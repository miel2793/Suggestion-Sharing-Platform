import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String dept;
  final String intake;
  final String section;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.dept,
    required this.intake,
    required this.section,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _deptController;
  late final TextEditingController _intakeController;
  late final TextEditingController _sectionController;
  bool _isLoading = false;
  File? _pickedImage;

  // Plain solid colors
  static const _primaryColor = Color(0xFF1976D2);
  static const _surfaceColor = Colors.white;
  static const _textPrimary = Color(0xFF212121);
  static const _textSecondary = Color(0xFF757575);
  static const _borderColor = Color(0xFFE0E0E0);
  static const _errorColor = Color(0xFFD32F2F);
  static const _successColor = Color(0xFF388E3C);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _deptController = TextEditingController(text: widget.dept);
    _intakeController = TextEditingController(text: widget.intake);
    _sectionController = TextEditingController(text: widget.section);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deptController.dispose();
    _intakeController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: _primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _getImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: _primaryColor),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _getImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open image picker. Try restarting the app.'),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Check image size (max 10MB)
    if (_pickedImage != null) {
      final fileSize = await _pickedImage!.length();
      if (fileSize > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image size must be less than 10 MB.'),
            backgroundColor: _errorColor,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final cookie = await authService.getToken();

      // Build FormData — only include fields that have values
      final Map<String, dynamic> formFields = {};

      final name = _nameController.text.trim();
      final dept = _deptController.text.trim();
      final intake = _intakeController.text.trim();
      final section = _sectionController.text.trim();

      if (name.isNotEmpty) formFields['name'] = name;
      if (dept.isNotEmpty) formFields['dept'] = dept;
      if (intake.isNotEmpty) formFields['intake'] = intake;
      if (section.isNotEmpty) formFields['section'] = section;

      // Attach image as 'img_url' if picked
      if (_pickedImage != null) {
        final fileName = _pickedImage!.path.split('/').last;
        formFields['img_url'] = await MultipartFile.fromFile(
          _pickedImage!.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(formFields);

      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://sdp-3-backend.vercel.app/api',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.put(
        '/auth/update-profile',
        data: formData,
        options: Options(
          headers: {
            if (cookie != null) 'Cookie': cookie,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (!mounted) return;

      final data = response.data;
      final message = data is Map && data.containsKey('message')
          ? data['message']
          : 'Profile updated successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.toString()),
          backgroundColor: _successColor,
        ),
      );

      setState(() => _isLoading = false);
      Navigator.pop(context, {
        'name': name,
        'dept': dept,
        'intake': intake,
        'section': section,
        'image': _pickedImage,
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String errorMsg = 'Failed to update profile.';
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errorMsg = data['message'];
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: _errorColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: _errorColor,
        ),
      );
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF5F5F5) : _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
        validator: validator,
        style: const TextStyle(color: _textPrimary, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: _primaryColor, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft off-white background
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
            children: [
              // Profile image section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: _primaryColor.withValues(alpha: 0.1),
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : null,
                            child: _pickedImage == null
                                ? Icon(
                              Icons.person,
                              color: _primaryColor,
                              size: 55,
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to change profile photo',
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Form card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    _buildField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _deptController,
                      label: 'Department',
                      icon: Icons.school_outlined,
                      validator: (v) => v!.isEmpty ? 'Department required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _intakeController,
                            label: 'Intake',
                            icon: Icons.numbers,
                            type: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _sectionController,
                            label: 'Section',
                            icon: Icons.group_outlined,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primaryColor.withValues(alpha: 0.5),
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
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}