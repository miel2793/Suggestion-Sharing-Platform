import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
              leading: const Icon(Icons.photo_library, color: Color(0xFF5C2D91)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _getImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF5C2D91)),
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
        const SnackBar(
          content: Text('Could not open image picker. Try restarting the app.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);


    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _isLoading = false);
    Navigator.pop(context, true);
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
        color: readOnly ? Colors.grey[200] : const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF5C2D91), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF5C2D91), size: 20),
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
          'Edit Profile',
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
              // Avatar with camera icon
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color(0xFF5C2D91),
                      backgroundImage:
                          _pickedImage != null ? FileImage(_pickedImage!) : null,
                      child: _pickedImage == null
                          ? const Icon(Icons.person, color: Colors.white, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C2D91),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap photo to change',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),

              const SizedBox(height: 28),

              // Name
              _buildField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 14),

              // Department
              _buildField(
                controller: _deptController,
                label: 'Department',
                icon: Icons.school_outlined,
                validator: (v) => v!.isEmpty ? 'Department required' : null,
              ),
              const SizedBox(height: 14),

              // Intake & Section
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

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSave,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Saving...' : 'Save Changes',
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
