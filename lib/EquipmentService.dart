import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentService {
  final CollectionReference equipments = FirebaseFirestore.instance.collection(
    'equipments',
  );

  Future<void> addEquipment(Map<String, dynamic> data) async {
    await equipments.add(data);
  }

  Stream<QuerySnapshot> getEquipments() {
    return equipments.snapshots();
  }

  Future<void> updateEquipment(String id, Map<String, dynamic> data) async {
    await equipments.doc(id).update(data);
  }

  Future<void> deleteEquipment(String id) async {
    await equipments.doc(id).delete();
  }
}
