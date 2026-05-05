import 'package:flutter/material.dart';
import '../../models/explore_suggestion_model.dart';
import '../../services/explore_suggestion_service.dart';
import '../explore/suggestion_detail_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final UploadedBy uploader;

  const PublicProfileScreen({super.key, required this.uploader});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final SuggestionService _suggestionService = SuggestionService();
  List<Suggestion> _userSuggestions = [];
  bool _isLoading = true;
  String? _error;

  // Professional solid color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _starColor = Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();
    _fetchUserSuggestions();
  }

  Future<void> _fetchUserSuggestions() async {
    try {
      final allSuggestions = await _suggestionService.fetchSuggestions();
      if (mounted) {
        setState(() {
          // Filter suggestions by uploader ID
          _userSuggestions = allSuggestions
              .where((s) => s.uploadedBy.id == widget.uploader.id)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfoCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Uploaded Materials',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: _primaryColor),
                    ))
                  else if (_error != null)
                    Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  else if (_userSuggestions.isEmpty)
                    _buildEmptyState()
                  else
                    ..._userSuggestions.map((s) => _buildSuggestionCard(s)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.uploader.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    final u = widget.uploader;

    // Use information from suggestions if uploader info is missing (N/A)
    String displayDept = u.dept ?? 'N/A';
    String displayIntake = u.intake ?? 'N/A';

    if ((displayDept == 'N/A' || displayIntake == 'N/A') && _userSuggestions.isNotEmpty) {
      final firstS = _userSuggestions.first;
      if (displayDept == 'N/A') displayDept = firstS.dept;
      if (displayIntake == 'N/A') displayIntake = firstS.intake;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: _primaryColor.withOpacity(0.1),
            backgroundImage: (u.imgUrl != null && u.imgUrl!.isNotEmpty)
                ? NetworkImage(u.imgUrl!)
                : null,
            child: (u.imgUrl == null || u.imgUrl!.isEmpty)
                ? const Icon(Icons.person, size: 40, color: _primaryColor)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            u.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryColor),
          ),
          if (u.role != null && u.role!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(u.role!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getRoleColor(u.role!).withOpacity(0.5)),
              ),
              child: Text(
                u.role!.toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(u.role!),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(u.email, style: const TextStyle(color: _textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompactStat(Icons.school, displayDept, 'Dept'),
              _buildCompactStat(Icons.numbers, displayIntake, 'Intake'),
              _buildCompactStat(Icons.star_rounded, _calculateTotalStars().toString(), 'Total Stars'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: _primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: _textSecondary, fontSize: 11)),
      ],
    );
  }

  int _calculateTotalStars() {
    return _userSuggestions.fold(0, (sum, s) => sum + s.stars);
  }

  Widget _buildSuggestionCard(Suggestion s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => SuggestionDetailScreen(suggestion: s)),
        ),
        title: Text(
          s.courseName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(s.courseCode, style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 2),
            Text('${s.examType} • ${s.dept}', style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _starColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: _starColor, size: 14),
              const SizedBox(width: 4),
              Text(s.stars.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: const Column(
        children: [
          Icon(Icons.folder_open, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('No materials shared yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFEF4444);
      case 'teacher':
        return const Color(0xFF1E88E5);
      case 'moderator':
      case 'modarator':
        return const Color(0xFF8B5CF6);
      default:
        return _textSecondary;
    }
  }
}
