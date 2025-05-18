import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../user/AuthService.dart';
import '../user/firebase_service.dart';

class AdminPage extends StatefulWidget {
  AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseService _firebaseService = FirebaseService();
  var colors = {
    "reject": Colors.red,

    "wait": Colors.yellowAccent,
    "active": Colors.green,
  };
  final AuthService authService = AuthService();

  var texts = {
    "reject": "Отклоненный",

    "wait": "Ожидающий",
    "active": "Одобренный",
  };

  void showQrCodeDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('QR-код', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(data: text, version: QrVersions.auto, size: 200.0),
                SizedBox(height: 20),
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
                child: Text('Закрыть'),
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
        title: Text(
          'Панель Администратора',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              authService.signOut(context);
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firebaseService.getDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Устройств нет.'));
          }

          final devices = snapshot.data!.docs;
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              if (device['state'] == 'wait') {
                return GestureDetector(
                  onTap: () {
                    showQrCodeDialog(
                      context,
                      "${device['device_name']}:${device['serial_number']}:${device['manufacturer']}",
                    );
                  },
                  child: Card(
                    elevation: 8,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              device['device_image'],
                              width: double.infinity,
                              height: 150,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            device['device_name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Тип: ${device['device_type']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Локация: ${device['location']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Серийный номер: ${device['serial_number']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Производитель: ${device['manufacturer']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Дата покупки: ${device['purchase_date']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Добавил: ${device['author']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Статус: ${texts[device['state']]}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors[device['state']],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  await _firebaseService.updateDeviceState(
                                    device.id,
                                    'active',
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  await _firebaseService.updateDeviceState(
                                    device.id,
                                    'reject',
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink(); // Скрыть устройства не в состоянии "ожидание"
            },
          );
        },
      ),
    );
  }
}
