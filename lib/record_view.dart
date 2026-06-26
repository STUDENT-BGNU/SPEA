StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('student_marks')
      .where('studentEmail', isEqualTo: FirebaseAuth.instance.currentUser?.email) 
      .orderBy('timestamp', descending: true) 
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF004D40)));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return _buildNoDataUI();
    }

    var docs = snapshot.data!.docs;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var data = docs[index].data() as Map<String, dynamic>;
        
        double avg = (data['average'] ?? 0.0).toDouble();
        String subject = data['subject'] ?? "General Presentation";
        String dept = data['department'] ?? "N/A";

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.teal.withOpacity(0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildScoreIcon(avg),
            title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("Dept: $dept", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            trailing: _buildScoreTrailing(avg),
          ),
        );
      },
    );
  },
)

// --- Helper UI Methods ---

Widget _buildScoreIcon(double score) {
  Color color = score >= 7 ? Colors.green : (score >= 5 ? Colors.orange : Colors.red);
  return CircleAvatar(
    backgroundColor: color.withOpacity(0.1),
    child: Icon(Icons.assessment, color: color),
  );
}

Widget _buildScoreTrailing(double score) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(score.toStringAsFixed(1), 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF004D40))),
      const Text("Score", style: TextStyle(fontSize: 10, color: Colors.grey)),
    ],
  );
}

Widget _buildNoDataUI() {
  return Center(
    child: Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.folder_open, size: 50, color: Colors.grey[300]),
        const Text("No evaluation records found.", style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}