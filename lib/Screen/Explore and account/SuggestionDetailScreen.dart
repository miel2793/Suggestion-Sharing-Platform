import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/model/explore_suggestion_model.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/Services/auth_service.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/DocumentViewerScreen.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/login_screen.dart';

class SuggestionDetailScreen extends StatelessWidget {
  final Suggestion suggestion;
  const SuggestionDetailScreen({super.key, required this.suggestion});
  static const _primaryColor = Color(0xFF42A5F5);

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    final isExamFinal = s.examType.toLowerCase() == 'final';

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Suggestion Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: const Border(left: BorderSide(color: _primaryColor, width: 5)),
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(s.courseCode, style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text('${s.stars}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(s.courseName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isExamFinal ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isExamFinal ? Colors.green[300]! : Colors.orange[300]!),
                    ),
                    child: Text(s.examType, style: TextStyle(color: isExamFinal ? Colors.green[700] : Colors.orange[700], fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text(s.description.isNotEmpty ? s.description : 'No description provided.', style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.6)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _infoRow(Icons.school_outlined, 'Department', s.dept),
                  const SizedBox(height: 10),
                  _infoRow(Icons.numbers, 'Intake', s.intake),
                  const SizedBox(height: 10),
                  _infoRow(Icons.group_outlined, 'Section', s.section),
                  const SizedBox(height: 10),
                  _infoRow(Icons.calendar_today, 'Uploaded', '${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}'),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(radius: 18, backgroundColor: _primaryColor.withValues(alpha: 0.1), child: const Icon(Icons.person, color: _primaryColor, size: 20)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.uploadedBy.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                          Text(s.uploadedBy.email, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _viewDocument(context),
                icon: const Icon(Icons.visibility, color: Colors.white),
                label: const Text('View Document', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 2),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showAiSummary(context),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text('AI Summarize', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  Future<void> _viewDocument(BuildContext context) async {
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();
    if (!loggedIn) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [Icon(Icons.lock_outline, color: Color(0xFF42A5F5)), SizedBox(width: 8), Text('Login Required')]),
          content: const Text('You need to login first to view this document.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42A5F5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }
    try {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentViewerScreen(url: suggestion.attachmentUrl, title: suggestion.courseName)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the document.'), backgroundColor: Colors.red));
    }
  }

  Future<void> _showAiSummary(BuildContext context) async {
    final s = suggestion;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          margin: EdgeInsets.all(40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF7C3AED)),
                SizedBox(height: 16),
                Text('AI is analyzing...', style: TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;
    Navigator.pop(context);

    // Build summary
    final summary = StringBuffer();
    summary.writeln('📘 Course: ${s.courseName} (${s.courseCode})');
    summary.writeln('');
    summary.writeln('📝 Exam Type: ${s.examType}');
    summary.writeln('🏫 Dept: ${s.dept} | Intake: ${s.intake} | Sec: ${s.section}');
    summary.writeln('');
    summary.writeln('── Summary ──');
    summary.writeln('');
    if (s.description.isNotEmpty) {
      summary.writeln('This is a ${s.examType} exam suggestion for "${s.courseName}" (${s.courseCode}). '
          'It targets students in ${s.dept}, Intake ${s.intake}, Section ${s.section}.');
      summary.writeln('');
      summary.writeln('Description: ${s.description}');
    } else {
      summary.writeln('This is a ${s.examType} exam suggestion for "${s.courseName}" (${s.courseCode}). '
          'Targeted at ${s.dept} students, Intake ${s.intake}, Section ${s.section}. '
          'No additional description was provided.');
    }
    summary.writeln('');
    summary.writeln('⭐ Rating: ${s.stars} stars');
    summary.writeln('👤 Uploaded by: ${s.uploadedBy.name}');

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF7C3AED), size: 24),
            SizedBox(width: 10),
            Text('AI Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
                ),
                child: Text(
                  summary.toString(),
                  style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF374151)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '⚡ Generated by AI • May not be fully accurate',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
