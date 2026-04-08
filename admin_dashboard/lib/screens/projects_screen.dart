import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/supabase_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProjects();
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = _supabaseService.getProjects();
    });
  }

  void _showEditDialog([Project? project]) {
    final titleController = TextEditingController(text: project?.title ?? '');
    final categoryController = TextEditingController(text: project?.category ?? 'art');
    final metadataController = TextEditingController(text: project?.metadataInfo ?? '');
    final descriptionController = TextEditingController(text: project?.description ?? '');
    final imagesController = TextEditingController(text: project?.images.join('\n') ?? '');
    final sortOrderController = TextEditingController(text: project?.sortOrder.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project == null ? 'Add Project' : 'Edit Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category (art, books, design)')),
              TextField(controller: metadataController, decoration: const InputDecoration(labelText: 'Metadata Info')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              TextField(controller: imagesController, decoration: const InputDecoration(labelText: 'Image URLs (one per line)'), maxLines: 5),
              TextField(controller: sortOrderController, decoration: const InputDecoration(labelText: 'Sort Order'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newProject = Project(
                id: project?.id,
                title: titleController.text,
                category: categoryController.text,
                metadataInfo: metadataController.text,
                description: descriptionController.text,
                images: imagesController.text.split('\n').where((s) => s.isNotEmpty).toList(),
                sortOrder: int.tryParse(sortOrderController.text) ?? 0,
              );
              await _supabaseService.upsertProject(newProject);
              if (!context.mounted) return;
              Navigator.pop(context);
              _refreshProjects();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showEditDialog()),
        ],
      ),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final projects = snapshot.data ?? [];
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                title: Text(project.title),
                subtitle: Text('${project.category} - ${project.images.length} images'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(project)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (project.id != null) {
                          await _supabaseService.deleteProject(project.id!);
                          _refreshProjects();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
