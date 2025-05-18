import 'package:equip_manager/user/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../user/firebase_service.dart';

class RejectedActiveDevicesPage extends StatelessWidget {
  RejectedActiveDevicesPage({super.key});

  final FirebaseService _firebaseService = FirebaseService();
  final AuthService authService = AuthService();

  final Map<String, Color> colors = {
    "reject": Colors.red,
    "wait": Colors.yellowAccent,
    "active": Colors.green,
  };

  final Map<String, String> texts = {
    "reject": "Отклоненный",
    "wait": "Ожидающий",
    "active": "Одобренный",
  };

  void showQrCodeDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('QR-код', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: text, version: QrVersions.auto, size: 200.0),
            const SizedBox(height: 20),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'Активные и отклоненные устройства',
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: _firebaseService.getDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Нет активных или отклоненных устройств.'));
          }

          final devices = snapshot.data!.docs.where((device) {
            return device['state'] == 'active' || device['state'] == 'reject';
          }).toList();

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return GestureDetector(
                onTap: () {
                  showQrCodeDialog(
                    context,
                    "${device['device_name']}:${device['serial_number']}:${device['manufacturer']}",
                  );
                },
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            device['device_image'],
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              device['device_name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Подтверждение'),
                                    content: const Text('Вы уверены, что хотите удалить это устройство?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Нет'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Да'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await _firebaseService.deleteDevice(device.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Устройство удалено')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Тип: ${device['device_type']}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        Text('Локация: ${device['location']}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        Text('Серийный номер: ${device['serial_number']}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        Text('Производитель: ${device['manufacturer']}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        Text('Дата покупки: ${device['purchase_date']}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Text('Добавил: ${device['author']}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Text(
                          'Состояние: ${texts[device['state']] ?? device['state']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors[device['state']] ?? Colors.grey,
                          ),
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
}
