import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../models/user_profile_model.dart';

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

  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textSecondary = Color(0xFF6B7280);
  static const _errorColor = Color(0xFFEF4444);
  static const _successColor = Color(0xFF10B981);
  static const _warningColor = Color(0xFFF59E0B);
  static const _starColor = Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _authService.getProfile(forceRefresh: true);
      if (mounted) {
        setState(() {
          _profile = UserProfile.fromJson(data);
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    final p = _profile!;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: p.name,
          dept: p.dept,
          intake: p.intake,
          section: p.section,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      _fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20)),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_profile != null)
            IconButton(icon: const Icon(Icons.edit), onPressed: _navigateToEditProfile),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _error != null
          ? _buildErrorState()
          : RefreshIndicator(
        onRefresh: _fetchProfile,
        color: _primaryColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildTotalStarsHeader(),
              const SizedBox(height: 12),
              _buildUploadsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalStarsHeader() {
    if (_profile == null) return const SizedBox.shrink();
    final totalStars = _profile!.uploads.fold(0, (sum, u) => sum + u.stars);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Stars Received',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'Community Impact',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.stars, color: Color(0xFFFBBF24), size: 32),
              const SizedBox(width: 8),
              Text(
                '$totalStars',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: _errorColor),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: _errorColor)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _fetchProfile, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final p = _profile!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: _primaryColor,
            backgroundImage: p.imgUrl.isNotEmpty ? NetworkImage(p.imgUrl) : null,
            child: p.imgUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 52) : null,
          ),
          const SizedBox(height: 16),
          Text(
            p.name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryColor),
          ),
          if (p.role.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(p.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getRoleColor(p.role).withOpacity(0.5)),
              ),
              child: Text(
                p.role.toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(p.role),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            p.email,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: _textSecondary),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.school, 'Dept', p.dept),
          const SizedBox(height: 12),
          _infoRow(Icons.numbers, 'Intake', p.intake),
          const SizedBox(height: 12),
          _infoRow(Icons.group, 'Section', p.section),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: Text(label, style: const TextStyle(color: _textSecondary))),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildStatsSection() {
    if (_profile == null) return const SizedBox.shrink();
    final uploads = _profile!.uploads;
    final int total = uploads.length;
    final int approved = uploads.where((u) => u.status.toLowerCase() == 'approved').length;
    final int pending = uploads.where((u) => u.status.toLowerCase() == 'pending').length;
    final int rejected = total - approved - pending;

    final dataMap = total > 0
        ? {"Appr": approved.toDouble(), "Pend": pending.toDouble(), "Rej": rejected.toDouble()}
        : {"No Data": 1.0};

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(24)),
      child: LayoutBuilder(builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 320;
        return Column(
          children: [
            const Text('Upload Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            isSmall
                ? Column(children: [_chart(dataMap, total), const SizedBox(height: 20), _legend(approved, pending, rejected)])
                : Row(children: [Expanded(child: _chart(dataMap, total)), const SizedBox(width: 20), Expanded(child: _legend(approved, pending, rejected))]),
          ],
        );
      }),
    );
  }

  Widget _chart(Map<String, double> data, int total) {
    return SizedBox(
      height: 120,
      child: PieChart(
        dataMap: data,
        chartRadius: 100,
        colorList: total > 0 ? [_successColor, _warningColor, _errorColor] : [Colors.grey],
        chartType: ChartType.ring,
        centerText: "$total",
        legendOptions: const LegendOptions(showLegends: false),
        chartValuesOptions: const ChartValuesOptions(showChartValues: false),
      ),
    );
  }

  Widget _legend(int a, int p, int r) {
    return Column(
      children: [
        _legItem('Approved', a, _successColor),
        _legItem('Pending', p, _warningColor),
        _legItem('Rejected', r, _errorColor),
      ],
    );
  }

  Widget _legItem(String l, int c, Color clr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: clr, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(l, style: const TextStyle(fontSize: 12))),
          Text("$c", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildUploadsSection() {
    if (_profile == null) return const SizedBox.shrink();

    // Sort uploads by stars (highest first)
    final uploads = List<UserUpload>.from(_profile!.uploads);
    uploads.sort((a, b) => b.stars.compareTo(a.stars));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Uploads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              'Sorted by Stars',
              style: TextStyle(fontSize: 12, color: _textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (uploads.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('No uploads yet', style: TextStyle(color: _textSecondary))),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: uploads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildUploadCard(uploads[index]),
          ),
      ],
    );
  }

  Widget _buildUploadCard(UserUpload upload) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(upload.courseCode, style: const TextStyle(fontWeight: FontWeight.bold, color: _primaryColor)),
              StatusBadge(status: upload.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            upload.courseName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, color: _starColor, size: 16),
              const SizedBox(width: 4),
              Text('${upload.stars} stars'),
              const Spacer(),
              Text('${upload.createdAt.day}/${upload.createdAt.month}/${upload.createdAt.year}', style: const TextStyle(fontSize: 12, color: _textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFEF4444); // Red
      case 'teacher':
        return const Color(0xFF1E88E5); // Blue
      case 'moderator':
      case 'modarator':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return _textSecondary;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    Color c = Colors.grey;
    if (status.toLowerCase() == 'approved') c = const Color(0xFF10B981);
    if (status.toLowerCase() == 'pending') c = const Color(0xFFF59E0B);
    if (status.toLowerCase() == 'rejected') c = const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}