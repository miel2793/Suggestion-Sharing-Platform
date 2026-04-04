import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/Services/auth_service.dart';
import 'package:suggestion_sharing_platform/Screen/profile%20and%20dashboard/EditProfileScreen.dart';
import 'package:pie_chart/pie_chart.dart';
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

  // Professional solid color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _borderColor = Color(0xFFE5E7EB);
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
      // Force refresh to get latest upload stats and status
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
        title: const Text(
          'My Profile',
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
        actions: [
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _navigateToEditProfile,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: _primaryColor,
          strokeWidth: 3,
        ),
      )
          : _error != null
          ? _buildErrorState()
          : RefreshIndicator(
        onRefresh: _fetchProfile,
        color: _primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildUploadsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: _errorColor),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _errorColor, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
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
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with solid background
          CircleAvatar(
            radius: 48,
            backgroundColor: _primaryColor,
            backgroundImage: p.imgUrl.isNotEmpty ? NetworkImage(p.imgUrl) : null,
            onBackgroundImageError: p.imgUrl.isNotEmpty ? (_, __) {} : null,
            child: p.imgUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 52)
                : null,
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            p.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 6),

          // Email
          Text(
            p.email,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              p.role.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: _borderColor),
          const SizedBox(height: 16),

          // Info rows (solid icons and text)
          _infoRow(Icons.school_outlined, 'Department', p.dept),
          const SizedBox(height: 12),
          _infoRow(Icons.numbers_outlined, 'Intake', p.intake),
          const SizedBox(height: 12),
          _infoRow(Icons.group_outlined, 'Section', p.section),
          const SizedBox(height: 12),
          _infoRow(Icons.upload_file_outlined, 'Total Uploads', '${p.uploads.length}'),
          const SizedBox(height: 12),
          _infoRow(
            Icons.calendar_today_outlined,
            'Joined',
            '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 22),
        const SizedBox(width: 14),
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  // ─────────────────── STATISTICS SECTION ───────────────────
  Widget _buildStatsSection() {
    if (_profile == null) return const SizedBox.shrink();

    final uploads = _profile!.uploads;
    final int total = uploads.length;
    final int approved = uploads.where((u) => u.status.toLowerCase() == 'approved').length;
    final int pending = uploads.where((u) => u.status.toLowerCase() == 'pending').length;
    final int rejected = total - approved - pending;

    // Data for the pie chart (fallback to 100% empty if no uploads)
    final Map<String, double> dataMap = total > 0
        ? {
            "Approved": approved.toDouble(),
            "Pending": pending.toDouble(),
            "Rejected": rejected.toDouble(),
          }
        : {
            "No Data": 1,
          };

    final List<Color> colorList = total > 0
        ? [_successColor, _warningColor, _errorColor]
        : [Colors.grey.shade300];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 180, // Added fixed height to prevent layout collapse
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 1,
                  child: PieChart(
                    dataMap: dataMap,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 0,
                    chartRadius: 120,
                    colorList: colorList,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring, // Changed to ring for better look
                    centerText: total > 0 ? "TOTAL\n$total" : "EMPTY",
                    centerTextStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                    ringStrokeWidth: 16,
                    legendOptions: const LegendOptions(showLegends: false),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: total > 0,
                      showChartValuesInPercentage: false,
                      showChartValuesOutside: total > 0,
                      decimalPlaces: 0,
                      chartValueStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Legend
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Approved', approved, _successColor),
                      const SizedBox(height: 14),
                      _buildLegendItem('Pending', pending, _warningColor),
                      const SizedBox(height: 14),
                      _buildLegendItem('Rejected', rejected, _errorColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
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
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        if (uploads.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file_outlined, size: 48, color: _textSecondary),
                const SizedBox(height: 12),
                Text(
                  'No uploads yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your uploaded suggestions will appear here',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
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
    Color statusColor;
    String statusText;
    switch (upload.status.toLowerCase()) {
      case 'approved':
        statusColor = _successColor;
        statusText = 'Approved';
        break;
      case 'pending':
        statusColor = _warningColor;
        statusText = 'Pending';
        break;
      default:
        statusColor = _errorColor;
        statusText = 'Rejected';
    }

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Optionally navigate to detail view
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        upload.courseCode,
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  upload.courseName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      upload.examType,
                      style: TextStyle(
                        color: upload.examType == 'Final' ? _successColor : _warningColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${upload.dept} • Sec ${upload.section}',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  upload.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _borderColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: _starColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${upload.stars}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${upload.createdAt.day}/${upload.createdAt.month}/${upload.createdAt.year}',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}