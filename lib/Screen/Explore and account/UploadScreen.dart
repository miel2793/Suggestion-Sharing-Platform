import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'Servies/upload_suggestion_service.dart';

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
        const SnackBar(
          content: Text('Please select a file to upload.'),
          backgroundColor: Colors.orange,
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
        const SnackBar(
          content: Text('Suggestion uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
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
        color: const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF5C2D91), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text(
          'Upload Suggestion',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── File Picker ──
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _pickedFile != null
                          ? const Color(0xFF5C2D91)
                          : Colors.grey.shade300,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _pickedFile != null
                            ? Icons.check_circle
                            : Icons.cloud_upload_outlined,
                        color: _pickedFile != null
                            ? Colors.green
                            : const Color(0xFF5C2D91),
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pickedFile != null
                            ? _pickedFile!.name
                            : 'Tap to select a file',
                        style: TextStyle(
                          color: _pickedFile != null
                              ? Colors.black87
                              : Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_pickedFile != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                      if (_pickedFile == null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'PDF, JPG, PNG, DOC',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Form Fields ──
              _buildInputField(
                controller: _courseCodeController,
                label: 'Course Code (e.g. SWE 300)',
                validator: (v) => v!.isEmpty ? 'Course code required' : null,
              ),
              const SizedBox(height: 14),

              _buildInputField(
                controller: _courseNameController,
                label: 'Course Name',
                validator: (v) => v!.isEmpty ? 'Course name required' : null,
              ),
              const SizedBox(height: 14),

              _buildInputField(
                controller: _deptController,
                label: 'Department (e.g. CSE)',
                validator: (v) => v!.isEmpty ? 'Department required' : null,
              ),
              const SizedBox(height: 14),

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
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _sectionController,
                      label: 'Section',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Exam Type Dropdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedExamType,
                  decoration: const InputDecoration(
                    labelText: 'Exam Type',
                    labelStyle: TextStyle(color: Color(0xFF5C2D91), fontSize: 14),
                    border: InputBorder.none,
                  ),
                  dropdownColor: const Color(0xFFEDE9FF),
                  items: _examTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedExamType = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 14),

              _buildInputField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Description required' : null,
              ),

              const SizedBox(height: 28),

              // ── Upload Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleUpload,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.upload, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Uploading...' : 'Upload Suggestion',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C2D91),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
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
