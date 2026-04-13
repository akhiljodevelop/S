import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';
import '../models/press_item.dart';
import '../models/profile.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Projects
  Future<List<Project>> getProjects() async {
    final response = await _supabase
        .from('projects')
        .select()
        .order('sort_order', ascending: true);
    return (response as List).map((json) => Project.fromJson(json)).toList();
  }

  Future<void> upsertProject(Project project) async {
    await _supabase.from('projects').upsert(project.toJson());
  }

  Future<void> deleteProject(String id) async {
    await _supabase.from('projects').delete().eq('id', id);
  }

  // Press Items
  Future<List<PressItem>> getPressItems() async {
    final response = await _supabase
        .from('press_items')
        .select()
        .order('sort_order', ascending: true);
    return (response as List).map((json) => PressItem.fromJson(json)).toList();
  }

  Future<void> upsertPressItem(PressItem item) async {
    await _supabase.from('press_items').upsert(item.toJson());
  }

  Future<void> deletePressItem(String id) async {
    await _supabase.from('press_items').delete().eq('id', id);
  }

  // Profile
  Future<Profile?> getProfile() async {
    final response = await _supabase
        .from('profile')
        .select()
        .maybeSingle();
    return response != null ? Profile.fromJson(response) : null;
  }

  Future<void> updateProfile(Profile profile) async {
    await _supabase.from('profile').upsert(profile.toJson());
  }

  // Storage
  Future<String> uploadImage(String fileName, List<int> bytes) async {
    final path = 'public/$fileName';
    await _supabase.storage.from('portfolio-images').uploadBinary(path, bytes as List<int>);
    return _supabase.storage.from('portfolio-images').getPublicUrl(path);
  }
}
