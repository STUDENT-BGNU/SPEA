import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Ensure LoginScreen file import hai

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = "English";

  // Logout Function with Firebase
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase session end karein
      if (!mounted) return;
      
      // Sab purani screens khatam karke Login par le jayein
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgnuGreen = Color(0xFF004D40);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: bgnuGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // 1. Notifications Toggle
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active, color: bgnuGreen),
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive alerts for new evaluations"),
            value: _notificationsEnabled,
            activeColor: bgnuGreen,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          const Divider(indent: 20, endIndent: 20),

          // 2. Language Selection
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blueGrey),
            title: const Text("App Language"),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(), 
              items: ["English", "Urdu", "Punjabi"].map((String lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (val) => setState(() => _selectedLanguage = val!),
            ),
          ),
          const Divider(indent: 20, endIndent: 20),

          // 3. App Info
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blueGrey),
            title: Text("Version"),
            trailing: Text("1.0.0", style: TextStyle(color: Colors.grey)),
          ),
          const Divider(indent: 20, endIndent: 20),

          // 4. Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  // Confirm Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Logout"),
        content: const Text("Kashifa, are you sure you want to logout from the BGNU portal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}