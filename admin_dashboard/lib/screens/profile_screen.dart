import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();

  Profile? _profile;
  bool _loading = true;

  final _introController = TextEditingController();
  final _moreController = TextEditingController();
  final _imageController = TextEditingController();
  final _emailController = TextEditingController();
  final _instaHandleController = TextEditingController();
  final _instaUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _supabaseService.getProfile();
    if (profile != null) {
      setState(() {
        _profile = profile;
        _introController.text = profile.aboutTextIntro ?? '';
        _moreController.text = profile.aboutTextMore ?? '';
        _imageController.text = profile.aboutImageUrl ?? '';
        _emailController.text = profile.email ?? '';
        _instaHandleController.text = profile.instagramHandle ?? '';
        _instaUrlController.text = profile.instagramUrl ?? '';
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final updatedProfile = Profile(
      id: _profile?.id,
      aboutTextIntro: _introController.text,
      aboutTextMore: _moreController.text,
      aboutImageUrl: _imageController.text,
      email: _emailController.text,
      instagramHandle: _instaHandleController.text,
      instagramUrl: _instaUrlController.text,
    );
    await _supabaseService.updateProfile(updatedProfile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('About Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: _introController, decoration: const InputDecoration(labelText: 'Intro Text'), maxLines: 4),
              TextField(controller: _moreController, decoration: const InputDecoration(labelText: 'More About Text'), maxLines: 8),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _imageController, decoration: const InputDecoration(labelText: 'About Image URL'))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null && result.files.single.bytes != null) {
                        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
                        final url = await _supabaseService.uploadImage(fileName, result.files.single.bytes!);
                        setState(() {
                          _imageController.text = url;
                        });
                      }
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Contact & Social', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _instaHandleController, decoration: const InputDecoration(labelText: 'Instagram Handle')),
              TextField(controller: _instaUrlController, decoration: const InputDecoration(labelText: 'Instagram URL')),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Profile Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
