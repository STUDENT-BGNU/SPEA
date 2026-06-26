import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'presentation_screen.dart'; 
import 'settings_page.dart';
import 'main.dart'; // LoginScreen isi file mein hai

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final Color bgnuGreen = const Color(0xFF004D40); // BGNU Theme Green
  Timer? _timer;

  final List<String> universityImages = [
    "https://img.freepik.com/free-vector/university-campus-concept-illustration_114360-10118.jpg",
    "https://img.freepik.com/free-vector/education-concept-illustration_114360-8487.jpg",
    "https://img.freepik.com/free-vector/learning-concept-illustration_114360-1111.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % universityImages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        height: 400,
        child: Column(
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            CircleAvatar(radius: 45, backgroundColor: bgnuGreen, child: const Icon(Icons.person, size: 55, color: Colors.white)),
            const SizedBox(height: 15),
            Text("Kashifa Student", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: bgnuGreen)),
            const Text("kashifa@bgnu.edu.pk", style: TextStyle(color: Colors.grey)),
            const Divider(height: 30),
            _profileInfoTile(Icons.school, "Department", "Computer Science"),
            _profileInfoTile(Icons.numbers, "Roll No", "BGNU-2024-01"),
            _profileInfoTile(Icons.class_, "Semester", "4th Semester"),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: bgnuGreen, size: 22),
          const SizedBox(width: 15),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("BGNU STUDENT PORTAL", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: bgnuGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSlider(),
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Align(alignment: Alignment.centerLeft, child: Text("Quick Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSmallActionBtn(Icons.present_to_all, "Present", Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PresentationScreen()));
                  }),
                  _buildSmallActionBtn(Icons.analytics, "Marks", Colors.blue, () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Loading Academic Marks...")));
                  }),
                  _buildSmallActionBtn(Icons.person, "Profile", Colors.teal, _showProfile),
                  _buildSmallActionBtn(Icons.settings, "Settings", Colors.grey, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  }),
                ],
              ),
            ),
            _buildStatusSection(),
            const SizedBox(height: 20),
            _buildFeatureGrid(), // Additional cards for Department and Records
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: bgnuGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
          BottomNavigationBarItem(icon: Icon(Icons.contact_support), label: "Support"),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: universityImages.length,
            onPageChanged: (index) {
              setState(() { _currentPage = index; });
            },
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: NetworkImage(universityImages[index]), fit: BoxFit.cover),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(universityImages.length, (index) => 
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(4),
              width: _currentPage == index ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(color: _currentPage == index ? bgnuGreen : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            )
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Column(
          children: [
            Row(children: [Icon(Icons.auto_graph, color: bgnuGreen), const SizedBox(width: 10), const Text("Academic Performance", style: TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 15),
            _statusRow("Total Presentations", "04"),
            const SizedBox(height: 10),
            _statusRow("Latest CGPA", "3.85"),
            const SizedBox(height: 15),
            LinearProgressIndicator(value: 0.85, backgroundColor: Colors.teal[50], color: bgnuGreen),
          ],
        ),
      ),
    );
  }

  // Naya Section: Department aur Records ke Cards
  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildSquareCard("Dept Info", Icons.business, Colors.redAccent),
          const SizedBox(width: 15),
          _buildSquareCard("Past Records", Icons.history, Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildSquareCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String title, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
  }

  Widget _buildSmallActionBtn(IconData icon, String label, Color color, VoidCallback action) {
    return InkWell(
      onTap: action,
      child: Column(
        children: [
          CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}