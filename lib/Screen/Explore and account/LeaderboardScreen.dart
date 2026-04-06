import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/Servies/explore_suggestion_services.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/model/explore_suggestion_model.dart';

class LeaderboardUser {
  final String userId;
  final String name;
  final String? studentId;
  final String? image;
  final String? dept;
  final String? intake;
  int totalStars;

  LeaderboardUser({
    required this.userId,
    required this.name,
    this.studentId,
    this.image,
    this.dept,
    this.intake,
    required this.totalStars,
  });
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final SuggestionService _suggestionService = SuggestionService();
  List<LeaderboardUser> _leaderboard = [];
  bool _isLoading = true;
  String? _error;

  // Professional color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _starColor = Color(0xFFFBBF24);
  static const _accentColor = Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    _fetchAndProcessLeaderboard();
  }

  Future<void> _fetchAndProcessLeaderboard() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final suggestions = await _suggestionService.fetchSuggestions();
      
      final Map<String, LeaderboardUser> userStats = {};

      for (var suggestion in suggestions) {
        final user = suggestion.uploadedBy;
        if (!userStats.containsKey(user.id)) {
          userStats[user.id] = LeaderboardUser(
            userId: user.id,
            name: user.name,
            studentId: user.studentId,
            image: user.imgUrl,
            dept: user.dept,
            intake: user.intake,
            totalStars: 0,
          );
        }
        userStats[user.id]!.totalStars += suggestion.stars;
      }

      final list = userStats.values.toList();
      // Sort by stars descending
      list.sort((a, b) => b.totalStars.compareTo(a.totalStars));

      if (mounted) {
        setState(() {
          _leaderboard = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Top Contributors',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAndProcessLeaderboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _error != null
              ? _buildErrorScreen()
              : _leaderboard.isEmpty
                  ? _buildEmptyScreen()
                  : _buildLeaderboardList(),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Failed to load leaderboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: _textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchAndProcessLeaderboard,
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No contributors yet!', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Column(
      children: [
        _buildLeaderboardHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _leaderboard.length,
            itemBuilder: (context, index) {
              final user = _leaderboard[index];
              final rank = index + 1;
              return _buildLeaderboardItem(user, rank);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Leader  board',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Top Suggestion Sharers',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 20),
          if (_leaderboard.length >= 3) _buildTopThree(),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumItem(_leaderboard[1], 2, 70), // 2nd
        _buildPodiumItem(_leaderboard[0], 1, 90), // 1st
        _buildPodiumItem(_leaderboard[2], 3, 70), // 3rd
      ],
    );
  }

  Widget _buildPodiumItem(LeaderboardUser user, int rank, double size) {
    Color rankColor = rank == 1 ? const Color(0xFFFFD700) : (rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: 3),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.white,
                backgroundImage: user.image != null && user.image!.isNotEmpty ? NetworkImage(user.image!) : null,
                child: (user.image == null || user.image!.isEmpty)
                    ? Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(fontSize: size / 2, fontWeight: FontWeight.bold, color: _primaryColor),
                      )
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
              child: Text('$rank', style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            const Icon(Icons.star, color: _starColor, size: 14),
            Text(
              ' ${user.totalStars}',
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardUser user, int rank) {
    bool isTop3 = rank <= 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isTop3 ? _primaryColor : _textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: _primaryColor.withOpacity(0.1),
            backgroundImage: user.image != null && user.image!.isNotEmpty ? NetworkImage(user.image!) : null,
            child: (user.image == null || user.image!.isEmpty)
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _starColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: _starColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${user.totalStars}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309), // dark orange
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
