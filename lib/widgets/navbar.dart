//lib/widgets/navbar.dart
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class Navbar extends StatelessWidget {
  final String username;
  final String position;
  final int notificationCount;

  const Navbar({
    Key? key,
    required this.username,
    required this.position,
    required this.notificationCount,
  }) : super(key: key);

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, // Clear the navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Tablet/Desktop layout
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            automaticallyImplyLeading: false, // Prevent the default drawer button
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Custom Hamburger Button and Logo
                Row(
                  children: [
                    Image.asset(
                      'assets/images/easylogo.jpg', // Replace with your logo
                      height: 40,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.teal),
                      onPressed: () {
                        Scaffold.of(context).openDrawer(); // Open the drawer
                      },
                    ),
                  ],
                ),
                // Welcome Message
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Welcome !! ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextSpan(
                        text: username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: ' | $position',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Notifications and Logout
                Row(
                  children: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.teal),
                          onPressed: () {},
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => logout(context), // Call logout function
                      child: const Text(
                        'Log out',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          // Mobile layout
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            automaticallyImplyLeading: false, // Prevent the default drawer button
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Custom Hamburger Button and Logo
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.teal),
                      onPressed: () {
                        Scaffold.of(context).openDrawer(); // Open the drawer
                      },
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/images/easylogo.jpg', // Replace with your logo
                      height: 30,
                    ),
                  ],
                ),
                // Welcome Message
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Welcome !! ',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        TextSpan(
                          text: username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: ' | $position',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Notifications and Logout
                Row(
                  children: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.teal),
                          onPressed: () {},
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => logout(context), // Call logout function
                      child: const Text(
                        'Log out',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
