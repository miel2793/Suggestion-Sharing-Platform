import 'package:flutter/material.dart';

class ReportFeedbackScreen extends StatefulWidget {
  const ReportFeedbackScreen({super.key});

  @override
  State<ReportFeedbackScreen> createState() => _ReportFeedbackScreenState();
}

class _ReportFeedbackScreenState extends State<ReportFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'General Feedback';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'Content Report',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // Clear form
    _subjectController.clear();
    _descriptionController.clear();
    setState(() => _selectedCategory = 'General Feedback');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Thank you! Your feedback has been submitted.'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text(
          'Report & Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5C2D91),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Header Info ──
              _buildHeaderInfo(),

              const SizedBox(height: 20),

              // ── Feedback Form ──
              _buildFormCard(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────── HEADER INFO ───────────────────
  Widget _buildHeaderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C2D91), Color(0xFF7B4DB5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C2D91).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.feedback_outlined, color: Colors.white, size: 42),
          SizedBox(height: 12),
          Text(
            'We value your feedback!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Help us improve Suggest Me by sharing your thoughts, reporting bugs, or requesting new features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── FORM CARD ───────────────────
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: Color(0xFF5C2D91), size: 24),
              SizedBox(width: 8),
              Text(
                'Submit Feedback',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C2D91),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Category Dropdown ──
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF5C2D91)),
              dropdownColor: Colors.white,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(cat),
                              size: 18,
                              color: const Color(0xFF5C2D91),
                            ),
                            const SizedBox(width: 10),
                            Text(cat),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          ),

          const SizedBox(height: 18),

          // ── Subject Field ──
          const Text(
            'Subject',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                hintText: 'Brief summary of your feedback',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon:
                    Icon(Icons.subject, color: Color(0xFF5C2D91), size: 20),
              ),
              style: const TextStyle(fontSize: 14),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 18),

          // ── Description Field ──
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                    'Describe your feedback, bug, or feature request in detail...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontSize: 14, height: 1.5),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a description';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          // ── Submit Button ──
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C2D91),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Submit Feedback',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Bug Report':
        return Icons.bug_report_outlined;
      case 'Feature Request':
        return Icons.auto_awesome_outlined;
      case 'Content Report':
        return Icons.report_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }
}
