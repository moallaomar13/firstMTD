import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/constant/linkapi.dart';

class MyReservations extends StatefulWidget {
  const MyReservations({super.key});

  @override
  _MyReservationsState createState() => _MyReservationsState();
}

class _MyReservationsState extends State<MyReservations> {
  final _storage = const FlutterSecureStorage(); // Instance of secure storage
  List<Reservation> _reservations = []; // List to hold reservation data
  Map<String, String> _stadiumNames = {}; // Map to hold stadium IDs and their names

  @override
  void initState() {
    super.initState();
    print('Initializing MyReservations...');
    _fetchReservations(); // Fetch reservations when the widget is initialized
    // Fetch stadiums to get their names
  }

  Future<void> _fetchReservations() async {
    try {
      print('Fetching reservations...');
      String? userId = await _storage.read(key: 'userId'); // Retrieve user ID from secure storage
      print('Retrieved User ID: $userId');

      if (userId != null) {
        String url = '${ApiLinks.readReservation}?user_id=$userId'; // API endpoint to fetch reservations for the specific user
        print('API URL: $url');
        
        var response = await http.get(Uri.parse(url)); // Make HTTP GET request to fetch reservations
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body); // Decode the response body
          print('Response body decoded: $responseBody');

          if (responseBody["status"] == "success") {
            var data = responseBody['data'];
            if (data is List) {
              setState(() {
                _reservations = List<Reservation>.from(
                  data.map((json) => Reservation.fromJson(json, _stadiumNames))
                ); // Update state with reservations data
              });
              print('Reservations successfully fetched and set.');
              _fetchStadiums(); 
            } else {
              print('Unexpected data format: $data');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unexpected data format')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load reservations: ${responseBody["message"]}')),
            );
            print('Failed to load reservations: ${responseBody["message"]}');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
          print('Error: ${response.statusCode}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID not found')),
        );
        print('User ID not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Exception caught: $e');
    }
  }

  Future<void> _fetchStadiums() async {
    try {
      print('Fetching stadiums...');
      String url = ApiLinks.readTerrain; // API endpoint to fetch all stadiums
      print('API URL: $url');
      
      var response = await http.get(Uri.parse(url)); // Make HTTP GET request to fetch stadiums
      //print('Response status: ${response.statusCode}');
     
      
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body); // Decode the response body
       

        if (responseBody["status"] == "success") {
          var data = responseBody['data'];
         
          if (data is List) {
            setState(() {
              _stadiumNames = Map.fromIterable(
                data,
                key: (item) => item['id'].toString(),
                value: (item) => item['name']
              );
            });
            print('Stadiums successfully fetched and set.');
          } else {
            print('Unexpected data format: $data');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unexpected data format')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load stadiums: ${responseBody["message"]}')),
          );
          print('Failed to load stadiums: ${responseBody["message"]}');
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
      print('Exception caught: $e');
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    try {
      print('Attempting to cancel reservation with ID: $reservationId');
      String url = '${ApiLinks.deleteReservation}?id=$reservationId'; // API endpoint to cancel reservation
      var response = await http.delete(Uri.parse(url)); // Make HTTP DELETE request to cancel reservation
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body); // Decode the response body
        print('Response body decoded: $responseBody');

        if (responseBody["status"] == "success") {
          setState(() {
            _reservations.removeWhere((reservation) => reservation.id == reservationId); // Remove reservation from list
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reservation canceled successfully')),
          );
          print('Reservation canceled successfully.');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel reservation: ${responseBody["message"]}')),
          );
          print('Failed to cancel reservation: ${responseBody["message"]}');
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
      print('Exception caught: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building MyReservations UI...');
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reservations"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Your Reservations",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final reservation = _reservations[index];
                  print('Building list item for reservation: ${reservation.id}');
                  return ListTile(
                    title: Text('Reservation ID: ${reservation.id}'),
                    subtitle: Text('Stadium: ${_stadiumNames[reservation.terrain_id] ?? 'Unknown'}\nTime: ${reservation.time}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _cancelReservation(reservation.id);
                      },
                      child: const Text("Cancel"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Reservation {
  final String id;
  final String terrain_id; // Changed to terrain_id to fetch name separately
  final String time;

  Reservation({
    required this.id,
    required this.terrain_id,
    required this.time,
  });

  factory Reservation.fromJson(Map<String, dynamic> json, Map<String, String> stadiumNames) {
    return Reservation(
      id: json['id']?.toString() ?? '', // Handle null values
      terrain_id: json['terrain_id']?.toString() ?? '', // Handle null values
      time: json['reservation_time'] ?? '', // Handle null values
    );
  }
}
