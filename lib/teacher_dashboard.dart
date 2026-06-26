import 'package:flutter/material.dart';
import 'presentation_screen.dart'; 
import 'student_list_screen.dart'; 

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final Color primaryPurple = const Color(0xFF4527A0);
  final Color secondaryBlue = const Color(0xFF1976D2);
  
  double totalMarks = 0;
  int clickCount = 0;
  double average = 0;

  void _addMarks(int value) {
    setState(() {
      totalMarks += value;
      clickCount++;
      average = totalMarks / clickCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("TEACHER PORTAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryPurple, secondaryBlue])),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Student Search UI
            const Text("Student Search", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter Student Email...",
                prefixIcon: Icon(Icons.person_search, color: primaryPurple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            
            const SizedBox(height: 25),

            // 2. Smart Evaluation
            _buildSectionCard("SMART EVALUATION", [
              const Text("Select Marks (1-10):", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(10, (index) => _marksButton(index + 1)),
              ),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statInfo("Total Points", totalMarks.toStringAsFixed(1)),
                  _statInfo("Avg Score", average.toStringAsFixed(2)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() { totalMarks = 0; average = 0; clickCount = 0; }),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reset"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Score ${average.toStringAsFixed(2)} Submitted!"), backgroundColor: Colors.green)
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    ),
                  ),
                ],
              )
            ]),

            const SizedBox(height: 25),

            // 3. Presentation Tools (FIXED: Const removed from Navigation)
            const Text("Presentation Tools", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _toolIcon(Icons.camera_alt, "Camera", Colors.blue, () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => PresentationScreen())); 
                }),
                _toolIcon(Icons.picture_as_pdf, "PDF View", Colors.red, () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => PresentationScreen()));
                }),
                _toolIcon(Icons.folder, "Files", Colors.orange, () {}),
                _toolIcon(Icons.language, "Google", Colors.green, () {}),
              ],
            ),

            const SizedBox(height: 30),
            
            // 4. Academic Records (FIXED: Const removed from Navigation)
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentListScreen()));
              },
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.table_chart, color: Colors.white),
                    SizedBox(width: 10),
                    Text("View Academic Records", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _marksButton(int value) {
    return ElevatedButton(
      onPressed: () => _addMarks(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple.withOpacity(0.1),
        foregroundColor: primaryPurple,
        elevation: 0,
        minimumSize: const Size(50, 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text("$value", style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _statInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: secondaryBlue)),
      ],
    );
  }

  Widget _toolIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}