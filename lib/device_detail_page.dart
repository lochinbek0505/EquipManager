import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeviceDetailPage extends StatelessWidget {
  final String deviceId;
  final TextEditingController descriptionController = TextEditingController();

  DeviceDetailPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final deviceRef = FirebaseFirestore.instance
        .collection('devices')
        .doc(deviceId);

    return Scaffold(
      appBar: AppBar(title: const Text('Jihoz Tafsiloti')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Muammo ta\'rifi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Muammo haqida yozing...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('service_requests')
                    .add({
                      'deviceId': deviceId,
                      'description': descriptionController.text,
                      'status': 'pending', // default status
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                Navigator.pop(context);
              },
              child: const Text('Xizmat so‘rovi yuborish'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Xizmat so‘rovlari:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('service_requests')
                        .where('deviceId', isEqualTo: deviceId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final requests = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return ListTile(
                        title: Text(req['description']),
                        subtitle: Text('Holat: ${req['status']}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
