import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/upload_suggestion_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uploadService = UploadSuggestionService();

  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _deptController = TextEditingController();
  final _intakeController = TextEditingController();
  final _sectionController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedExamType = 'Final';
  PlatformFile? _pickedFile;
  bool _isLoading = false;

  final List<String> _examTypes = ['Midterm', 'Final'];

  // Professional solid color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorColor = Color(0xFFEF4444);
  static const _successColor = Color(0xFF10B981);
  static const _filePickerBorder = Color(0xFFE5E7EB);
  static const _filePickerBorderSelected = Color(0xFF1E88E5);

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _deptController.dispose();
    _intakeController.dispose();
    _sectionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedFile == null || _pickedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a file to upload.'),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _uploadService.uploadSuggestion(
        filePath: _pickedFile!.path!,
        fileName: _pickedFile!.name,
        courseCode: _courseCodeController.text.trim(),
        courseName: _courseNameController.text.trim(),
        dept: _deptController.text.trim(),
        intake: _intakeController.text.trim(),
        section: _sectionController.text.trim(),
        examType: _selectedExamType,
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Suggestion uploaded successfully!'),
          backgroundColor: _successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: _errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 15, color: _textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Upload Suggestion',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File picker card (solid design)
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _pickedFile != null
                          ? _filePickerBorderSelected
                          : _filePickerBorder,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _pickedFile != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        color: _pickedFile != null ? _successColor : _primaryColor,
                        size: 56,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _pickedFile != null
                            ? _pickedFile!.name
                            : 'Tap to select a file',
                        style: TextStyle(
                          color: _pickedFile != null ? _textPrimary : _textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_pickedFile != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (_pickedFile == null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'PDF, JPG, PNG, DOC',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form fields (solid white with border)
              _buildInputField(
                controller: _courseCodeController,
                label: 'Course Code (e.g. SWE 300)',
                validator: (v) => v!.isEmpty ? 'Course code required' : null,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _courseNameController,
                label: 'Course Name',
                validator: (v) => v!.isEmpty ? 'Course name required' : null,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _deptController,
                label: 'Department (e.g. CSE)',
                validator: (v) => v!.isEmpty ? 'Department required' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _intakeController,
                      label: 'Intake',
                      type: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      controller: _sectionController,
                      label: 'Section',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Exam Type Dropdown (styled consistently)
              Container(
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor, width: 1),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedExamType,
                  decoration: const InputDecoration(
                    labelText: 'Exam Type',
                    labelStyle: TextStyle(color: _textSecondary, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  isExpanded: true,
                  dropdownColor: _surfaceColor,
                  items: _examTypes
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(color: _textPrimary)),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedExamType = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Description required' : null,
              ),

              const SizedBox(height: 32),

              // Upload Button (solid, flat)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Upload Suggestion',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}