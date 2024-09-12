import 'package:flutter/material.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Manage Your Stadiums",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/AddStadium");// Navigate to add/edit stadium page
              },
              child: const Text("Add Stadiums"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/managetimeslots");// Navigate to manage timeslots page
              },
              child: const Text("Manage Timeslots"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/manageReservations");
              },
              child: const Text("Manage Reservations"),
            ),
          ],
        ),
      ),
    );
  }
}
