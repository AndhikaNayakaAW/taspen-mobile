//lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import 'duty_spt_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Navbar(
          username: "ANDHIKA NAYAKA",
          position: "Human Capital PT TASPEN (PERSERO)",
          notificationCount: 0,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              child: Row(
                children: const [
                  Text(
                    "Request ✈️",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined, color: Colors.teal),
              title: const Text('Duty (SPT)'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DutySPTScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.beach_access, color: Colors.teal),
              title: const Text('Paid Leave (Cuti)'),
              onTap: () {
                // Add functionality for Paid Leave
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Tablet/Desktop layout
            return Center(
              child: Text(
                'Welcome to the Main Screen!',
                style: TextStyle(fontSize: 24),
              ),
            );
          } else {
            // Mobile layout
            return Center(
              child: Text(
                'Welcome to the Main Screen!',
                style: TextStyle(fontSize: 16), // Smaller font size for mobile
              ),
            );
          }
        },
      ),
    );
  }
}