import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Only import dart:io on non-web platforms
import 'dart:io' show File, Platform;

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
    try {
      _firestore.collection('users').doc(userId).set(
        {'status': 'online', 'lastSeen': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      ).catchError((e) {
        debugPrint('UserPresenceService: Error setting online status: $e');
      });
    } catch (e) {
      debugPrint('UserPresenceService: Error in _setOnline: $e');
    }
  }

  void _setOffline() {
    try {
      _firestore.collection('users').doc(userId).set(
        {'status': 'offline', 'lastSeen': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      ).catchError((e) {
        debugPrint('UserPresenceService: Error setting offline status: $e');
      });
    } catch (e) {
      debugPrint('UserPresenceService: Error in _setOffline: $e');
    }
  }

  void _listenIncomingCalls() {
    try {
      _incomingCallSub = _firestore
          .collection('calls')
          .doc(userId)
          .snapshots()
          .listen(
            (snapshot) {
              try {
                if (snapshot.exists) {
                  _incomingCallController.add(snapshot);
                }
              } catch (e) {
                debugPrint('UserPresenceService: Error processing snapshot: $e');
              }
            },
            onError: (e) {
              // Ignore permission denied errors - 'calls' collection may not exist or user may not have permission
              if (!e.toString().contains('permission-denied')) {
                debugPrint('UserPresenceService: Error listening to calls: $e');
              }
            },
          );
    } catch (e) {
      debugPrint('UserPresenceService: Error in _listenIncomingCalls: $e');
    }
  }

  void dispose() {
    try {
      _incomingCallSub.cancel();
      _incomingCallController.close();
      _setOffline();
    } catch (e) {
      debugPrint('UserPresenceService: Error disposing: $e');
    }
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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('HomeScreen: No user logged in');
        return;
      }

      debugPrint('HomeScreen: Initializing user: ${user.uid}');

      // Load profile from Firestore if not in memory
      if (UserService.instance.currentUser.value == null) {
        final profile = await UserService.instance.loadProfileFromFirestore();
        debugPrint('HomeScreen: Profile loaded: ${profile?.name ?? 'Unknown'}');
      } else {
        debugPrint('HomeScreen: Profile already in memory: ${UserService.instance.currentUser.value?.name}');
      }

      if (!mounted) return;

      // Initialize presence service with logged-in user
      _presenceService = UserPresenceService(userId: user.uid);
      debugPrint('HomeScreen: Presence service initialized');

      if (!mounted) return;

      // 1. Listen for incoming calls via Presence Service (Firestore)
      _presenceService!.incomingCallStream.listen((snapshot) {
        if (!mounted) return;
        try {
          final data = snapshot.data() as Map<String, dynamic>?;

          if (data != null && data['status'] == 'calling') {
            final callerId = data['callerId'] as String?;
            if (callerId != null && mounted) {
              _showIncomingCallDialog(callerId);
            }
          }
        } catch (e) {
          debugPrint('HomeScreen: Error processing incoming call: $e');
        }
      });

      // 2. Listen via CallService
      _callService.onIncomingCall((callerId, isVideo) {
        if (mounted) {
          _showIncomingCallDialog(callerId);
        }
      });

      debugPrint('HomeScreen: Call listeners initialized');
    } catch (e) {
      debugPrint('HomeScreen: Error initializing user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  void _showIncomingCallDialog(String callerId) {
    if (!mounted) return;
    
    try {
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
    } catch (e) {
      debugPrint('HomeScreen: Error showing incoming call dialog: $e');
    }
  }

  @override
  void dispose() {
    _presenceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Material design for all platforms (including web)
    // Avoid Platform checks which don't work on web
    return _material();
  }

  // ------------------ MATERIAL (ANDROID) ------------------
  Widget _material() {
    return Scaffold(
      appBar: _index == 0 ? _materialAppBar() : null,
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
      title: const Text(
        'Baddie',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => _buildFilterSheet(),
              );
            },
          ),
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [_profileAvatar()],
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildFilterSection('Age Range', ['18-25', '25-35', '35-50', 'Any']),
          const SizedBox(height: 20),
          _buildFilterSection('Location Distance', ['10 km', '25 km', '50 km', '100+ km']),
          const SizedBox(height: 20),
          _buildFilterSection('Verified Only', [
            'All',
            'Verified Only',
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF06595),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options
              .map((option) => FilterChip(
                    label: Text(option),
                    onSelected: (_) {},
                  ))
              .toList(),
        ),
      ],
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
              // Determine route type based on platform
              final route = !kIsWeb && Platform.isIOS
                  ? CupertinoPageRoute(builder: (_) => const ProfileScreen())
                  : MaterialPageRoute(builder: (_) => const ProfileScreen());
              Navigator.of(context).push(route);
            },
            child: avatar,
          ),
        );
      },
    );
  }
}