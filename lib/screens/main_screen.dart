//lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import 'duty_spt_screen.dart';
import 'paidleave_cuti_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Navbar(
          username: "andhika.nayaka",
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaidLeaveCutiScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
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
                                    rows: [
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
            );
          },
        ),
      ),
    );
  }
}
