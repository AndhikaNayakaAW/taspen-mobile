// lib/screens/login_screen.dart
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Secure Storage instance
  final _storage = const FlutterSecureStorage();

  // Dummy credentials
  final String correctUsername = "andhika.nayaka";
  final String correctPassword = "Tspti1234";

  String? errorMessage;
  bool _isPasswordVisible = false;
  bool _isRememberMe = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load saved credentials if Remember Me was checked
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Basic form validation
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please enter both username and password";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    print("Attempting login with Username: $username, Password: $password");

    setState(() {
      isLoading = true;
    });

    // Simulate a network call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      if (username == correctUsername && password == correctPassword) {
        errorMessage = null;
        if (_isRememberMe) {
          _storage.write(key: 'username', value: username);
          _storage.write(key: 'password', value: password);
        } else {
          _storage.delete(key: 'username');
          _storage.delete(key: 'password');
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        errorMessage = "Invalid username or password";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Try again!')),
        );
      }
      isLoading = false;
    });
  }

  void _openForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Forgot Password"),
          content: const Text(
              "Please contact support@yourapp.com to reset your password."),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _loadSavedCredentials() async {
    String? savedUsername = await _storage.read(key: 'username');
    String? savedPassword = await _storage.read(key: 'password');

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        _isRememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the available width for the button
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = 60.0; // 30 left and 30 right
    double availableWidth = screenWidth - horizontalPadding;
    double buttonWidth = isLoading ? 50.0 : availableWidth;

    return Scaffold(
      // Use SafeArea to avoid intrusions by system UI
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logintaspen.jpg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay with blur effect for better readability
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Login Form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Card(
                  color: Colors.white.withOpacity(0.85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/easylogo.jpg',
                          height: 150, // Increased height
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Human Capital\nPT TASPEN (PERSERO)\nSilahkan Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Username Field with Icon
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            hintText: 'Username',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password Field with Icon and Toggle
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Remember Me and Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _isRememberMe,
                                  activeColor: Colors.teal,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isRememberMe = value ?? false;
                                    });
                                  },
                                ),
                                const Text(
                                  'Remember Me',
                                  style: TextStyle(color: Colors.teal),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _openForgotPasswordDialog,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.teal,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Error Message
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 10),
                        // Login Button with Animation using SizedBox and AnimatedContainer
                        SizedBox(
                          width: availableWidth,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: buttonWidth,
                            height: 50.0,
                            curve: Curves.easeInOut,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: isLoading ? null : login,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
