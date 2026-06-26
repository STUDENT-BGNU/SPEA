import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  String _selectedRole = 'Student'; 
  bool _isLoading = false;

  // Navy Blue & Royal Blue Gradient
  final LinearGradient blueGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // Pure Blue shades
  );

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _signup() async {
    // Validation
    if (_email.text.trim().isEmpty || _pass.text.trim().isEmpty || _name.text.trim().isEmpty) {
      _showSnackBar("Sab fields bharna lazmi hain!", Colors.orange);
      return;
    }
    if (_pass.text.length < 6) {
      _showSnackBar("Password kam az kam 6 characters ka ho", Colors.orange);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // 1. Firebase Auth Account Create
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(), 
          password: _pass.text.trim()
      );

      // 2. Firestore mein data save (Role selection ke sath)
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'fullName': _name.text.trim(),
        'email': _email.text.trim(),
        'role': _selectedRole.toLowerCase(), // lowercase for consistency
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Account Ban Gaya! Login karein.", Colors.green);
      
      // Thora delay taake snackbar dikhe, phir wapis login par
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } on FirebaseAuthException catch (e) {
      String errorMsg = "Ghalti hui!";
      if (e.code == 'email-already-in-use') errorMsg = "Ye email pehle se istemal mein hai.";
      if (e.code == 'invalid-email') errorMsg = "Email ka format sahi nahi hai.";
      _showSnackBar(errorMsg, Colors.red);
    } catch (e) {
      _showSnackBar("Server error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: blueGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Icon(Icons.person_add_alt_1, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text("CREATE ACCOUNT", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                  const Text("BGNU Smart System", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 40),
                  
                  _buildTextField(_name, "Pura Naam", Icons.person, false),
                  const SizedBox(height: 15),
                  _buildTextField(_email, "Email Address", Icons.email, false),
                  const SizedBox(height: 15),
                  _buildTextField(_pass, "Password", Icons.lock, true),
                  const SizedBox(height: 15),
                  
                  // Role Dropdown Blue style
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonFormField(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        border: InputBorder.none, 
                        prefixIcon: Icon(Icons.assignment_ind, color: Color(0xFF0D47A1))
                      ),
                      items: ['Admin', 'Teacher', 'Student']
                          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedRole = val as String),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55), 
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF004D40), // Dark text
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                        ),
                        onPressed: _signup, 
                        child: const Text("REGISTER NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)))
                      ),
                  
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Pehle se account hai? Login karein", style: TextStyle(color: Colors.white70)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPass) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}