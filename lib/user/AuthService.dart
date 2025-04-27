import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equip_manager/user/SharedPreferenceService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final SharedPreferenceService shr = SharedPreferenceService();
  Future<void> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // Attempt to sign in the user with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve the user's data from Firestore once signed in
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        // Safely retrieve the data as a Map
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        // Check if userData is not null
        if (userData != null) {
          // Extract user information, and handle potential null values
          String role =
              userData['role'] ?? 'Unknown'; // Default to 'Unknown' if null
          String firstName = userData['firstName'] ?? 'N/A';
          String lastName = userData['lastName'] ?? 'N/A';

          // Handle Firestore Timestamps and convert them to DateTime
          Timestamp createdAtTimestamp = userData['createdAt'];
          DateTime createdAt =
              createdAtTimestamp != null
                  ? createdAtTimestamp
                      .toDate() // Convert Timestamp to DateTime
                  : DateTime.now(); // Fallback to current date if Timestamp is null

          // Convert DateTime to string if saving in SharedPreferences or as JSON
          String createdAtString = createdAt.toIso8601String();

          // Create a Map with all user data, converting any non-encodable values
          Map<String, dynamic> encodableUserData = {
            'role': role,
            'firstName': firstName,
            'lastName': lastName,
            'createdAt':
                createdAtString, // Save the string representation of the DateTime
          };

          // Save user data locally (if needed)
          await shr.saveData("auth", encodableUserData);

          // Display a welcome message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome, $firstName $lastName! You are a $role. Account created on: $createdAtString',
              ),
            ),
          );

          // Navigate to the HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (builder) => HomePage()),
          );
        } else {
          // Handle the case where user data is not available
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User data not found!')));
        }
      } else {
        // Handle the case where the user document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found in Firestore!')),
        );
      }
    } catch (e) {
      // Handle errors (e.g., network issues, wrong credentials)
      print('Error during sign-in: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    }
  }

  // Method to fetch user data from Firestore and handle Timestamp fields
  Future<void> _getUserDataAndNavigate(
    String userId,
    BuildContext context,
  ) async {
    try {
      // Get user document from Firestore
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userId).get();

      // Check if the document exists
      if (userDoc.exists) {
        // Safely access the data and ensure it is a Map
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        // Check if the data was fetched successfully
        if (userData != null) {
          String role = userData['role'] ?? 'Unknown';
          String firstName = userData['firstName'] ?? 'N/A';
          String lastName = userData['lastName'] ?? 'N/A';

          // If the "createdAt" field is a Timestamp, convert it to DateTime
          Timestamp createdAtTimestamp = userData['createdAt'];
          DateTime createdAt =
              createdAtTimestamp != null
                  ? createdAtTimestamp.toDate()
                  : DateTime.now(); // Use current date if it's null

          // Now you can use the DateTime object for the createdAt field
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome, $firstName $lastName! You are a $role. Account created on: $createdAt',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch user data.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found in Firestore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching user data: $e')));
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

      // Firestore'ga foydalanuvchi ma'lumotlarini saqlash
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
      Navigator.pop(context); // Registratsiyadan keyin login sahifaga qaytish
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration error: $e')));
    }
  }
}
