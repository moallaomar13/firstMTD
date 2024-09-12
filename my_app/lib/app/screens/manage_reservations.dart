import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/constant/linkapi.dart'; // Adjust with your API links

class ManageReservations extends StatefulWidget {
  const ManageReservations({super.key});

  @override
  _ManageReservationsState createState() => _ManageReservationsState();
}

class _ManageReservationsState extends State<ManageReservations> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _reservations = [];
  Map<String, String> _terrainNames = {}; // Holds terrain names by terrain ID
  Map<int, String> _clientNames = {}; // Holds client names by user ID
  Map<int, Map<String, dynamic>> _timeslotDetails = {}; // Holds a single timeslot by reservation ID
  List<int> _adminTerrains = []; // Holds terrains owned by the admin

  @override
  void initState() {
    super.initState();
    _initializeData(); // Initialize data fetching
  }

  Future<void> _initializeData() async {
    await _fetchAdminTerrains();
    await _fetchReservations();
  }

  // Fetch Admin's Terrains
  Future<void> _fetchAdminTerrains() async {
    print('-------------------------------------------------------------------------------');
    try {
      String? adminId = await _storage.read(key: 'userId');
      if (adminId != null) {
        String terrainsUrl = '${ApiLinks.readTerrain}?owner_id=$adminId';
        print('Fetching terrains from: $terrainsUrl'); // Log URL
        var terrainsResponse = await http.get(Uri.parse(terrainsUrl));
        print('Terrains response status: ${terrainsResponse.statusCode}'); // Log status code

        if (terrainsResponse.statusCode == 200) {
          var terrainsResponseBody = jsonDecode(terrainsResponse.body);
          if (terrainsResponseBody["status"] == "success") {
            setState(() {
              _adminTerrains = List<int>.from(
                terrainsResponseBody['data'].map((terrain) => terrain['id'] as int),
              );
            });
          } else {
            _showErrorSnackbar('Failed to load terrains');
          }
        } else {
          _showErrorSnackbar('Error: ${terrainsResponse.statusCode}');
        }
      } else {
        _showErrorSnackbar('Admin ID not found.');
      }
      print('-------------------------------------------------------------------------------');
    } catch (e) {
      _showErrorSnackbar('Error fetching terrains: $e');
    }
  }

  // Fetch Reservations
  Future<void> _fetchReservations() async {
    print('-------------------------------------------------------------------------------');
    try {
      String reservationsUrl = ApiLinks.readReservation;
      print('Fetching reservations from: $reservationsUrl'); // Log URL
      var reservationsResponse = await http.get(Uri.parse(reservationsUrl));
      print('Reservations response status: ${reservationsResponse.statusCode}'); // Log status code
      print('Reservations response body: ${reservationsResponse.body}'); // Log response body

      if (reservationsResponse.statusCode == 200) {
        var reservationsResponseBody = jsonDecode(reservationsResponse.body);

        if (reservationsResponseBody["status"] == "success") {
          setState(() {
            _reservations = List<Map<String, dynamic>>.from(
              reservationsResponseBody['data'].where(
                (reservation) => _adminTerrains.contains(reservation['terrain_id']),
              ),
            );
          });
          // Fetch additional details (terrain names, client names, timeslots)
          await _fetchTerrainNames();
          await _fetchClientNames();
          await _fetchTimeslotDetails();
        } else {
          _showErrorSnackbar('Failed to load reservations');
        }
      } else {
        _showErrorSnackbar('Error: ${reservationsResponse.statusCode}');
      }
      print('-------------------------------------------------------------------------------');
    } catch (e) {
      _showErrorSnackbar('Error fetching reservations: $e');
    }
  }

  // Fetch Terrain Names
  Future<void> _fetchTerrainNames() async {
    print('-------------------------------------------------------------------------------');
    try {
      Set<int> terrainIds = _reservations.map((res) => res['terrain_id'] as int).toSet();
      for (int terrainId in terrainIds) {
        String terrainUrl = '${ApiLinks.readTerrain}?id=$terrainId';
        print('Fetching terrain from: $terrainUrl'); // Log URL
        var terrainResponse = await http.get(Uri.parse(terrainUrl));
        print('Terrain response status: ${terrainResponse.statusCode}'); // Log status code

        if (terrainResponse.statusCode == 200) {
          var terrainResponseBody = jsonDecode(terrainResponse.body);
          if (terrainResponseBody["status"] == "success") {
            var terrainData = terrainResponseBody['data'];
            setState(() {
              _terrainNames[terrainId.toString()] = terrainData['name'] ?? 'Unknown';
            });
          }
        }
      }
      print('-------------------------------------------------------------------------------');
    } catch (e) {
      print('Error fetching terrain names: $e');
    }
  }

  // Fetch Client Names
  Future<void> _fetchClientNames() async {
    print('-------------------------------------------------------------------------------');
    try {
      Set<int> userIds = _reservations.map((res) => res['user_id'] as int).toSet();
      for (int userId in userIds) {
        String userUrl = '${ApiLinks.readUser}?id=$userId';
        print('Fetching user from: $userUrl'); // Log URL
        var userResponse = await http.get(Uri.parse(userUrl));
        print('User response status: ${userResponse.statusCode}'); // Log status code
        print('User response body: ${userResponse.body}'); // Log response body

        if (userResponse.statusCode == 200) {
          var userResponseBody = jsonDecode(userResponse.body);
          if (userResponseBody["status"] == "success") {
            var userData = userResponseBody['data'];
            setState(() {
              _clientNames[userId] = userData['username'] ?? 'Unknown';
            });
          }
        }
      }
      print('-------------------------------------------------------------------------------');
    } catch (e) {
      print('Error fetching client names: $e');
    }
  }

  // Fetch Timeslot Details (filtered by reservation_id)
  Future<void> _fetchTimeslotDetails() async {
    print('-------------------------------------------------------------------------------');
    try {
      for (var reservation in _reservations) {
        int reservationId = reservation['id'];
        if (!_timeslotDetails.containsKey(reservationId)) {
          String timeslotUrl = '${ApiLinks.readTimeslot}?reservation_id=$reservationId';
          print('Fetching timeslot from: $timeslotUrl'); // Log URL
          var timeslotResponse = await http.get(Uri.parse(timeslotUrl));
          print('Timeslot response status: ${timeslotResponse.statusCode}'); // Log status code
          print('Timeslot response body: ${timeslotResponse.body}'); // Log response body

          if (timeslotResponse.statusCode == 200) {
            var timeslotResponseBody = jsonDecode(timeslotResponse.body);
            if (timeslotResponseBody["status"] == "success") {
              var timeslotData = timeslotResponseBody['data'];
              setState(() {
                _timeslotDetails[reservationId] = timeslotData.isNotEmpty
                    ? timeslotData[0] // Only take the first timeslot for the reservation
                    : {};
              });
            }
          }
        }
      }
      print('-------------------------------------------------------------------------------');
    } catch (e) {
      print('Error fetching timeslot details: $e');
    }
  }

  // Confirm or Decline Reservation
  Future<void> _updateReservationConfirmation(int reservationId, bool isConfirmed) async {
    print('-------------------------------------------------------------------------------');
    try {
      final payload = {
        'id': reservationId,
        'is_confirmed': isConfirmed ? 1 : 0,
      };
      print('Payload for update reservation: ${jsonEncode(payload)}'); // Log payload

      final response = await http.put(
        Uri.parse('${ApiLinks.updatereservationTimeslot}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      print('Update reservation response status: ${response.statusCode}'); // Log status code
      print('Update reservation response body: ${response.body}'); // Log response body

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "success") {
          setState(() {
            _reservations = _reservations.map((reservation) {
              if (reservation['id'] == reservationId) {
                return {...reservation, 'is_confirmed': isConfirmed ? 1 : 0};
              }
              return reservation;
            }).toList();
          });
          await _updateTimeslotConfirmation(reservationId, isConfirmed ? 1 : 0);
        } else {
          _showErrorSnackbar('Failed to update reservation: ${responseBody["message"]}');
        }
      } else {
        _showErrorSnackbar('Error: ${response.statusCode}');
      }
      print('-------------------------------------------------------------------------------');
    } catch (e) {
      _showErrorSnackbar('Error updating reservation: $e');
    }
  }

  // Update reservation_timeslot table
  Future<void> _updateTimeslotConfirmation(int reservationId, int isConfirmed) async {
    print('-------------------------------------------------------------------------------');
    try {
      final response = await http.put(
        Uri.parse('${ApiLinks.updatereservationTimeslot}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': reservationId,
          'is_confirmed': isConfirmed,
        }),
      );
      print('Update timeslot response status: ${response.statusCode}'); // Log status code
      print('Update timeslot response body: ${response.body}'); // Log response body

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "success") {
          _showErrorSnackbar('Reservation confirmed/declined successfully');
        } else {
          _showErrorSnackbar('Failed to update timeslot confirmation');
        }
      } else {
        _showErrorSnackbar('Error: ${response.statusCode}');
      }
      print('-------------------------------------------------------------------------------');
    } catch (e) {
      _showErrorSnackbar('Error updating timeslot confirmation: $e');
    }
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color.fromARGB(255, 54, 114, 244),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Reservations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          var reservation = _reservations[index];
          int terrainId = reservation['terrain_id'];
          int userId = reservation['user_id'];
          String reservationTime = reservation['created_at'] ?? 'Unknown';
          String terrainName = _terrainNames[terrainId.toString()] ?? 'Unknown Terrain';
          String clientName = _clientNames[userId] ?? 'Unknown Client';

          var timeslot = _timeslotDetails[reservation['id']];
          String timeslotInfo = timeslot != null
              ? '${timeslot['start_time']} - ${timeslot['end_time']}'
              : 'No timeslot info';

          // Determine background color based on reservation confirmation status
           Color  backgroundColor = reservation['is_confirmed'] == 1
              ? Colors.green[100]!
              : reservation['is_confirmed'] == 0
                  ? Colors.red[100]!
                  : Colors.white;

          return Container(
            color: backgroundColor,
            child: ListTile(
              title: Text('$clientName - $terrainName'),
              subtitle: Text('$reservationTime\nTimeslot: $timeslotInfo'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => _updateReservationConfirmation(reservation['id'], true),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _updateReservationConfirmation(reservation['id'], false),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
