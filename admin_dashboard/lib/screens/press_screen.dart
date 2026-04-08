import 'package:flutter/material.dart';
import '../models/press_item.dart';
import '../services/supabase_service.dart';

class PressScreen extends StatefulWidget {
  const PressScreen({super.key});

  @override
  State<PressScreen> createState() => _PressScreenState();
}

class _PressScreenState extends State<PressScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<PressItem>> _pressFuture;

  @override
  void initState() {
    super.initState();
    _refreshPress();
  }

  void _refreshPress() {
    setState(() {
      _pressFuture = _supabaseService.getPressItems();
    });
  }

  void _showEditDialog([PressItem? item]) {
    final sourceController = TextEditingController(text: item?.source ?? '');
    final contentController = TextEditingController(text: item?.content ?? '');
    final urlController = TextEditingController(text: item?.url ?? '');
    final sortOrderController = TextEditingController(text: item?.sortOrder.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Press Item' : 'Edit Press Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: sourceController, decoration: const InputDecoration(labelText: 'Source')),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
              TextField(controller: urlController, decoration: const InputDecoration(labelText: 'URL')),
              TextField(controller: sortOrderController, decoration: const InputDecoration(labelText: 'Sort Order'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newItem = PressItem(
                id: item?.id,
                source: sourceController.text,
                content: contentController.text,
                url: urlController.text,
                sortOrder: int.tryParse(sortOrderController.text) ?? 0,
              );
              await _supabaseService.upsertPressItem(newItem);
              if (!context.mounted) return;
              Navigator.pop(context);
              _refreshPress();
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
        title: const Text('Press Items'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showEditDialog()),
        ],
      ),
      body: FutureBuilder<List<PressItem>>(
        future: _pressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.source),
                subtitle: Text(item.content),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(item)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (item.id != null) {
                          await _supabaseService.deletePressItem(item.id!);
                          _refreshPress();
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
