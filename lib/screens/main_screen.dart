// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Ensure this is imported
// Import your other screens here if needed
// e.g., import 'profile_screen.dart'; etc.

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to determine screen size and adapt UI accordingly
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PT TASPEN (Persero)',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Desktop/Tablet: Optionally, you can keep a sidebar or other layout
            // For simplicity, we'll display the HomePage layout
            return _buildHomePage(context, isLargeScreen: true);
          } else {
            // Mobile: Single column layout
            return _buildHomePage(context, isLargeScreen: false);
          }
        },
      ),
      // Add the CustomBottomAppBar only for mobile screens
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 600) {
            // Mobile Screen: Show Bottom App Bar
            return const CustomBottomAppBar();
          } else {
            // Large Screen: No Bottom App Bar
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildHomePage(BuildContext context, {required bool isLargeScreen}) {
    // You can adjust the layout based on screen size if needed
    return Column(
      children: [
        // User Information Section
        Container(
          color: Colors.green[700],
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Andhika Nayaka',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Application Staff'),
                  Text('Divisi Teknologi Informasi'),
                ],
              ),
            ],
          ),
        ),
        // Menu Grid
        Expanded(
          child: GridView.count(
            crossAxisCount: isLargeScreen ? 4 : 3, // Adjust for responsiveness
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.all(16),
            children: [
              _buildMenuItem(context, Icons.person, 'Profil', ProfileScreen()),
              _buildMenuItem(context, Icons.fingerprint, 'Presensi', AttendanceScreen()),
              _buildMenuItem(context, Icons.attach_money, 'Slip Gaji', SalarySlipScreen()),
              // Add more menu items as needed
            ],
          ),
        ),
        // Logout Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              // Implement your logout functionality here
              _showLogoutConfirmation(context);
            },
            child: const Center(
              child: Text(
                'Log Out',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
        // Footer
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: const Text(
            'Powered by: PT TASPEN (Persero)',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, Widget targetScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.black),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Log Out'),
              onPressed: () {
                // Implement your logout logic here
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to login screen or perform other actions
              },
            ),
          ],
        );
      },
    );
  }
}

// Placeholder Screens for Navigation
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your Profile Screen
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your Attendance Screen
    return Scaffold(
      appBar: AppBar(title: const Text('Presensi')),
      body: const Center(child: Text('Attendance Screen')),
    );
  }
}

class SalarySlipScreen extends StatelessWidget {
  const SalarySlipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your Salary Slip Screen
    return Scaffold(
      appBar: AppBar(title: const Text('Slip Gaji')),
      body: const Center(child: Text('Salary Slip Screen')),
    );
  }
}
