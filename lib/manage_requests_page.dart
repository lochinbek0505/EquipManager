import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageRequestsPage extends StatelessWidget {
  const ManageRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xizmat So‘rovlari')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('service_requests')
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
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    await req.reference.update({'status': value});
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'in_progress',
                          child: Text('Jarayonda'),
                        ),
                        const PopupMenuItem(
                          value: 'completed',
                          child: Text('Bajarildi'),
                        ),
                        const PopupMenuItem(
                          value: 'rejected',
                          child: Text('Rad etildi'),
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
