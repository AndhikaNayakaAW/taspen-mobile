// lib/widgets/custom_bottom_app_bar.dart
import 'package:flutter/material.dart';
import '../screens/duty_spt_screen.dart';
import '../screens/main_screen.dart';
import '../screens/paidleave_cuti_screen.dart';

class CustomBottomAppBar extends StatelessWidget {
  final bool showBackButton;

  const CustomBottomAppBar({
    Key? key,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if the current route can be popped
    bool canPop = Navigator.of(context).canPop();

    return BottomAppBar(
      color: Colors.teal,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          // Distribute space evenly
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Left Side: Back Button and Duty (SPT)
            Row(
              children: [
                if (showBackButton && canPop)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    tooltip: "Back",
                  ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  DutySPTScreen(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.assignment,
                        color: Colors.white,
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Duty (SPT)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Center: Home Button
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  MainScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Right Side: Paid Leave (Cuti)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaidLeaveCutiScreen(),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.beach_access, // Use an appropriate icon
                    color: Colors.white,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Paid Leave (CUTI)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
