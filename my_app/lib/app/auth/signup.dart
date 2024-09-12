import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/constant/linkapi.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> signUp() async {
    if (formstate.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        print('Attempting to connect to the server...');
        final response = await http.post(
          Uri.parse(linkSignUp), // Ensure linkSignUp points to your signup API
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'username': usernameController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'role': 'client',
          }),
        );

        print('Response status code: ${response.statusCode}');
        print('Request body: ${json.encode({
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        })}');

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          final responseBody = response.body.isNotEmpty ? json.decode(response.body) : null;

          if (responseBody == null) {
            print('Received empty response from the server.');
            _showErrorDialog('Server returned an empty response.');
            return;
          }

          print('Received response from server: $responseBody');

          if (responseBody["status"] == 'success') {
            print('Signup successful.');
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          } else {
            print('Error from server: ${responseBody['message']}');
            _showErrorDialog(responseBody['message'] ?? 'An unknown error occurred');
          }
        } else {
          print('Server error: ${response.statusCode}');
          _showErrorDialog('Server error: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Exception during the request: $e');
        _showErrorDialog('Exception during the request: $e');
      }
    } else {
      print("Form is not valid");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Up Failed'),
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
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: formstate,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_add,
                        size: 100,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
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
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/login");
                        },
                        child: const Text("Already have an account? Log In"),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
