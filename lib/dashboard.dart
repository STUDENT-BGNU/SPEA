import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
// Niche wale imports check karein ke files ke naam sahi hain
import 'admin_dashboard.dart'; 
import 'evaluation_screen.dart';
import 'settings_screen.dart';
import 'department_grid_screen.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme color matching BGNU Green
    const Color bgnuGreen = Color(0xFF004D40);

    return Scaffold(
      appBar: AppBar(
        title: const Text("BGN UNIVERSITY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: bgnuGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo Section
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.school, size: 60, color: bgnuGreen),
              ),
            ),
            const SizedBox(height: 20),
            
            // Slides Section
            CarouselSlider(
              options: CarouselOptions(height: 180, autoPlay: true, enlargeCenterPage: true),
              items: ["Campus View", "Library", "Labs"].map((text) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00695C), Color(0xFF004D40)]),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Center(child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Icons Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                // Yahan hum naye Admin Dashboard aur Grid Screen ko connect kar rahay hain
                _buildCard(context, "ADMIN PANEL", Icons.admin_panel_settings, bgnuGreen, const AdminDashboard()),
                _buildCard(context, "DEPARTMENTS", Icons.grid_view_rounded, Colors.orange, const DepartmentGridScreen()),
                _buildCard(context, "MARKS ENTRY", Icons.assignment_turned_in, Colors.blue, const StudentEvaluationScreen()),
                _buildCard(context, "SETTINGS", Icons.settings, Colors.blueGrey, const SettingsScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () { 
        Navigator.push(context, MaterialPageRoute(builder: (context) => page)); 
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}