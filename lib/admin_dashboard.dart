import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'department_grid_screen.dart'; 
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final Color bgnuPrimary = const Color(0xFF004D40); 
  DateTime selectedDate = DateTime.now();

  // Correct Logout Function
  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text("ADMIN DASHBOARD", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: bgnuPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout, 
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildLogoSlide(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPresentationTool(),
                  const SizedBox(height: 25),
                  Text("Academic Departments", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: bgnuPrimary)),
                  const SizedBox(height: 12),
                  _buildSubjectCard("Information Technology", "Mobile App Dev", Icons.developer_mode, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DepartmentGridScreen()));
                  }),
                  _buildSubjectCard("Computer Science", "Operating Systems", Icons.settings_suggest, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DepartmentGridScreen()));
                  }),
                  const SizedBox(height: 25),
                  Text("Management Systems", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: bgnuPrimary)),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    children: [
                      _menuIcon(Icons.edit_note, "Marks Entry", Colors.orange, _openMarksEntry),
                      _menuIcon(Icons.grid_on, "Attendance Sheet", Colors.blue, _openAttendance),
                      _menuIcon(Icons.description, "Excel Records", Colors.green, _openExcelRecords),
                      _menuIcon(Icons.print, "Print Data", Colors.red, _printData),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSlide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      decoration: BoxDecoration(
        color: bgnuPrimary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40, backgroundColor: Colors.white,
            child: Icon(Icons.admin_panel_settings, size: 45, color: Color(0xFF004D40)),
          ),
          const SizedBox(height: 15),
          const Text("bgnu@gmail.com", 
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Admin Access | Session 2024-2026", 
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPresentationTool() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Presentation Mode", style: TextStyle(fontWeight: FontWeight.bold)),
              ActionChip(
                backgroundColor: bgnuPrimary.withOpacity(0.1),
                avatar: Icon(Icons.calendar_month, size: 16, color: bgnuPrimary),
                label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context, 
                    initialDate: selectedDate, 
                    firstDate: DateTime(2024), 
                    lastDate: DateTime(2026)
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _toolBtn(Icons.camera_alt, "Camera", Colors.red, () {}),
              _toolBtn(Icons.folder_open, "Files", Colors.amber, () {}),
              _toolBtn(Icons.picture_as_pdf, "PDF", Colors.blue, () {}),
              _toolBtn(Icons.language, "Google", Colors.green, 
                () => launchUrl(Uri.parse("https://google.com"))),
            ],
          )
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(String dept, String subject, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.teal.shade50, child: Icon(icon, color: bgnuPrimary)),
        title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(dept),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: bgnuPrimary),
        onTap: onTap, 
      ),
    );
  }

  Widget _menuIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1), 
              child: Icon(icon, color: color, size: 28)
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _openMarksEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => const MarksEntryModal(),
    );
  }

  void _openAttendance() {}
  void _openExcelRecords() {}
  void _printData() {}
}

class MarksEntryModal extends StatefulWidget {
  const MarksEntryModal({super.key});
  @override
  State<MarksEntryModal> createState() => _MarksEntryModalState();
}

class _MarksEntryModalState extends State<MarksEntryModal> {
  final TextEditingController _search = TextEditingController();
  List _students = [];
  bool _isSearching = false;

  Future<void> _searchApi(String q) async {
    if (q.length < 3) return;
    setState(() => _isSearching = true);
    try {
      final res = await http.get(Uri.parse('https://bgnu.space/api/student_data'));
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _students = (json.decode(res.body) as List)
              .where((s) => s['user_full_name'].toString().toLowerCase().contains(q.toLowerCase()))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
    if (mounted) setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          const Text("Student Evaluation Sheet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(
            controller: _search,
            onChanged: _searchApi,
            decoration: InputDecoration(
              hintText: "Search Name (e.g. Kashifa)",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF004D40)),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          if (_isSearching) const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: LinearProgressIndicator()),
          const SizedBox(height: 10),
          Expanded(
            child: _students.isEmpty 
              ? const Center(child: Text("Type name to find student"))
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, i) => Card(
                    child: ListTile(
                      title: Text(_students[i]['user_full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_students[i]['user_email']),
                      trailing: const Icon(Icons.edit_square, color: Colors.orange),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => EvaluationForm(studentName: _students[i]['user_full_name'])
                        ));
                      },
                    ),
                  ),
                ),
          )
        ],
      ),
    );
  }
}

class EvaluationForm extends StatefulWidget {
  final String studentName;
  const EvaluationForm({super.key, required this.studentName});

  @override
  State<EvaluationForm> createState() => _EvaluationFormState();
}

class _EvaluationFormState extends State<EvaluationForm> {
  final _mid = TextEditingController();
  final _assign = TextEditingController();
  final _quiz = TextEditingController();
  double _avg = 0.0;

  void _calc() {
    double m = double.tryParse(_mid.text) ?? 0;
    double a = double.tryParse(_assign.text) ?? 0;
    double q = double.tryParse(_quiz.text) ?? 0;
    setState(() => _avg = (m + a + q) / 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName, style: const TextStyle(fontSize: 16)), 
        backgroundColor: const Color(0xFF004D40), 
        foregroundColor: Colors.white
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _scoreInput("Mid Term (Max 30)", _mid),
            _scoreInput("Assignment (Max 10)", _assign),
            _scoreInput("Quiz (Max 10)", _quiz),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50, borderRadius: BorderRadius.circular(15), 
                border: Border.all(color: Colors.orange)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Calculated Average:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(_avg.toStringAsFixed(2), 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40), 
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              child: const Text("Save Evaluation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _scoreInput(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        onChanged: (v) => _calc(),
        decoration: InputDecoration(
          labelText: label, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
        ),
      ),
    );
  }
}