import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key}); // Added const constructor

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  DateTime selectedDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  String? _selectedFilePath; 

  // Google Launcher
  Future<void> _launchGoogle() async {
    final Uri url = Uri.parse('https://www.google.com');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showSnackBar("Could not launch Google", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Browser error: $e", Colors.red);
    }
  }

  // Camera Picker
  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      _showSnackBar("Photo Captured!", Colors.green);
    }
  }

  // File Picker (PDF select karne ke liye)
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], 
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
      _showSnackBar("PDF Loaded Successfully", Colors.green);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Presentation Mode", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: const Color(0xFF004D40),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildDateSection(),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: _selectedFilePath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, size: 100, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text("No PDF Document Selected", style: TextStyle(color: Colors.grey[500])),
                      Text("Tap 'Files' to upload", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SfPdfViewer.file(File(_selectedFilePath!)), 
                  ),
            ),
          ),

          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Session Date", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(DateFormat('EEEE, d MMM yyyy').format(selectedDate), 
                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
            ],
          ),
          IconButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context, 
                initialDate: selectedDate, 
                firstDate: DateTime(2020), 
                lastDate: DateTime(2030)
              );
              if (picked != null) setState(() { selectedDate = picked; });
            },
            icon: const Icon(Icons.edit_calendar, color: Color(0xFF004D40)),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toolItem(Icons.camera_alt, "Camera", Colors.redAccent, _openCamera),
          _toolItem(Icons.folder_copy, "Files", Colors.orange[800]!, _pickFile),
          _toolItem(Icons.refresh, "Reset", Colors.blueAccent, () {
            setState(() => _selectedFilePath = null);
          }),
          _toolItem(Icons.travel_explore, "Google", Colors.green, _launchGoogle),
        ],
      ),
    );
  }

  Widget _toolItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1), 
            radius: 28, 
            child: Icon(icon, color: color, size: 28)
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
        ],
      ),
    );
  }
}