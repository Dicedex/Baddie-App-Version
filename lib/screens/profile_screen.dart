import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shimmer/shimmer.dart';
import '../services/user_service.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _loading = true;
  late final AnimationController _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    // simulate loading shimmer
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _loading = false);
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder<Profile?>(
            valueListenable: UserService.instance.currentUser,
            builder: (context, profile, _) {
              if (_loading || profile == null) {
                return _buildShimmer();
              }

              return FadeTransition(
                opacity: _animController.drive(CurveTween(curve: Curves.easeIn)),
                child: _buildProfile(profile),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(height: 300, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(height: 20, width: 160, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(height: 14, width: 240, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(height: 60, color: Colors.white),
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: 4,
          ),
        )
      ],
    );
  }

  Widget _buildProfile(Profile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 300,
            child: profile.imageUrl != null
                ? (profile.imageUrl!.startsWith('http')
                    ? Image.network(profile.imageUrl!, fit: BoxFit.cover)
                    : Image.file(File(profile.imageUrl!), fit: BoxFit.cover))
                : Container(color: Colors.grey[200]),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${profile.name}, ${profile.age}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(profile.bio, style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report/Block not implemented'))),
              icon: const Icon(Icons.more_vert),
            )
          ],
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: profile.interests.map((i) => Chip(label: Text(i))).toList()),
        const SizedBox(height: 12),
        Text('Personality: ${profile.personality}'),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: ListView(
              key: ValueKey(profile.id),
              children: [
                ListTile(
                  leading: const Icon(Icons.place),
                  title: Text('Max distance: ${profile.preferences['maxDistance']} km'),
                ),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: Text(
                      'Age range: ${profile.preferences['ageRangeStart']} - ${profile.preferences['ageRangeEnd']}'),
                ),
                ListTile(
                  leading: const Icon(Icons.verified),
                  title: Text('Verified only: ${profile.preferences['verifiedOnly']}'),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
