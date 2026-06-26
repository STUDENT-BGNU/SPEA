import 'package:flutter/material.dart';
import 'department_screen.dart'; // Ensure is file mein 'DepartmentScreen' class ho

class DepartmentGridScreen extends StatelessWidget {
  const DepartmentGridScreen({super.key});

  // Departments ki list
  final List<Map<String, dynamic>> depts = const [
    {"name": "Computer Science", "icon": Icons.computer, "color": Colors.orange},
    {"name": "Information Tech", "icon": Icons.language, "color": Colors.blue},
    {"name": "Mathematics", "icon": Icons.calculate, "color": Colors.green},
    {"name": "BBA / Commerce", "icon": Icons.business, "color": Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Select Department", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: const Color(0xFF004D40), // BGNU Green Theme
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          crossAxisSpacing: 15, 
          mainAxisSpacing: 15,
          childAspectRatio: 1.0, 
        ),
        itemCount: depts.length,
        itemBuilder: (context, index) {
          // Data ko variables mein nikalna behtar practice hai
          final String name = depts[index]['name'];
          final IconData icon = depts[index]['icon'];
          final Color color = depts[index]['color'];

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Navigation check
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => DepartmentScreen(selectedDept: name)
                )
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1), 
                    blurRadius: 10, 
                    offset: const Offset(0, 4)
                  )
                ],
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35, // Thora bara avatar
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, size: 35, color: color),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      name, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 15, 
                        color: Color(0xFF2D3436)
                      )
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}