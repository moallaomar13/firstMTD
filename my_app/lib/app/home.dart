import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app/constant/linkapi.dart'; // Ensure this import matches your project's structure

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _username = '';
  String _role = '';
  final storage = const FlutterSecureStorage(); // Instance of secure storage

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final username = await storage.read(key: 'username') ?? 'Guest';
    final role = await storage.read(key: 'role') ?? 'guest'; // Default to 'guest' if no role is found

    setState(() {
      _username = username;
      _role = role;
    });

    if (role == 'admin') {
      await _fetchAndSaveAdminData();
    }
  }

  Future<void> _fetchAndSaveAdminData() async {
    try {
      final userId = await storage.read(key: 'userId');
      if (userId != null) {
        // Fetch reservations
        final reservationsResponse = await http.get(Uri.parse('${ApiLinks.readReservation}?owner_id=$userId'));
        if (reservationsResponse.statusCode == 200) {
          final reservationsData = jsonDecode(reservationsResponse.body);
          await storage.write(key: 'reservations', value: jsonEncode(reservationsData['data']));
        }

        // Fetch terrains
        final terrainsResponse = await http.get(Uri.parse('${ApiLinks.readTerrain}?owner_id=$userId'));
        if (terrainsResponse.statusCode == 200) {
          final terrainsData = jsonDecode(terrainsResponse.body);
          await storage.write(key: 'terrains', value: jsonEncode(terrainsData['data']));
        }

        // Fetch timeslots
        final timeslotsResponse = await http.get(Uri.parse('${ApiLinks.readTimeslot}?owner_id=$userId'));
        if (timeslotsResponse.statusCode == 200) {
          final timeslotsData = jsonDecode(timeslotsResponse.body);
          await storage.write(key: 'timeslots', value: jsonEncode(timeslotsData['data']));
        }
      }
    } catch (e) {
      print('Error fetching admin data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home $_role"),
        centerTitle: true,
        actions: [
          if (_role == 'admin') ...[
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.of(context).pushNamed("/manageReservations");
              },
            ),
            IconButton(
              icon: const Icon(Icons.stadium),
              onPressed: () {
                Navigator.of(context).pushNamed("/ownerDashboard");
              },
            ),
          ] else if (_role == 'client') ...[
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.of(context).pushNamed("/myReservations");
              },
            ),
            IconButton(
              icon: const Icon(Icons.stadium),
              onPressed: () {
                Navigator.of(context).pushNamed("/browseStadiums");
              },
            ),
          ],
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to Stadium Reservation App! You are logged in as: $_username",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Handle logout
                await storage.deleteAll(); // Clear all stored values
                Navigator.of(context).pushReplacementNamed("/login");
                print('You are logged out');
                print('----------------------------');
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
