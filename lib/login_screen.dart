import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'firebase_options.dart'; 

// Dashboard aur Signup files (Inka hona lazmi hai)
import 'admin_dashboard.dart'; 
import 'teacher_dashboard.dart';
import 'student_dashboard.dart'; 
import 'signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint("✅ BGNU App Connected!");
  } catch (e) {
    debugPrint("❌ Firebase Error: $e");
  }
  runApp(const SPEAApp());
}

class SPEAApp extends StatelessWidget {
  const SPEAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BGNU Smart System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true, 
      ),
      home: const SmartTitlePage(), 
    );
  }
}

// --- Splash Screen (SmartTitlePage) ---
class SmartTitlePage extends StatefulWidget {
  const SmartTitlePage({super.key});

  @override
  State<SmartTitlePage> createState() => _SmartTitlePageState();
}

class _SmartTitlePageState extends State<SmartTitlePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const LoginScreen()) 
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text("BGNU EVALUATION SYSTEM", 
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// --- Login Screen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    String email = _email.text.trim();
    String password = _pass.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email aur Password likhein!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Role Check from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        // lowercase convert taake spelling ka masla na ho
        String role = doc.get('role').toString().toLowerCase().trim(); 
        debugPrint("✅ User Role: $role");

        Widget nextScreen;
        if (role == 'admin') {
          nextScreen = AdminDashboard();
        } else if (role == 'teacher') {
          nextScreen = TeacherDashboard();
        } else {
          nextScreen = StudentDashboard();
        }

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
      } else {
        _showSnackBar("Data nahi mila! Kya aapne Register kiya?", Colors.red);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Login Fail: ${e.message}", Colors.red);
    } catch (e) {
      _showSnackBar("Ghalti: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Icon(Icons.account_circle, size: 90, color: Colors.white),
                const SizedBox(height: 10),
                const Text("BGNU LOGIN", 
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                _buildTextField(_email, "Email Address", false, Icons.email),
                const SizedBox(height: 15),
                _buildTextField(_pass, "Password", true, Icons.lock),
                const SizedBox(height: 35),
                _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D47A1),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _login, 
                    child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())), 
                  child: const Text("Create New Account", style: TextStyle(color: Colors.white70))
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool obscure, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          hintText: hint, 
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}