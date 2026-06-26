import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  // Constant constructor error se bachne ke liye instance yahan rakha hai
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _exportToExcel(BuildContext context, String deptName, List<DocumentSnapshot> students) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Exporting ${students.length} records for $deptName..."),
        backgroundColor: const Color(0xFF004D40),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("BGNU Academic Records", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF004D40), 
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _exportToExcel(context, "All Departments", []),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // student_marks collection se data fetch ho raha hai
        stream: _firestore.collection('student_marks').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF004D40)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var docs = snapshot.data!.docs;
          Map<String, List<DocumentSnapshot>> deptData = {};

          // Data grouping logic
          for (var doc in docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String dName = data['department'] ?? 'General';
            if (!deptData.containsKey(dName)) {
              deptData[dName] = [];
            }
            deptData[dName]!.add(doc);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: deptData.keys.length,
            itemBuilder: (context, index) {
              String deptName = deptData.keys.elementAt(index);
              return _buildDeptCard(context, deptName, deptData[deptName]!);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          const Text("No student records found.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDeptCard(BuildContext context, String deptName, List<DocumentSnapshot> students) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF004D40).withOpacity(0.1),
          child: Text("${students.length}", 
            style: const TextStyle(color: Color(0xFF004D40), fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        title: Text(deptName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("Avg Performance: ${_calculateDeptAvg(students)}/10", 
          style: TextStyle(color: Colors.teal[700], fontSize: 12)),
        children: [
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ...students.map((student) {
                  var sData = student.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.person, size: 20, color: Colors.blueGrey),
                    title: Text(sData['studentName'] ?? "Unknown Student", 
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text(sData['subject'] ?? "General", style: const TextStyle(fontSize: 11)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        "${(sData['average'] ?? 0.0).toStringAsFixed(1)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  );
                }).toList(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    onPressed: () => _exportToExcel(context, deptName, students),
                    icon: const Icon(Icons.download_for_offline, size: 18),
                    label: const Text("Export CSV"),
                    style: TextButton.styleFrom(foregroundColor: Colors.green[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDeptAvg(List<DocumentSnapshot> students) {
    if (students.isEmpty) return "0.0";
    double total = 0;
    for (var s in students) {
      total += (s.data() as Map<String, dynamic>)['average'] ?? 0.0;
    }
    return (total / students.length).toStringAsFixed(1);
  }
}