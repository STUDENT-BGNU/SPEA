import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentEvaluationScreen extends StatefulWidget {
  const StudentEvaluationScreen({super.key});

  @override
  _StudentEvaluationScreenState createState() => _StudentEvaluationScreenState();
}

class _StudentEvaluationScreenState extends State<StudentEvaluationScreen> {
  final _searchController = TextEditingController();
  final _introController = TextEditingController();
  final _drawingController = TextEditingController();
  final _confidenceController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String? selectedStudentEmail;
  String? selectedStudentName;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // Memory leaks se bachne ke liye controllers ko dispose karein
    _searchController.dispose();
    _introController.dispose();
    _drawingController.dispose();
    _confidenceController.dispose();
    super.dispose();
  }

  // --- API Search Function ---
  Future<void> _searchStudent(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final response = await http.get(Uri.parse('https://bgnu.space/api/student_data'));
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        List<dynamic> students = data is List ? data : (data['students'] ?? []);
        
        setState(() {
          _searchResults = students.where((s) => 
            s['user_full_name'].toString().toLowerCase().contains(query.toLowerCase())
          ).toList();
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    }
    if (mounted) setState(() => _isSearching = false);
  }

  // --- Save to Firebase ---
  void _submitEvaluation() async {
    if (selectedStudentName == null || _introController.text.isEmpty) {
      _showSnackBar("Pehle student select karein aur marks likhein", Colors.orange);
      return;
    }
    
    setState(() => _isSearching = true); // Using search flag as a general loader

    try {
      await _firestore.collection('evaluations').add({
        'student_name': selectedStudentName,
        'student_email': selectedStudentEmail,
        'intro_marks': double.tryParse(_introController.text) ?? 0,
        'drawing_marks': double.tryParse(_drawingController.text) ?? 0,
        'confidence_marks': double.tryParse(_confidenceController.text) ?? 0,
        'teacher_email': FirebaseAuth.instance.currentUser?.email ?? "Admin",
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSnackBar("✅ Evaluation Saved Successfully!", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Firebase Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("STUDENT EVALUATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFF004D40), 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            if (_isSearching) const LinearProgressIndicator(color: Colors.teal),
            _buildSearchResults(),
            const SizedBox(height: 25),
            if (selectedStudentName != null) _buildEvaluationForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchStudent,
        decoration: InputDecoration(
          hintText: "Type student name to search...",
          prefixIcon: const Icon(Icons.person_search, color: Color(0xFF004D40)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(top: 5),
      elevation: 4,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _searchResults.length,
          itemBuilder: (context, i) => ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFF004D40), child: Icon(Icons.person, color: Colors.white, size: 20)),
            title: Text(_searchResults[i]['user_full_name']),
            onTap: () {
              setState(() {
                selectedStudentName = _searchResults[i]['user_full_name'];
                selectedStudentEmail = _searchResults[i]['user_email'];
                _searchResults = [];
                _searchController.text = selectedStudentName!;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluationForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Evaluation for: $selectedStudentName", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF004D40))),
            const Divider(height: 30),
            _buildMarksField(_introController, "Introduction Marks", Icons.mic, Colors.blue),
            _buildMarksField(_drawingController, "Practical Skills", Icons.brush, Colors.orange),
            _buildMarksField(_confidenceController, "Confidence Level", Icons.psychology, Colors.purple),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitEvaluation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("SUBMIT EVALUATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMarksField(TextEditingController ctrl, String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: color),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}