import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceService {
  final CollectionReference requests = FirebaseFirestore.instance.collection(
    'maintenance_requests',
  );

  Future<void> createRequest(Map<String, dynamic> data) async {
    await requests.add(data);
  }

  Stream<QuerySnapshot> getRequests() {
    return requests.snapshots();
  }

  Future<void> updateRequest(String id, Map<String, dynamic> data) async {
    await requests.doc(id).update(data);
  }

  Future<void> assignTechnician(String requestId, String technicianId) async {
    await requests.doc(requestId).update({'assignedTechnician': technicianId});
  }
}
