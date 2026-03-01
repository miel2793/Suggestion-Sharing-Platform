import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/Services/auth_service.dart';
import 'user_profile_model.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();

  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _authService.getProfile();
      setState(() {
        _profile = UserProfile.fromJson(data);
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5C2D91),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C2D91)),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _fetchProfile();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProfile,
                  color: const Color(0xFF5C2D91),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 24),
                        _buildUploadsSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ─────────────────── PROFILE CARD ───────────────────
  Widget _buildProfileCard() {
    final p = _profile!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          // Avatar
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF5C2D91),
            child: Icon(Icons.person, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            p.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C2D91),
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            p.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p.role.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C2D91),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Info rows
          _infoRow(Icons.school, 'Department', p.dept),
          const SizedBox(height: 10),
          _infoRow(Icons.numbers, 'Intake', p.intake),
          const SizedBox(height: 10),
          _infoRow(Icons.group, 'Section', p.section),
          const SizedBox(height: 10),
          _infoRow(Icons.upload_file, 'Total Uploads', '${p.uploads.length}'),
          const SizedBox(height: 10),
          _infoRow(Icons.calendar_today, 'Joined',
              '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5C2D91), size: 20),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ─────────────────── UPLOADS SECTION ───────────────────
  Widget _buildUploadsSection() {
    final uploads = _profile!.uploads;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Uploads',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C2D91),
          ),
        ),
        const SizedBox(height: 12),

        if (uploads.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No uploads yet',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          )
        else
          ...uploads.map((upload) => _buildUploadCard(upload)),
      ],
    );
  }

  Widget _buildUploadCard(UserUpload upload) {
    Color statusColor;
    switch (upload.status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF5C2D91), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: code + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                upload.courseCode,
                style: const TextStyle(
                  color: Color(0xFF5C2D91),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  upload.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Course name
          Text(
            upload.courseName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // Exam type + dept
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                upload.examType,
                style: TextStyle(
                  color: upload.examType == 'Final'
                      ? Colors.green[700]
                      : Colors.orange[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                '${upload.dept}:${upload.section}',
                style: const TextStyle(
                  color: Color(0xFF5C2D91),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            upload.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),

          const SizedBox(height: 8),

          // Stars + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${upload.stars}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF5C2D91),
                    ),
                  ),
                ],
              ),
              Text(
                '${upload.createdAt.day}/${upload.createdAt.month}/${upload.createdAt.year}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
