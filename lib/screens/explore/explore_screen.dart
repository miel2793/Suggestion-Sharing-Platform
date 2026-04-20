import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/explore_suggestion_model.dart';
import 'upload_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../services/auth_service.dart';
import '../profile/edit_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/login_screen.dart';
import '../../services/explore_suggestion_service.dart';
import 'suggestion_detail_screen.dart';
import '../profile/public_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SuggestionService _suggestionService = SuggestionService();
  final AuthService _authService = AuthService();

  List<Suggestion> _allSuggestions = [];
  List<Suggestion> _filteredSuggestions = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userName = '';

  String? _errorMessage;
  final Set<String> _votedIds = {};

  // Professional solid color palette
  static const _primaryColor = Color(0xFF1E88E5);
  static const _surfaceColor = Colors.white;
  static const _backgroundLight = Color(0xFFF8FAFF);
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _errorColor = Color(0xFFEF4444);
  static const _successColor = Color(0xFF10B981);
  static const _starColor = Color(0xFFFBBF24);
  static const _voteColor = Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
    _checkLoginStatus();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      try {
        final data = await _authService.getProfile();
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _userName = data['name'] ?? '';
          });
          // Load persistently stored voted IDs for this account
          if (data['email'] != null) {
            _loadVotedIds(data['email']);
          }
        }
      } catch (_) {
        if (mounted) setState(() => _isLoggedIn = true);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _votedIds.clear(); // Clear voted state if not logged in
        });
      }
    }
  }

  Future<void> _loadVotedIds(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'voted_ids_$email';
    final savedIds = prefs.getStringList(key) ?? [];
    if (mounted) {
      setState(() {
        _votedIds.addAll(savedIds);
      });
    }
  }

  Future<void> _saveVotedId(String id) async {
    final loggedIn = await _authService.isLoggedIn();
    if (!loggedIn) return;

    try {
      final data = await _authService.getProfile();
      final email = data['email'];
      if (email == null) return;

      final prefs = await SharedPreferences.getInstance();
      final key = 'voted_ids_$email';
      final current = prefs.getStringList(key) ?? [];

      if (!current.contains(id)) {
        current.add(id);
        await prefs.setStringList(key, current);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = List.from(_allSuggestions);
      } else {
        _filteredSuggestions = _allSuggestions.where((s) {
          return s.courseName.toLowerCase().contains(query) ||
              s.courseCode.toLowerCase().contains(query);
        }).toList();
      }
      _sortByStars();
    });
  }


  Future<void> _fetchSuggestions() async {
    try {
      final suggestions = await _suggestionService.fetchSuggestions();
      setState(() {
        _allSuggestions = suggestions;
        _filteredSuggestions = List.from(suggestions);
        _sortByStars();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Sort both lists by stars descending (highest votes first)
  void _sortByStars() {
    _allSuggestions.sort((a, b) => b.stars.compareTo(a.stars));
    _filteredSuggestions.sort((a, b) => b.stars.compareTo(a.stars));
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: _primaryColor),
            const SizedBox(width: 10),
            const Text('Login Required', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text('Please log in to continue.', style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVote(Suggestion suggestion) async {
    final loggedIn = await _authService.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      _showLoginDialog();
      return;
    }

    try {
      final cookie = await _authService.getToken();
      final dio = Dio();
      final response = await dio.post(
        'https://sdp-3-backend.vercel.app/api/suggestions/${suggestion.id}/vote',
        options: Options(
          headers: {
            if (cookie != null) 'Cookie': cookie,
          },
        ),
      );

      if (!mounted) return;

      final data = response.data;
      final message = data is Map && data.containsKey('message')
          ? data['message']
          : 'Vote submitted!';

      // Update the star count locally if the server returns it
      if (data is Map && data.containsKey('stars')) {
        setState(() {
          final index = _allSuggestions.indexWhere((s) => s.id == suggestion.id);
          if (index != -1) {
            final old = _allSuggestions[index];
            final updated = Suggestion(
              id: old.id,
              courseCode: old.courseCode,
              courseName: old.courseName,
              dept: old.dept,
              intake: old.intake,
              section: old.section,
              examType: old.examType,
              description: old.description,
              attachmentUrl: old.attachmentUrl,
              stars: data['stars'] is int ? data['stars'] : old.stars,
              uploadedBy: old.uploadedBy,
              createdAt: old.createdAt,
              updatedAt: old.updatedAt,
            );
            _allSuggestions[index] = updated;
            // Also update filtered list
            final fIndex = _filteredSuggestions.indexWhere((s) => s.id == suggestion.id);
            if (fIndex != -1) _filteredSuggestions[fIndex] = updated;
          }
        });
      }

      // Mark as voted & re-sort
      setState(() {
        _votedIds.add(suggestion.id);
        _sortByStars();
      });

      // Save permanently for this account
      _saveVotedId(suggestion.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message.toString())),
            ],
          ),
          backgroundColor: _successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      String errorMsg = 'Failed to vote. Try again.';
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errorMsg = data['message'];
        }
      }
      // If already voted, mark it and save
      if (errorMsg.toLowerCase().contains('already')) {
        setState(() => _votedIds.add(suggestion.id));
        _saveVotedId(suggestion.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: _voteColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _backgroundLight,
        drawer: const AppDrawer(),
        body: Builder(
          builder: (scaffoldContext) => Column(
            children: [
              _buildHeader(context, scaffoldContext),
              _buildSearchRow(),
              Expanded(
                child: _isLoading
                    ? _buildShimmerCards()
                    : _errorMessage != null
                    ? _buildErrorState()
                    : _filteredSuggestions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                  onRefresh: _fetchSuggestions,
                  color: _primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
                    itemCount: _filteredSuggestions.length,
                    itemBuilder: (context, index) => _buildSuggestionCard(_filteredSuggestions[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final loggedIn = await _authService.isLoggedIn();
            if (!loggedIn) {
              if (!context.mounted) return;
              _showLoginDialog();
              return;
            }
            if (!context.mounted) return;
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen()));
            if (result == true && mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _fetchSuggestions();
            }
          },
          tooltip: 'Upload Suggestion',
          backgroundColor: _surfaceColor,
          foregroundColor: _primaryColor,
          elevation: 4,
          shape: const CircleBorder(side: BorderSide(color: _primaryColor, width: 2)),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BuildContext scaffoldContext) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 8,
      ),
      color: _primaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          ),
          const Expanded(
            child: Text(
              'Explore Suggestions',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (!_isLoggedIn)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login, color: Colors.white, size: 24),
                  Text('Login', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          else
            const SizedBox(width: 40), // Balance the menu icon on the left
        ],
      ),
    );
  }


  Widget _buildSearchRow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      color: _primaryColor,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(50), // Infinity / Pill design
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: isSmallScreen ? 'Search...' : 'Search course name or code...',
            hintStyle: TextStyle(color: _textSecondary, fontSize: isSmallScreen ? 13 : 14),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.search, color: _textSecondary, size: 22),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: _textSecondary, size: 18),
              onPressed: () => _searchController.clear(),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Suggestion suggestion) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuggestionDetailScreen(suggestion: suggestion))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        suggestion.courseCode,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: _starColor, size: 18),
                          const SizedBox(width: 4),
                          Text('${suggestion.stars}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _votedIds.contains(suggestion.id)
                                ? null
                                : () => _handleVote(suggestion),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _votedIds.contains(suggestion.id)
                                    ? Colors.grey.shade400
                                    : _voteColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                _votedIds.contains(suggestion.id) ? 'Voted' : 'Vote',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                suggestion.courseName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.2),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    suggestion.examType,
                    style: TextStyle(
                      color: suggestion.examType.toLowerCase() == 'final' ? _successColor : _voteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${suggestion.dept} • Int ${suggestion.intake} • Sec ${suggestion.section}',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _textSecondary, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                suggestion.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: _borderColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicProfileScreen(uploader: suggestion.uploadedBy),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, color: _primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              suggestion.uploadedBy.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _primaryColor, 
                                fontSize: 13, 
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final loggedIn = await _authService.isLoggedIn();
                              if (!loggedIn) {
                                if (!mounted) return;
                                _showLoginDialog();
                                return;
                              }
                              try {
                                final uri = Uri.parse(suggestion.attachmentUrl);
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: const Text('Could not open the download link.'), backgroundColor: _errorColor),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: _primaryColor, width: 1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text('Download', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text('View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCards() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(width: 80, height: 14, color: _surfaceColor),
                Container(width: 60, height: 14, color: _surfaceColor),
              ]),
              const SizedBox(height: 12),
              Container(width: 200, height: 18, color: _surfaceColor),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(width: 60, height: 12, color: _surfaceColor),
                Container(width: 80, height: 12, color: _surfaceColor),
              ]),
              const SizedBox(height: 12),
              Container(width: double.infinity, height: 12, color: _surfaceColor),
              const SizedBox(height: 6),
              Container(width: 180, height: 12, color: _surfaceColor),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(width: 100, height: 12, color: _surfaceColor),
                Container(width: 80, height: 12, color: _surfaceColor),
              ]),
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
            Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: _errorColor)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchSuggestions();
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 72, color: _textSecondary.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text('No suggestions found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _textSecondary)),
          const SizedBox(height: 8),
          Text('Try a different search term', style: TextStyle(fontSize: 14, color: _textSecondary)),
        ],
      ),
    );
  }
}