// lib/screens/main_screen.dart
import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Ensure this is imported
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'login_screen.dart'; // Import LoginScreen

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Updates the current time every second
  void _updateTime() {
    setState(() {
      _currentTime = _formatTime(DateTime.now());
    });
  }

  /// Formats DateTime to 'hh:mm:ss a' format
  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss a').format(dateTime);
  }

  /// Helper method to build the user's information section
  Widget _buildUserInfo() {
    return Container(
      color: Colors.teal[700],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Andhika Nayaka',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Improved readability on teal background
                ),
              ),
              Text(
                'Application Staff',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                'Divisi Teknologi Informasi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper method to build today's date and live clock display
  Widget _buildDateTimeDisplay(bool isLargeScreen) {
    String today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: Colors.teal.withOpacity(0.3),
        child: Container(
          width: isLargeScreen ? 500 : double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[50]!, Colors.teal[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Section
              Column(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 50,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    today,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Time Section
              Column(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 50,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _currentTime,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[900],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build the logout button
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Log Out',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        onPressed: () {
          // Show logout confirmation dialog
          _showLogoutConfirmation(context);
        },
      ),
    );
  }

  /// Helper method to build the footer
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: const Text(
        'Powered by: PT TASPEN (Persero)',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  /// Helper method to show logout confirmation dialog
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
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to LoginScreen and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Helper method to build decorative background
  Widget _buildDecorativeBackground() {
    return Positioned(
      top: -50,
      left: -50,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.teal[200]!.withOpacity(0.5),
              Colors.teal[100]!.withOpacity(0.0)
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  /// Helper method to build another decorative element
  Widget _buildAnotherDecorativeElement() {
    return Positioned(
      bottom: -50,
      right: -50,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.teal[200]!.withOpacity(0.5),
              Colors.teal[100]!.withOpacity(0.0)
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to determine screen size and adapt UI accordingly
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow decorative background to show behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PT TASPEN (Persero)',
          style: TextStyle(color: Colors.teal),
        ),
      ),
      body: Stack(
        children: [
          // Decorative Background Elements
          _buildDecorativeBackground(),
          _buildAnotherDecorativeElement(),
          // Main Content
          LayoutBuilder(
            builder: (context, constraints) {
              bool isLargeScreen = constraints.maxWidth > 600;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: kToolbarHeight + 40), // Spacer for AppBar and decorative elements
                    // User Information Section
                    _buildUserInfo(),
                    const SizedBox(height: 30),
                    // Today's Date and Live Clock Display
                    _buildDateTimeDisplay(isLargeScreen),
                    const SizedBox(height: 30),
                    // Logout Button
                    _buildLogoutButton(context),
                    const SizedBox(height: 30),
                    // Footer
                    _buildFooter(),
                  ],
                ),
              );
            },
          ),
        ],
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
      backgroundColor: Colors.teal[50], // Base background color
    );
  }
}

/// Placeholder Screens for Navigation
/// You can remove these if they're no longer needed

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
