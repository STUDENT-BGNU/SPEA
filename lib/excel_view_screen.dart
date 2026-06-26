import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExcelViewScreen extends StatefulWidget {
  final String? selectedDept;

  const ExcelViewScreen({super.key, this.selectedDept});

  @override
  _ExcelViewScreenState createState() => _ExcelViewScreenState();
}

class _ExcelViewScreenState extends State<ExcelViewScreen> {
  Uint8List? _fileBytes;
  bool _isPDF = false;
  DateTime selectedDate = DateTime.now();
  String selectedDay = DateFormat('EEEE').format(DateTime.now());

  // --- File Picker Function ---
  Future<void> _pickFile(bool isPDF) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: isPDF ? FileType.custom : FileType.image,
        allowedExtensions: isPDF ? ['pdf'] : null,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _fileBytes = result.files.single.bytes;
          _isPDF = isPDF;
        });
      }
    } catch (e) {
      debugPrint("File Picker Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.selectedDept?.toUpperCase() ?? "BGNU MANAGEMENT", 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        centerTitle: true,
        backgroundColor: const Color(0xFF004D40),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _buildDateHeader(),
            _buildViewer(),
            const SizedBox(height: 20),
            _buildRecordsTable(),
            const SizedBox(height: 25),
            _buildControlGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF004D40).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Color(0xFF004D40)),
              const SizedBox(width: 10),
              Text(selectedDay, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
            ],
          ),
          Text(DateFormat('dd MMM, yyyy').format(selectedDate), style: const TextStyle(color: Color(0xFF004D40), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildViewer() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: _fileBytes == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_drive_file_outlined, size: 70, color: Colors.grey[300]),
                const SizedBox(height: 10),
                const Text("Select PDF or Image to View Content", style: TextStyle(color: Colors.grey)),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _isPDF
                  ? SfPdfViewer.memory(_fileBytes!)
                  : InteractiveViewer(child: Image.memory(_fileBytes!, fit: BoxFit.contain)),
            ),
    );
  }

  Widget _buildRecordsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Text("LIVE STUDENT PROGRESS (${widget.selectedDept ?? 'ALL'})", 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
          ),
          child: StreamBuilder<QuerySnapshot>(
            // Note: Make sure collection name is correct (evaluations vs student_marks)
            stream: FirebaseFirestore.instance.collection('evaluations').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text("Error loading data"));
              if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No records found")));

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 25,
                  columns: const [
                    DataColumn(label: Text("NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("INTRO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("DRAW", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("CONF", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                  rows: docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['student_name'] ?? "N/A", style: const TextStyle(fontSize: 11))),
                      DataCell(Text(data['intro_marks']?.toString() ?? "0", style: const TextStyle(fontSize: 11))),
                      DataCell(Text(data['drawing_marks']?.toString() ?? "0", style: const TextStyle(fontSize: 11))),
                      DataCell(Text(data['confidence_marks']?.toString() ?? "0", style: const TextStyle(fontSize: 11))),
                    ]);
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _menuTile("Select Date", Icons.calendar_month, Colors.orange, _selectDate),
        _menuTile("Upload Image", Icons.image_search, Colors.blue, () => _pickFile(false)),
        _menuTile("Upload PDF", Icons.picture_as_pdf, Colors.red, () => _pickFile(true)),
        _menuTile("BGNU Web", Icons.language, Colors.green, () => _launchUrl("https://bgnu.edu.pk")),
      ],
    );
  }

  Widget _menuTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2024), lastDate: DateTime(2026));
    if (picked != null) setState(() { selectedDate = picked; selectedDay = DateFormat('EEEE').format(picked); });
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch URL")));
    }
  }
}