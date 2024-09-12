import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import the secure storage package

import 'package:my_app/constant/linkapi.dart'; // Ensure this points to the correct URL

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // Create an instance of FlutterSecureStorage
  final storage = FlutterSecureStorage();

  Future<void> login() async {
    if (formstate.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(linklogin),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': emailController.text,
            'password': passwordController.text,
          }),
        );

        print('Response status code: ${response.statusCode}');
        print('Request body: ${json.encode({
              'email': emailController.text,
            })}');
        print("--------------------------------------");
        print("you are logged in with ${emailController.text}");

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          final responseBody =
              response.body.isNotEmpty ? json.decode(response.body) : null;
          print('Response body: $responseBody');

          if (responseBody == null) {
            _showErrorDialog('Server returned an empty response.');
            return;
          }

          if (responseBody['status'] == 'success') {
            final userData = responseBody['data'];

            if (userData is Map<String, dynamic>) {
              final role =
                  userData['role'] as String?; // Ensure `role` is a String
              final userId = userData['id']?.toString() ??
                  ''; // Safely get and convert `id` if it exists
              final email = userData['email']
                  as String?; // Safely get `email` if it exists
              final username = userData['username']
                  as String?; // Safely get `username` if it exists

              // Store values securely
              await storage.write(key: 'role', value: role ?? '');
              await storage.write(key: 'email', value: email ?? '');
              await storage.write(key: 'username', value: username ?? '');
              await storage.write(key: 'userId', value: userId);

              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
                arguments:
                    userData, // Pass `userData` if needed on the home page
              );
              /*Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => DynamicScreen(userRole: 'admin'), // Or 'client'
                 ),
                );*/
            } else {
              _showErrorDialog('Unexpected response format.');
            }
          } else {
            _showErrorDialog(
                responseBody['message'] ?? 'An unknown error occurred');
          }
        } else {
          _showErrorDialog('Server error: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          print(e);
        });
        print('Error during the request: $e');
        _showErrorDialog('Exception during the request: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formstate,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed("/signup");
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
