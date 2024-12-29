// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_app_bar.dart'; // Import the CustomBottomAppBar
import 'duty_spt_screen.dart';
import 'paidleave_cuti_screen.dart';
import 'create_duty_form.dart'; // Ensure this is imported for navigation

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // You can use a LayoutBuilder to determine screen size and adapt UI accordingly
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text(
            "Main Screen",
            style: TextStyle(color: Colors.white), // Set the text color to white
          ),
          backgroundColor: Colors.teal, // Set the AppBar background color to teal
        ),
      ),
      // Removed the Drawer to eliminate the hamburger menu
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop/Tablet: Display sidebar alongside content
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar
                  SizedBox(
                    width: 250,
                    child: SingleChildScrollView(
                      child: Container(
                        color: const Color(0xFFf8f9fa),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Create Duty Form Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateDutyForm(duties: []),
                                  ),
                                ).then((_) {
                                  // Handle any updates after returning from the form
                                });
                              },
                              child: const Text("Create Duty Form"),
                            ),
                            const SizedBox(height: 20),
                            // Additional Sidebar Items (if any)
                            const Text(
                              "Navigation",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            ListTile(
                              leading:
                                  const Icon(Icons.assignment_outlined, color: Colors.teal),
                              title: const Text('Duty (SPT)'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const DutySPTScreen()),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.beach_access, color: Colors.teal),
                              title: const Text('Paid Leave (Cuti)'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const PaidLeaveCutiScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Announcement Section
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "📢 Announcement",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                          ),
                                          child: const Text("Link Absensi Kehadiran"),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                          ),
                                          child: const Text("Link Update Data Keluarga Tertunjang"),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text("Jabatan anda saat ini: APPLICATION STAFF"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Special Moments Section
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "❤️ Our Special Moment",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            columns: const [
                                              DataColumn(label: Text('NIK')),
                                              DataColumn(label: Text('NAMA')),
                                              DataColumn(label: Text('JABATAN')),
                                              DataColumn(label: Text('UNIT KERJA')),
                                            ],
                                            rows: const [
                                              DataRow(cells: [
                                                DataCell(Text('3149')),
                                                DataCell(Text('DIAN SUKMANTO PUTRA')),
                                                DataCell(Text('STAF DIR.DIPERBANTUKAN')),
                                                DataCell(Text('DIREKTORAT UTAMA')),
                                              ]),
                                              DataRow(cells: [
                                                DataCell(Text('3190')),
                                                DataCell(Text('DEWI ISMAYA')),
                                                DataCell(Text('SERVICE STAFF YOGYAKARTA')),
                                                DataCell(Text('KANTOR CABANG YOGYAKARTA')),
                                              ]),
                                              DataRow(cells: [
                                                DataCell(Text('3173')),
                                                DataCell(Text('DESRI HARIANSYAH')),
                                                DataCell(Text('FINANCE ADMINISTRATION STAFF PALEMBANG')),
                                                DataCell(Text('KANTOR CABANG PALEMBANG')),
                                              ]),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // To-Do List and Forum Discussion
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "📝 My To-Do List",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text("No tasks available"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "💬 Latest Forum Discussion",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ListView(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          children: const [
                                            Text("SAP by LINA FEBRIANI"),
                                            Text("SAP by DINI NUROHMANDANI"),
                                            Text("SAP by MUHAMMAD YUSUF"),
                                            Text("Perlu adanya tambahan aplikasi... by JAFAR RAJAB"),
                                            Text("e-Office Problem by FAHRI"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              );
              } else {
                // Mobile: Single column layout without sidebar
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Announcement Section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "📢 Announcement",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                                child: const Text("Link Absensi Kehadiran"),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                                child: const Text("Link Update Data Keluarga Tertunjang"),
                              ),
                              const SizedBox(height: 10),
                              const Text("Jabatan anda saat ini: APPLICATION STAFF"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Special Moments Section
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "❤️ Our Special Moment",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('NIK')),
                                    DataColumn(label: Text('NAMA')),
                                    DataColumn(label: Text('JABATAN')),
                                    DataColumn(label: Text('UNIT KERJA')),
                                  ],
                                  rows: const [
                                    DataRow(cells: [
                                      DataCell(Text('3149')),
                                      DataCell(Text('DIAN SUKMANTO PUTRA')),
                                      DataCell(Text('STAF DIR.DIPERBANTUKAN')),
                                      DataCell(Text('DIREKTORAT UTAMA')),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('3190')),
                                      DataCell(Text('DEWI ISMAYA')),
                                      DataCell(Text('SERVICE STAFF YOGYAKARTA')),
                                      DataCell(Text('KANTOR CABANG YOGYAKARTA')),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('3173')),
                                      DataCell(Text('DESRI HARIANSYAH')),
                                      DataCell(Text('FINANCE ADMINISTRATION STAFF PALEMBANG')),
                                      DataCell(Text('KANTOR CABANG PALEMBANG')),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // To-Do List and Forum Discussion
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "📝 My To-Do List",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text("No tasks available"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "💬 Latest Forum Discussion",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: const [
                                  Text("SAP by LINA FEBRIANI"),
                                  Text("SAP by DINI NUROHMANDANI"),
                                  Text("SAP by MUHAMMAD YUSUF"),
                                  Text("Perlu adanya tambahan aplikasi... by JAFAR RAJAB"),
                                  Text("e-Office Problem by FAHRI"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
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
}
