import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For handling files (used for mobile platforms)
import 'package:image_picker/image_picker.dart'; // Import image picker package
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/constant/linkapi.dart'; // Import your API base URL
import 'package:flutter/foundation.dart' show kIsWeb; // For platform checking

class AddStadium extends StatefulWidget {
  @override
  _AddStadiumState createState() => _AddStadiumState();
}

class _AddStadiumState extends State<AddStadium> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = ['Football', 'Basketball', 'Tennis']; // Example categories

  final _storage = const FlutterSecureStorage(); // Secure storage instance
  String _ownerId = ''; // To store the logged-in user's ID
  File? _imageFile; // To store the selected image for mobile
  Uint8List? _webImage; // To store the selected image for web
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    // Load the logged-in user's ID from secure storage
    String? userId = await _storage.read(key: 'userId');
    if (userId != null) {
      setState(() {
        _ownerId = userId;
      });
    }
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web, read the image as bytes
        var f = await pickedFile.readAsBytes();
        setState(() {
          _webImage = f;
        });
      } else {
        // For mobile platforms, use File
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    String name = _nameController.text;
    String location = _locationController.text;

    String url = "$baseUrl/terrains.php"; // Ensure this is correct

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['name'] = name;
    request.fields['location'] = location;
    request.fields['category'] = _selectedCategory ?? '';
    request.fields['owner_id'] = _ownerId;

    if (!kIsWeb && _imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('imageart', _imageFile!.path));
    } else if (kIsWeb && _webImage != null) {
      request.files.add(http.MultipartFile.fromBytes('imageart', _webImage!, filename: '$name'));
    }

    var response = await request.send();
    var responseBody = await http.Response.fromStream(response);

    // Debug: Print the raw response
    print('Raw response: ${responseBody.body}');

    if (response.statusCode == 200) {
      try {
        var decodedResponse = jsonDecode(responseBody.body);

        if (decodedResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stadium added successfully')),
          );
          _formKey.currentState?.reset();
          setState(() {
            _imageFile = null;
            _webImage = null;
          });
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacementNamed('/home');
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add stadium: ${decodedResponse['message']}')),
          );
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse server response')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Stadium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Stadium Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stadium name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map<DropdownMenuItem<String>>((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Display selected image
                if (!kIsWeb && _imageFile != null)
                  Image.file(_imageFile!, height: 150, width: 150)
                else if (kIsWeb && _webImage != null)
                  Image.memory(_webImage!, height: 150, width: 150)
                else
                  const Text('No image selected'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Stadium'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Return'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
