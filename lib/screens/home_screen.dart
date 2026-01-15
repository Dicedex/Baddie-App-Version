import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'swipe_screen.dart';
import 'matches_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import '../models/profile.dart';
import '../services/user_service.dart';
import '../services/call_service.dart';

/// ------------------ USER PRESENCE SERVICE ------------------
class UserPresenceService {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final StreamSubscription<DocumentSnapshot> _incomingCallSub;

  final StreamController<DocumentSnapshot> _incomingCallController =
      StreamController.broadcast();

  Stream<DocumentSnapshot> get incomingCallStream =>
      _incomingCallController.stream;

  UserPresenceService({required this.userId}) {
    _setOnline();
    _listenIncomingCalls();
  }

  void _setOnline() {
    _firestore.collection('users').doc(userId).set(
      {'status': 'online', 'lastSeen': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  void _setOffline() {
    _firestore.collection('users').doc(userId).set(
      {'status': 'offline', 'lastSeen': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  void _listenIncomingCalls() {
    _incomingCallSub = _firestore
        .collection('calls')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _incomingCallController.add(snapshot);
      }
    });
  }

  void dispose() {
    _incomingCallSub.cancel();
    _incomingCallController.close();
    _setOffline();
  }
}

/// ------------------ HOME SCREEN ------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  // FIX 1: Access the service via the Singleton instance
  final CallService _callService = CallService.instance;
  
  UserPresenceService? _presenceService;

  // Badge counts
  final ValueNotifier<int> matchesCount = ValueNotifier<int>(3);
  final ValueNotifier<int> messagesCount = ValueNotifier<int>(7);

  // Pages
  final List<Widget> pages = const [
    SwipeScreen(),
    MatchesScreen(),
    MessagesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Initialize presence service with logged-in user
    _presenceService = UserPresenceService(userId: user.uid);

    // 1. Listen for incoming calls via Presence Service (Firestore)
    _presenceService!.incomingCallStream.listen((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data['status'] == 'calling') {
        final callerId = data['callerId'] as String?;
        if (callerId != null) {
          _showIncomingCallDialog(callerId);
        }
      }
    });

    // 3. Listen via CallService
    // FIX 2: Updated method name and arguments to match CallService definition
    _callService.onIncomingCall((callerId, isVideo) {
      // You can handle 'isVideo' here if you want to show a video icon
      _showIncomingCallDialog(callerId);
    });
  }

  void _showIncomingCallDialog(String callerId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Incoming Call'),
        content: Text('User $callerId is calling you'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to your CallScreen with caller info
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _presenceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _cupertino() : _material();
  }

  // ------------------ MATERIAL (ANDROID) ------------------
  Widget _material() {
    return Scaffold(
      appBar: _materialAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: pages[_index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: _badge(matchesCount, Icons.chat),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: _badge(messagesCount, Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }

  AppBar _materialAppBar() {
    return AppBar(
      title: const Text('Baddie'),
      automaticallyImplyLeading: false,
      actions: [_profileAvatar()],
    );
  }

  // ------------------ CUPERTINO (IOS) ------------------
  Widget _cupertino() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: _badge(matchesCount, CupertinoIcons.chat_bubble_2),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: _badge(messagesCount, CupertinoIcons.mail),
            label: 'Messages',
          ),
        ],
      ),
      tabBuilder: (_, index) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Baddie'),
            trailing: _profileAvatar(),
          ),
          child: pages[index],
        );
      },
    );
  }

  // ------------------ SHARED WIDGETS ------------------
  Widget _badge(ValueNotifier<int> count, IconData icon) {
    return ValueListenableBuilder<int>(
      valueListenable: count,
      builder: (_, value, __) {
        if (value == 0) return Icon(icon);
        return badges.Badge(
          badgeContent: Text(
            value.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Colors.red,
            padding: EdgeInsets.all(5),
          ),
          child: Icon(icon),
        );
      },
    );
  }

  Widget _profileAvatar() {
    return ValueListenableBuilder<Profile?>(
      valueListenable: UserService.instance.currentUser,
      builder: (_, profile, __) {
        if (profile == null) {
          return const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(child: Icon(Icons.person)),
          );
        }

        final String? imageUrl = profile.imageUrl;
        Widget avatar;

        if (imageUrl != null && imageUrl.startsWith('http')) {
          avatar = CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(imageUrl),
          );
        } else if (imageUrl != null) {
          avatar = CircleAvatar(
            backgroundImage: FileImage(File(imageUrl)),
          );
        } else {
          avatar = const CircleAvatar(child: Icon(Icons.person));
        }

        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                Platform.isIOS
                    ? CupertinoPageRoute(builder: (_) => const ProfileScreen())
                    : MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: avatar,
          ),
        );
      },
    );
  }
}