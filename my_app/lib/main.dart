

import 'package:flutter/material.dart';
import 'package:my_app/app/auth/login.dart';
import 'package:my_app/app/auth/signup.dart';
import 'package:my_app/app/compoments/managetimeslot.dart';
import 'package:my_app/app/compoments/terrains/addterrains.dart';
import 'package:my_app/app/home.dart';
import 'package:my_app/app/screens/owner_dashboard.dart';
import 'package:my_app/app/screens/browse_stadiums.dart';
import 'package:my_app/app/screens/manage_reservations.dart';
import 'package:my_app/app/screens/my_reservations.dart';
import 'package:my_app/app/uploadfile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stadium Reservation App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/login",
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          // No role argument needed since Home will read from local storage
          return MaterialPageRoute(
            builder: (context) => const Home(),
          );
        }
        return null; // Return null to use default routing
      },
      routes: {
        "/login": (context) => const Login(),
        "/signup": (context) => const SignUp(),
        "/ownerDashboard": (context) => const OwnerDashboard(),
        "/AddStadium": (context) => AddStadium(),
        "/browseStadiums": (context) => const BrowseStadiums(),
        "/manageReservations": (context) => const ManageReservations(),
        "/myReservations": (context) => const MyReservations(),
        "/managetimeslots": (context) =>  ManageTimeslot(),
        "/fileupload": (context) => FileUploadPage(),

      },
    );
  }
}
