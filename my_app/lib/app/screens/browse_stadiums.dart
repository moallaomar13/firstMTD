import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_app/app/screens/ReservationScreen.dart';
import 'package:my_app/constant/linkapi.dart';

class BrowseStadiums extends StatefulWidget {
  const BrowseStadiums({super.key});

  @override
  _BrowseStadiumsState createState() => _BrowseStadiumsState();
}

class _BrowseStadiumsState extends State<BrowseStadiums> {
  late Future<List<Stadium>> stadiums;

  @override
  void initState() {
    super.initState();
    stadiums = fetchStadiums();
  }

  Future<List<Stadium>> fetchStadiums() async {
    print('Fetching stadiums from API: ${ApiLinks.readTerrain}');
    final response = await http.get(Uri.parse(ApiLinks.readTerrain));
    print('Received response with status code: ${response.statusCode}');

    if (response.statusCode == 200) {
     
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        print('Stadiums fetched successfully');
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Stadium.fromJson(json)).toList();
      } else {
        print('Failed to load stadiums: ${jsonResponse['message']}');
        throw Exception('Failed to load stadiums: ${jsonResponse['message']}');
      }
    } else {
      print('Failed to load stadiums with status code: ${response.statusCode}');
      throw Exception('Failed to load stadiums');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse Stadiums"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
        ),
      ),
      body: FutureBuilder<List<Stadium>>(
        future: stadiums,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No stadiums available'));
          } else {
            final stadiumList = snapshot.data!;
            return ListView.builder(
              itemCount: stadiumList.length,
              itemBuilder: (context, index) {
                final stadium = stadiumList[index];
                return ListTile(
                  leading: stadium.imageUrl.isNotEmpty
                      ? Image.memory(
                          base64Decode(stadium.imageUrl.split(',').last),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(stadium.name),
                  subtitle: Text(stadium.location),
                  trailing: ElevatedButton(
                    onPressed: () {
                      print('Navigating to reservation screen for stadium ID: ${stadium.id}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationScreen(stadium: stadium),
                        ),
                      );
                    },
                    child: const Text("Reserve"),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Stadium {
  final String id;
  final String name;
  final String location;
  final String imageUrl;

  Stadium({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
  });

  factory Stadium.fromJson(Map<String, dynamic> json) {
    return Stadium(
      id: json['id'].toString(),
      name: json['name'],
      location: json['location'],
      imageUrl: json['imageart'] ?? '', // Handle base64-encoded image here
    );
  }
}
