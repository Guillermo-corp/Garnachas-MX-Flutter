import 'package:flutter/material.dart';

class NotificationService {
  static final List<String> _logs = [];
  static final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);

  static List<String> get logs => List.unmodifiable(_logs);

  static void add(String message) {
    _logs.add(message);
    notificationCount.value = _logs.length;
  }

  static void clear() {
    _logs.clear();
    notificationCount.value = 0;
  }
}

void showNotificationsDialog(BuildContext context) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Notificaciones'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: NotificationService.logs.isEmpty
                          ? const Text('No hay notificaciones.')
                          : ListView(
                              shrinkWrap: true,
                              children: NotificationService.logs
                                  .map((msg) => ListTile(title: Text(msg)))
                                  .toList(),
                            ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }