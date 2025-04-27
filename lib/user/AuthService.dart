import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equip_manager/user/SharedPreferenceService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final SharedPreferenceService shr = SharedPreferenceService();

  Future<void> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // Попытка входа в систему через Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Получение данных пользователя из Firestore после входа
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          String role = userData['role'] ?? 'Неизвестно';
          String firstName = userData['firstName'] ?? 'Нет данных';
          String lastName = userData['lastName'] ?? 'Нет данных';

          Timestamp createdAtTimestamp = userData['createdAt'];
          DateTime createdAt =
              createdAtTimestamp != null
                  ? createdAtTimestamp.toDate()
                  : DateTime.now();

          String createdAtString = createdAt.toIso8601String();

          Map<String, dynamic> encodableUserData = {
            'role': role,
            'firstName': firstName,
            'lastName': lastName,
            'createdAt': createdAtString,
          };

          await shr.saveData("auth", encodableUserData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Добро пожаловать, $firstName $lastName! Ваша роль: $role. Аккаунт создан: $createdAtString',
              ),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (builder) => HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Данные пользователя не найдены!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пользователь не найден в Firestore!')),
        );
      }
    } catch (e) {
      print('Ошибка при входе: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка входа: $e')));
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String role,
    BuildContext context,
    String firstName,
    String lastName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Регистрация прошла успешно!')),
      );
      Navigator.pop(context); // Возврат на экран входа после регистрации
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка регистрации: $e')));
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await shr.clearData("auth");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы успешно вышли из аккаунта!')),
      );

      // Здесь вы можете перенаправить пользователя на экран входа
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка выхода: $e')));
    }
  }
}
