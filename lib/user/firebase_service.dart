// firebase_service.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equip_manager/user/SharedPreferenceService.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload Image
  Future<String> uploadImage(File image) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('device_images/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  // Statistikani olish
  Future<Map<String, dynamic>> getDeviceStats() async {
    var snapshot = await _firestore.collection('devices').get();
    int activeCount = 0;
    int waitCount = 0;
    int rejectCount = 0;

    snapshot.docs.forEach((doc) {
      if (doc['state'] == 'active') {
        activeCount++;
      } else if (doc['state'] == 'wait') {
        waitCount++;
      } else if (doc['state'] == 'reject') {
        rejectCount++;
      }
    });

    return {'active': activeCount, 'wait': waitCount, 'reject': rejectCount};
  }

  // Add Device to Firestore
  Future<void> addDevice({
    required String deviceName,
    required String deviceType,
    required String model,
    required String location,
    required String serialNumber,
    required String manufacturer,
    required String purchaseDate,
    required String imageUrl,
  }) async {
    SharedPreferenceService service = SharedPreferenceService();
    var data = await service.getData('auth');
    var fio = "${data['firstName']} ${data['lastName']}";

    try {
      await _firestore.collection('devices').add({
        'device_name': deviceName,
        'device_type': deviceType,
        'model': model,
        'location': location,
        'author': fio,
        'serial_number': serialNumber,
        'manufacturer': manufacturer,
        'purchase_date': purchaseDate,
        'state': "wait",

        'device_image': imageUrl,
        'date_added': DateTime.now(),
      });
    } catch (e) {
      print("Error adding device: $e");
    }
  }

  Future<void> updateDeviceState(String deviceId, String newState) async {
    try {
      await _firestore.collection('devices').doc(deviceId).update({
        'state': newState,
      });
    } catch (e) {
      print('Error updating device state: $e');
    }
  }
  Future<void> deleteDevice(String deviceId) async {
    await FirebaseFirestore.instance.collection('devices').doc(deviceId).delete();
  }

  // Get Device List from Firestore
  Stream<QuerySnapshot> getDevices() {
    return _firestore.collection('devices').snapshots();
  }
}
