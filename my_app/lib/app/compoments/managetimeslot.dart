import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/constant/linkapi.dart';

class ManageTimeslot extends StatefulWidget {
  @override
  _ManageTimeslotState createState() => _ManageTimeslotState();
}

class _ManageTimeslotState extends State<ManageTimeslot> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _terrainIdController = TextEditingController();

  final _storage = const FlutterSecureStorage();
  int? _adminId;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<Map<String, dynamic>> _terrains = [];
  String? _selectedTerrain;

  @override
  void initState() {
    super.initState();
    _loadAdminId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_adminId != null) {
      _fetchTerrains();
    }
  }

  Future<void> _loadAdminId() async {
    try {
      String? adminIdString = await _storage.read(key: 'userId');
      if (adminIdString != null) {
        setState(() {
          _adminId = int.tryParse(adminIdString);
        });
        if (_adminId == null) {
          throw FormatException('Admin ID is not a valid integer');
        }
        print('Admin ID loaded: $_adminId');
        _fetchTerrains();
      } else {
        throw Exception('Admin ID not found in secure storage');
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading admin ID: $e')),
        );
      });
      print('Error loading admin ID: $e');
    }
  }

  Future<void> _fetchTerrains() async {
    if (_adminId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin ID is null')),
        );
      });
      print('Error: Admin ID is null');
      return;
    }

    try {
      String url = '${ApiLinks.readTerrain}?owner_id=$_adminId';
      var response = await http.get(Uri.parse(url));
      print('Fetch Terrains Response status: ${response.statusCode}');
      /*print('Fetch Terrains Response body: ${response.body}');*/

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "success") {
          setState(() {
            _terrains = List<Map<String, dynamic>>.from(responseBody['data']);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load terrains: ${responseBody["message"]}')),
            );
          });
          print('Failed to load terrains: ${responseBody["message"]}');
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      });
      print('Error: $e');
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  Future<void> _addTimeslot() async {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both start and end times')),
        );
        return;
      }

      String terrainId = _selectedTerrain ?? '';

      String url = ApiLinks.createTimeslot;

      Map<String, dynamic> requestData = {
        "start_time": _startTime!.format(context) + ":00",
        "end_time": _endTime!.format(context) + ":00",
        "terrain_id": terrainId,
        "owner_id": _adminId, // Automatically fills in the admin's ID
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestData),
        );

        print('Add Timeslot Response status: ${response.statusCode}');
        print('Add Timeslot Response body: ${response.body}');

        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          if (responseBody['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Timeslot added successfully')),
            );
            _formKey.currentState?.reset();
            setState(() {
              _startTime = null;
              _endTime = null;
            });
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add timeslot: ${responseBody['message']}')),
            );
            print('Failed to add timeslot: ${responseBody['message']}');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Timeslot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTerrainDropdown(),
              const SizedBox(height: 20),
              ListTile(
                title: Text(_startTime == null
                    ? 'Select Start Time'
                    : 'Start Time: ${_startTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                title: Text(_endTime == null
                    ? 'Select End Time'
                    : 'End Time: ${_endTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTimeslot,
                child: const Text('Add Timeslot'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerrainDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedTerrain,
      decoration: const InputDecoration(
        labelText: 'Select Terrain',
        border: OutlineInputBorder(),
      ),
      items: _terrains.map<DropdownMenuItem<String>>((terrain) {
        return DropdownMenuItem<String>(
          value: terrain['id'].toString(),
          child: Text(terrain['name']),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedTerrain = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a terrain';
        }
        return null;
      },
    );
  }
}
