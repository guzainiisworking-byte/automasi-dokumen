import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/timezone_provider.dart';
import '../widgets/digital_clock_widget.dart';
import '../models/timezone_model.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Clock'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTimezoneDialog,
            tooltip: 'Tambah Timezone',
          ),
        ],
      ),
      body: Consumer<TimezoneProvider>(
        builder: (context, provider, _) {
          if (provider.timezones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada timezone',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddTimezoneDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Timezone'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.timezones.length,
            itemBuilder: (context, index) {
              final tz = provider.timezones[index];
              return Dismissible(
                key: Key(tz.id),
                onDismissed: (_) {
                  provider.removeTimezone(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${tz.name} dihapus')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tz.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tz.timezone,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditTimezoneDialog(
                                  context, provider, index, tz),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DigitalClockWidget(
                          timezone: tz.timezone,
                          isAnalog: false,
                        ),
                        const SizedBox(height: 12),
                        DigitalClockWidget(
                          timezone: tz.timezone,
                          isAnalog: true,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTimezoneDialog() {
    final nameController = TextEditingController();
    final timezoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Timezone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lokasi',
                hintText: 'Contoh: Jakarta, Tokyo, London',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timezoneController,
              decoration: const InputDecoration(
                labelText: 'Timezone',
                hintText: 'Contoh: Asia/Jakarta',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Format timezone:\nAsia/Jakarta, Europe/London, America/New_York, etc.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  timezoneController.text.isNotEmpty) {
                context.read<TimezoneProvider>().addTimezone(
                  TimezoneModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    timezone: timezoneController.text,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${nameController.text} ditambahkan')),
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditTimezoneDialog(BuildContext context, TimezoneProvider provider,
      int index, TimezoneModel tz) {
    final nameController = TextEditingController(text: tz.name);
    final timezoneController = TextEditingController(text: tz.timezone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Timezone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Lokasi'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timezoneController,
              decoration: const InputDecoration(labelText: 'Timezone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  timezoneController.text.isNotEmpty) {
                provider.updateTimezone(
                  index,
                  TimezoneModel(
                    id: tz.id,
                    name: nameController.text,
                    timezone: timezoneController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
