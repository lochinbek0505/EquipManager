// device_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_service.dart';

class DevicePage extends StatefulWidget {
  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _modelController = TextEditingController();
  final _locationController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  File? _image;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addDevice() async {
    if (_image == null ||
        _nameController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _serialNumberController.text.isEmpty ||
        _manufacturerController.text.isEmpty ||
        _purchaseDateController.text.isEmpty) {
      return;
    }

    _imageUrl = await _firebaseService.uploadImage(_image!);
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      await _firebaseService.addDevice(
        deviceName: _nameController.text,
        deviceType: _typeController.text,
        model: _modelController.text,
        location: _locationController.text,
        serialNumber: _serialNumberController.text,
        manufacturer: _manufacturerController.text,
        purchaseDate: _purchaseDateController.text,
        imageUrl: _imageUrl!,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Device added successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          'Добавить устройство',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Название устройства',
                controller: _nameController,
                hint: 'Введите название устройства',
              ),
              SizedBox(height: 16),

              _buildTextField(
                label: 'Тип устройства',
                controller: _typeController,
                hint: 'Введите тип устройства',
              ),
              SizedBox(height: 16),

              _buildTextField(
                label: 'Модель',
                controller: _modelController,
                hint: 'Введите модель',
              ),
              SizedBox(height: 16),

              _buildTextField(
                label: 'Местоположение',
                controller: _locationController,
                hint: 'Введите местоположение',
              ),
              SizedBox(height: 16),

              _buildTextField(
                label: 'Серийный номер',
                controller: _serialNumberController,
                hint: 'Введите серийный номер',
              ),
              SizedBox(height: 16),

              _buildTextField(
                label: 'Производитель',
                controller: _manufacturerController,
                hint: 'Введите производителя',
              ),
              SizedBox(height: 16),

              _buildTextField(
                label: 'Дата покупки',
                controller: _purchaseDateController,
                hint: 'Введите дату покупки (например, 2022-01-01)',
              ),
              SizedBox(height: 20),

              // Кнопка выбора изображения
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: Text(
                    'Выбрать изображение устройства',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Отображение выбранного изображения
              _image != null
                  ? Center(
                    child: Image.file(
                      _image!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                  : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Text('Изображение не выбрано')),
                  ),
              SizedBox(height: 20),

              // Кнопка добавления устройства
              Center(
                child: ElevatedButton(
                  onPressed: _addDevice,
                  child: Text(
                    'Добавить устройство',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
          ),
          maxLines: maxLines,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
