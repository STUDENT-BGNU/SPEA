import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Ensure these files exist in your lib folder
import 'department_grid_screen.dart'; 
import 'excel_view_sheet.dart'; // Make sure file name matches exactly
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color bgnuGreen = const Color(0xFF004D40); 
  final Color bgnuGold = const Color(0xFFC5A059);

  // Slides List
  final List<String> universitySlides = [
    'https://bgnu.space/assets/slide1.jpg', 
    'https://bgnu.space/assets/slide2.jpg',
    'https://bgnu.space/assets/slide3.jpg',
  ];

  List<dynamic> apiResults = [];
  bool isSearchingApi = false;

  Future<void> _searchFromApi(String query) async {
    if (query.isEmpty) {
      setState(() => apiResults = []);
      return;
    }
    setState(() => isSearchingApi = true);
    try {
      final response = await http.get(Uri.parse('https://bgnu.space/api/student_data'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> students = data is List ? data : data['students'] ?? [];
        setState(() {
          apiResults = students.where((s) => 
            s['user_full_name'].toString().toLowerCase().contains(query.toLowerCase())
          ).toList();
        });
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      if (mounted) setState(() => isSearchingApi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BGNU PORTAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: bgnuGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: bgnuGreen),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school, size: 40, color: Color(0xFF004D40)),
              ),
              accountName: const Text("Admin Access", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text("admin@bgnu.edu.pk"),
            ),
            _drawerTile(Icons.account_tree, "BGNU Departments", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const DepartmentGridScreen()));
            }),
            _drawerTile(Icons.table_chart, "Grading Excel Sheet", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const ExcelViewScreen()));
            }),
            _drawerTile(Icons.settings, "Settings & Alerts", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsPage()));
            }),
            const Spacer(),
            const Divider(),
            _drawerTile(Icons.logout, "Logout", () {
              Navigator.pop(context); // Actual logout logic can be added here
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            
            // 1. Carousel Slider (Network Images for reliability)
            CarouselSlider(
              options: CarouselOptions(autoPlay: true, height: 180, enlargeCenterPage: true),
              items: universitySlides.map((url) => ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(url, fit: BoxFit.cover, width: double.infinity,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.grey[300], 
                    child: Icon(Icons.school, color: bgnuGreen, size: 50)
                  )),
              )).toList(),
            ),

            // 2. Stat Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  _buildStatCard("Students", "1,200", bgnuGreen),
                  const SizedBox(width: 10),
                  _buildStatCard("Faculty", "85", bgnuGold),
                ],
              ),
            ),

            // 3. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: _searchFromApi,
                decoration: InputDecoration(
                  hintText: "Search Student Name...",
                  prefixIcon: Icon(Icons.search, color: bgnuGreen),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            
            if (isSearchingApi) 
              const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
            
            // 4. Results List
            if (apiResults.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: apiResults.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: bgnuGreen, child: const Icon(Icons.person, color: Colors.white)),
                      title: Text(apiResults[index]['user_full_name'] ?? "No Name"),
                      subtitle: Text(apiResults[index]['user_email'] ?? "No Email"),
                    ),
                  );
                },
              )
            else if (!isSearchingApi && apiResults.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text("Search to find students", style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: bgnuGreen), 
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), 
      onTap: onTap
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))
          ],
        ),
      ),
    );
  }
}