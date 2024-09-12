import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? _file;

  Future<void> _uploadFile() async {
    if (_file == null) return;

    try {
      final uri = Uri.parse('http://localhost/phptest/newdb/upload.php');
      var request = http.MultipartRequest('POST', uri);
      
      request.files.add(
        http.MultipartFile(
          'fileToUpload',
          _file!.readAsBytes().asStream(),
          _file!.lengthSync(),
          filename: basename(_file!.path),
          contentType: MediaType('application', 'octet-stream'),
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        print('File uploaded successfully');
        final responseBody = await response.stream.bytesToString();
        print(responseBody);
      } else {
        print('File upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Upload'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Pick File'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}
