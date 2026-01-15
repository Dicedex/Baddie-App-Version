import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../models/profile.dart';
import '../services/user_service.dart';
import '../widgets/profile_card.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  // hold up to 3 uploaded image paths (local file paths)
  final List<String?> _uploadedImages = List<String?>.filled(3, null);

  final ImagePicker _picker = ImagePicker();

  // Interests & Lifestyle options
  final List<String> _allInterests = [
    'Music',
    'Travel',
    'Fitness',
    'Food',
    'Movies',
    'Outdoors',
  ];
  final List<String> _selectedInterests = [];

  // Personality & Intent options
  final List<String> _personalities = ['Casual', 'Serious', 'Friendship', 'Networking'];
  String _selectedPersonality = 'Casual';

  // Preferences & Filters
  double _maxDistance = 50;
  RangeValues _ageRange = const RangeValues(18, 40);
  bool _showVerifiedOnly = false;

  Future<void> _pickImageForIndex(int index) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _uploadedImages[index] = picked.path;
      });
    }
  }

  Profile _buildPreviewProfile() {
    return Profile(
      id: 'preview',
      name: _nameController.text.trim().isEmpty ? 'Your Name' : _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 18,
      imageUrl: _uploadedImages.firstWhere((e) => e != null, orElse: () => '') ?? '',
      bio: _bioController.text.trim().isEmpty ? 'Your short bio' : _bioController.text.trim(),
      interests: _selectedInterests,
      personality: _selectedPersonality,
      preferences: {
        'maxDistance': _maxDistance,
        'ageRangeStart': _ageRange.start.toInt(),
        'ageRangeEnd': _ageRange.end.toInt(),
        'verifiedOnly': _showVerifiedOnly,
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final profile = _buildPreviewProfile().copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: _uploadedImages.firstWhere(
          (e) => e != null,
          orElse: () => 'https://picsum.photos/400/400?image=30')!,
    );

    UserService.instance.setUser(profile);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args != null ? args['email'] as String? : null;

    final previewProfile = _buildPreviewProfile();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile setup'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (email != null)
                  Text('Creating account for $email', textAlign: TextAlign.center),
                const SizedBox(height: 12),

                // --- Live Preview ---
                ProfileCard(profile: previewProfile, expanded: true),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Display name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),

                      // Age
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Age required';
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 18) return 'Enter a valid age (18+)';
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),

                      // Bio
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(labelText: 'Short bio'),
                        maxLines: 3,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Images
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Tap a placeholder to upload photos')),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: Row(
                          children: List.generate(3, (i) {
                            final img = _uploadedImages[i];
                            return GestureDetector(
                              onTap: () => _pickImageForIndex(i),
                              child: Container(
                                width: 110,
                                height: 110,
                                margin: const EdgeInsets.only(right: 12),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade400),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: img == null
                                          ? const Center(
                                              child: Icon(Icons.add_a_photo,
                                                  size: 32, color: Colors.grey))
                                          : Builder(builder: (c) {
                                              if (img.startsWith('http')) {
                                                return Image.network(img,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (c, e, s) =>
                                                        Container(color: Colors.grey[300]));
                                              }
                                              return Image.file(File(img),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      Container(color: Colors.grey[300]));
                                            }),
                                    ),
                                    if (img != null)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _uploadedImages[i] = null;
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.black54, shape: BoxShape.circle),
                                            padding: const EdgeInsets.all(4),
                                            child:
                                                const Icon(Icons.close, size: 16, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Interests
                      const Align(
                          alignment: Alignment.centerLeft, child: Text('Interests & Lifestyle')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _allInterests.map((interest) {
                          final selected = _selectedInterests.contains(interest);
                          return FilterChip(
                            label: Text(interest),
                            selected: selected,
                            onSelected: (s) => setState(() {
                              if (s) {
                                _selectedInterests.add(interest);
                              } else {
                                _selectedInterests.remove(interest);
                              }
                            }),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Personality
                      const Align(
                          alignment: Alignment.centerLeft, child: Text('Personality & Intent')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _personalities.map((p) {
                          return ChoiceChip(
                            label: Text(p),
                            selected: _selectedPersonality == p,
                            onSelected: (_) => setState(() => _selectedPersonality = p),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Preferences
                      const Align(alignment: Alignment.centerLeft, child: Text('Preferences & Filters')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Max distance (km)'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Slider(
                              value: _maxDistance,
                              min: 5,
                              max: 200,
                              divisions: 39,
                              label: _maxDistance.round().toString(),
                              onChanged: (v) => setState(() => _maxDistance = v),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Age range'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RangeSlider(
                              values: _ageRange,
                              min: 18,
                              max: 100,
                              divisions: 82,
                              labels: RangeLabels('${_ageRange.start.toInt()}', '${_ageRange.end.toInt()}'),
                              onChanged: (r) => setState(() => _ageRange = r),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                              value: _showVerifiedOnly,
                              onChanged: (v) => setState(() => _showVerifiedOnly = v ?? false)),
                          const SizedBox(width: 8),
                          const Text('Show only verified profiles'),
                        ],
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _submit, child: const Text('Finish')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
