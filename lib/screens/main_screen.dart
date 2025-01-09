//lib/screens/main_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/user.dart';
import 'dart:convert';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _currentTime;
  late Timer _timer;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatTime(DateTime.now());
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _loadUserInfo();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = _formatTime(DateTime.now());
    });
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss a').format(dateTime);
  }

  Future<void> _loadUserInfo() async {
    try {
      String? userJson = await _storage.read(key: 'user');
      if (userJson != null) {
        setState(() {
          _user = User.fromJson(jsonDecode(userJson));
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  Widget _buildUserInfo() {
    if (_user == null) {
      return Container(
        color: Colors.teal[700],
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Container(
      color: Colors.teal[700],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user!.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _user!.jabatan,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                _user!.unitKerja,
                style: const TextStyle(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        onPressed: () {
          _showLogoutConfirmation(context);
        },
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Text(
        'Powered by: PT TASPEN (Persero)',
        style: TextStyle(fontSize: 14, color: Colors.grey),
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PT TASPEN (Persero)',
          style: TextStyle(color: Colors.teal),
        ),
      ),
      body: Stack(
        children: [
          _buildDecorativeBackground(),
          _buildAnotherDecorativeElement(),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isLargeScreen = constraints.maxWidth > 600;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: kToolbarHeight + 40),
                    _buildUserInfo(),
                    const SizedBox(height: 30),
                    _buildDateTimeDisplay(isLargeScreen),
                    const SizedBox(height: 30),
                    _buildLogoutButton(context),
                    const SizedBox(height: 30),
                    _buildFooter(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 600) {
            return const CustomBottomAppBar();
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      backgroundColor: Colors.teal[50],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Slip Gaji')),
      body: const Center(child: Text('Salary Slip Screen')),
    );
  }
}
