import 'package:flutter/material.dart';

class DepartmentScreen extends StatelessWidget {
  final String selectedDept;

  // Constructor: selectedDept lazmi chahiye navigation ke waqt
  const DepartmentScreen({super.key, required this.selectedDept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("$selectedDept Dashboard", 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF004D40),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Header Card
            _buildInfoCard(),
            
            const SizedBox(height: 30),
            
            const Text(
              "Department Services", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            
            const SizedBox(height: 15),

            // 2. Services List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildServiceTile(context, "Excel Marks Sheet", Icons.table_view, Colors.green, "Generate .xlsx file for $selectedDept"),
                  _buildServiceTile(context, "Student Evaluation", Icons.edit_note, Colors.orange, "Enter/Edit marks for current semester"),
                  _buildServiceTile(context, "Auto-Average System", Icons.calculate, Colors.blue, "Calculate GPA and Class Average"),
                  _buildServiceTile(context, "Presentation Marks", Icons.present_to_all, Colors.purple, "Grade students for idea presentation"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            // FIX: black24 error hal karne ke liye withOpacity use kiya
            color: Colors.black.withOpacity(0.2), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.account_balance, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 15),
          Text(
            selectedDept, 
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 5),
          const Text(
            "BGNU Academic Management System", 
            style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 0.5)
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, String title, IconData icon, Color color, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(sub, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Opening $title for $selectedDept..."),
              backgroundColor: const Color(0xFF004D40),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}