import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';

class ReportFeedbackScreen extends StatefulWidget {
  const ReportFeedbackScreen({super.key});

  @override
  State<ReportFeedbackScreen> createState() => _ReportFeedbackScreenState();
}

class _ReportFeedbackScreenState extends State<ReportFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();

  String _selectedCategory = 'General Feedback';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'Content Report',
    'Others',
  ];

  // Professional solid color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorColor = Color(0xFFEF4444);
  static const _successColor = Color(0xFF10B981);
  static const _cardShadowColor = Color(0x0A000000); // black with 4% opacity

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      String backendCategory;
      switch (_selectedCategory) {
        case 'Bug Report':
          backendCategory = 'bug';
          break;
        case 'Feature Request':
          backendCategory = 'feature';
          break;
        case 'Content Report':
          backendCategory = 'content';
          break;
        case 'General Feedback':
          backendCategory = 'general';
          break;
        default:
          backendCategory = 'others';
      }

      await _feedbackService.submitFeedback(
        category: backendCategory,
        subject: _subjectController.text.trim(),
        message: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _subjectController.clear();
        _descriptionController.clear();
        _selectedCategory = 'General Feedback';
      });

      _showSnackBar(
        'Thank you! Your feedback has been submitted.',
        _successColor,
        Icons.check_circle,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      _showSnackBar(
        e.toString().replaceAll('Exception: ', ''),
        _errorColor,
        Icons.error_outline,
      );
    }
  }

  void _showSnackBar(String message, Color bgColor, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                softWrap: true,
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Report & Feedback',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Hero illustration / header
                _buildHeroSection(),
                const SizedBox(height: 24),
                // Main form card
                _buildFormCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gorgeous header with illustration-like icon and call to action
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _cardShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.feedback_outlined,
              color: _primaryColor,
              size: 56,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'We’d love to hear from you!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Report bugs, suggest features, or share your thoughts. Your feedback makes Suggest Me better for everyone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Sleek form card with refined inputs
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _cardShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_note, color: _primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category dropdown
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor, width: 1.5),
            ),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              icon: Icon(Icons.expand_more, color: _primaryColor),
              dropdownColor: _surfaceColor,
              style: const TextStyle(fontSize: 15, color: _textPrimary),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(cat), size: 20, color: _primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Subject field
          const Text(
            'Subject',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: 'Brief summary of your feedback',
              hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
              prefixIcon: Icon(Icons.subject, color: _primaryColor, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _borderColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 15, color: _textPrimary),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a subject';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Description field
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Describe your feedback, bug, or feature request in detail...',
              hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _borderColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 15, color: _textPrimary, height: 1.4),
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

          const SizedBox(height: 32),

          // Submit button (elegant, flat, with ripple)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _primaryColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
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
                  Icon(Icons.send_rounded, size: 20),
                  const SizedBox(width: 10),
                  const Text('Submit Feedback'),
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
      case 'General Feedback':
        return Icons.chat_bubble_outline;
      default:
        return Icons.more_horiz_outlined;
    }
  }
}