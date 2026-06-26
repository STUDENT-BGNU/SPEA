import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarksEntryPage extends StatefulWidget {
  const MarksEntryPage({super.key}); // Added Key for best practice

  @override
  _MarksEntryPageState createState() => _MarksEntryPageState();
}

class _MarksEntryPageState extends State<MarksEntryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _deliveryController = TextEditingController();
  final TextEditingController _qnaController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedDept;
  final List<String> _departments = ['Computer Science', 'Information Technology', 'Software Engineering', 'Business Admin'];
  
  List<dynamic> _apiStudents = [];
  bool _isSearching = false;
  double _average = 0.0;

  // --- API Search Logic ---
  Future<void> _searchStudentApi(String query) async {
    if (query.isEmpty) {
      setState(() => _apiStudents = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final response = await http.get(Uri.parse('https://bgnu.space/api/student_data'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> allStudents = data is List ? data : data['students'] ?? [];
        setState(() {
          _apiStudents = allStudents.where((s) => 
            s['user_full_name'].toString().toLowerCase().contains(query.toLowerCase())
          ).toList();
        });
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _calculateAverage() {
    double s1 = double.tryParse(_contentController.text) ?? 0;
    double s2 = double.tryParse(_deliveryController.text) ?? 0;
    double s3 = double.tryParse(_qnaController.text) ?? 0;
    setState(() { 
      _average = (s1 + s2 + s3) / 3; 
    });
  }

  Future<void> _saveData() async {
    if (_nameController.text.isEmpty || _selectedDept == null || _subjectController.text.isEmpty) {
      _showSnackBar("Please fill all details and select a student!", Colors.red);
      return;
    }
    
    try {
      await FirebaseFirestore.instance.collection('student_marks').add({
        'studentName': _nameController.text.trim(),
        'department': _selectedDept,
        'subject': _subjectController.text.trim(),
        'contentMarks': double.tryParse(_contentController.text) ?? 0,
        'deliveryMarks': double.tryParse(_deliveryController.text) ?? 0,
        'qnaMarks': double.tryParse(_qnaController.text) ?? 0,
        'average': double.parse(_average.toStringAsFixed(2)),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _clearFields();
      _showSnackBar("Evaluation Saved Successfully!", Colors.green);
    } catch (e) {
      _showSnackBar("Error saving record: $e", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)));
  }

  void _clearFields() {
    _nameController.clear(); 
    _subjectController.clear(); 
    _contentController.clear();
    _deliveryController.clear(); 
    _qnaController.clear(); 
    _searchController.clear();
    setState(() { 
      _average = 0.0; 
      _selectedDept = null; 
      _apiStudents = []; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Student Evaluation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF004D40),
        iconTheme: const IconThemeData(color: Colors.white), // Added for back button
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Search & Select Student", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 10),
            
            _buildSectionCard(
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _searchStudentApi,
                    decoration: InputDecoration(
                      hintText: "Type student name...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF004D40)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  if (_isSearching) const LinearProgressIndicator(color: Color(0xFF004D40)),
                  if (_apiStudents.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _apiStudents.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, i) => ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.teal[50], child: const Icon(Icons.person, color: Color(0xFF004D40))),
                          title: Text(_apiStudents[i]['user_full_name']),
                          subtitle: Text(_apiStudents[i]['user_email']),
                          onTap: () {
                            setState(() {
                              _nameController.text = _apiStudents[i]['user_full_name'];
                              _apiStudents = [];
                              _searchController.clear();
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text("Grading Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 10),
            _buildSectionCard(
              child: Column(
                children: [
                  _buildTextField(_nameController, "Selected Student", Icons.person_outline, enabled: false),
                  const SizedBox(height: 15),
                  _buildDropdown(),
                  const SizedBox(height: 15),
                  _buildTextField(_subjectController, "Subject Title", Icons.subject),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildMarksField(_contentController, "Content (Max 10)")),
                      const SizedBox(width: 15),
                      Expanded(child: _buildMarksField(_deliveryController, "Delivery (Max 10)")),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildMarksField(_qnaController, "Q&A Session (Max 10)"),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            _buildAverageDisplay(),
            const SizedBox(height: 25),
            
            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40), 
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4
              ),
              child: const Text("SUBMIT EVALUATION", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: child,
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: hint, 
        prefixIcon: Icon(icon, color: const Color(0xFF004D40)), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled ? Colors.transparent : Colors.grey[100],
      ),
    );
  }

  Widget _buildMarksField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      onChanged: (v) => _calculateAverage(),
      decoration: InputDecoration(
        labelText: label, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF004D40), width: 2), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDept,
      hint: const Text("Select Department"),
      items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (v) => setState(() => _selectedDept = v),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.business, color: Color(0xFF004D40)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
      ),
    );
  }

  Widget _buildAverageDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF004D40), Color(0xFF00695C)]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CALCULATED SCORE", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
              Text("Final Average", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          Text(_average.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}