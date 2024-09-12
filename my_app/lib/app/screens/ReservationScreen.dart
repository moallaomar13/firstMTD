import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/app/screens/browse_stadiums.dart';
import 'package:my_app/constant/linkapi.dart'; // Import your API links

class ReservationScreen extends StatefulWidget {
  final Stadium stadium;

  const ReservationScreen({super.key, required this.stadium});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime now = DateTime.now();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isReserving = false;
  String _userId = '';
  Stadium? _stadiumDetails;
  List<Map<String, dynamic>> _timeslots = [];
  int? _selectedTimeslotId;


  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchStadiumDetails();
    _fetchTimeslots();
  }

  Future<void> _loadUserId() async {
    print('Loading user ID...');
    _userId = await _storage.read(key: 'userId') ?? '';
    print('User ID loaded: $_userId');
  }

  Future<void> _fetchStadiumDetails() async {
    print('Fetching stadium details for ID: ${widget.stadium.id}');
    try {
      final response = await http.get(
        Uri.parse('${ApiLinks.readTerrain}?id=${widget.stadium.id}'),
      );

      print('Stadium details response status: ${response.statusCode}');
  

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          final details = responseBody['data'];
          setState(() {
            _stadiumDetails = Stadium.fromJson(details);
          });
        } else {
          throw Exception('Failed to load stadium details');
        }
      } else {
        throw Exception('Failed to load stadium details');
      }
    } catch (e) {
      print('Error fetching stadium details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    
  }

  Future<void> _fetchTimeslots() async {
    print('Fetching timeslots for terrain ID: ${widget.stadium.id}');
    try {
      final response = await http.get(
        Uri.parse('${ApiLinks.readTimeslot}?terrain_id=${widget.stadium.id}'),
      );

      print('Timeslots response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          final timeslotData = responseBody['data'] as List<dynamic>;
          setState(() {
            _timeslots = timeslotData.map((timeslot) {
              return {
                'id': timeslot['id'],
                'display': '${timeslot['start_time']} - ${timeslot['end_time']}'
              };
            }).toList();
          });
          print("if 1 correct");
        } else {
          throw Exception('Failed to load timeslots');
        }
      } else {
        throw Exception('Failed to load timeslots');
      }
    } catch (e) {
      print('Error fetching timeslots: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _reserveStadium() async {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    if (_selectedTimeslotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a timeslot')),
      );
      return;
    }

    print('Reserving stadium with ID: ${widget.stadium.id}');
    print('Selected timeslot ID: $_selectedTimeslotId');
    setState(() {
      _isReserving = true;
    });

   try {
      // Create reservation
      final reservationResponse = await http.post(
        Uri.parse(ApiLinks.createReservation),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'terrain_id': widget.stadium.id,
          'user_id': _userId,
          'reservation_time': ""
        }),
      );

      print('Reservation response status: ${reservationResponse.statusCode}');
      print('Response body: ${reservationResponse.body}');

      if (reservationResponse.statusCode == 200) {
        final reservationResponseBody = jsonDecode(reservationResponse.body);
        if (reservationResponseBody['status'] == 'success') {
          final reservationId = reservationResponseBody['data']['id'];
          print("reservationId:  $reservationId");

          // Create reservation_timeslot entry
          final reservationTimeslotResponse = await http.post(
            Uri.parse(ApiLinks.createreservationTimeslot),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'reservation_id': reservationId,
              'timeslot_id': _selectedTimeslotId,
              'is_confirmed':
                  false, // Set to false initially or based on your requirement
            }),
          );

          print(
              'Reservation timeslot response status: ${reservationTimeslotResponse.statusCode}');
          print('Response body: ${reservationTimeslotResponse.body}');

          if (reservationResponseBody['status'] == 'success') {
            final reservationData = reservationResponseBody['data'];
            if (reservationData != null && reservationData['id'] != null) {
              final reservationId = reservationData['id'];

              // Proceed with creating reservation_timeslot
              final reservationTimeslotResponse = await http.post(
                Uri.parse(ApiLinks.createreservationTimeslot),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'reservation_id': reservationId,
                  'timeslot_id': _selectedTimeslotId,
                  'is_confirmed':
                      false, // Set to false initially or based on your requirement
                }),
              );

              print(
                  'Reservation timeslot response status: ${reservationTimeslotResponse.statusCode}');
              print('Response body: ${reservationTimeslotResponse.body}');

              if (reservationTimeslotResponse.statusCode == 200) {
                final reservationTimeslotResponseBody =
                    jsonDecode(reservationTimeslotResponse.body);
                if (reservationTimeslotResponseBody['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reservation successful!')),
                  );
                  Navigator.of(context)
                      .pop(); // Go back to the previous screen after successful reservation
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Error updating reservation timeslot: ${reservationTimeslotResponseBody["message"]}')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Error: ${reservationTimeslotResponse.statusCode}')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reservation ID not found in response')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Error: ${reservationResponseBody["message"]}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: ${reservationResponseBody["message"]}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${reservationResponse.statusCode}')),
        );
      }
  } catch (e) {
      print('Error making reservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
   }finally {
      setState(() {
        _isReserving = false;
      }
      );
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve ${widget.stadium.name}'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _stadiumDetails != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Stadium: ${_stadiumDetails!.name}',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text('Location: ${_stadiumDetails!.location}'),
                      const SizedBox(height: 10),
                      _stadiumDetails!.imageUrl.isNotEmpty
                          ? Image.memory(
                              base64Decode(
                                  _stadiumDetails!.imageUrl.split(',').last),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported, size: 200),
                      const SizedBox(height: 20),
                      Text('Select Timeslot:'),
                      DropdownButton<int>(
                        value: _selectedTimeslotId,
                        hint: const Text('Choose a timeslot'),
                        items: _timeslots.map((timeslot) {
                          return DropdownMenuItem<int>(
                            value: timeslot['id'],
                            child: Text(timeslot['display']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTimeslotId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _reserveStadium,
                        child: _isReserving
                            ? const CircularProgressIndicator()
                            : const Text('Confirm Reservation'),
                      ),
                    ],
                  )
                : const Text('Error loading stadium details'),
      ),
    );
  }
}
