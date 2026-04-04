import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/model/explore_suggestion_model.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/UploadScreen.dart';
import 'AppDrawer.dart';
import 'package:suggestion_sharing_platform/Screen/log%20and%20reg/Services/auth_service.dart';
import 'package:suggestion_sharing_platform/Screen/profile%20and%20dashboard/EditProfileScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../log and reg/login_screen.dart';
import 'Servies/explore_suggestion_services.dart';
import 'SuggestionDetailScreen.dart';

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
  String _dept = '';
  String _intake = '';
  String _section = '';

  String? _errorMessage;

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
        }
      } catch (_) {
        if (mounted) setState(() => _isLoggedIn = true);
      }
    } else {
      if (mounted) setState(() => _isLoggedIn = false);
    }
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
    });
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: _userName,
          dept: _dept,
          intake: _intake,
          section: _section,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _userName = result['name'] ?? _userName;
        _dept = result['dept'] ?? _dept;
        _intake = result['intake'] ?? _intake;
        _section = result['section'] ?? _section;
      });
    }
  }

  Future<void> _fetchSuggestions() async {
    try {
      final suggestions = await _suggestionService.fetchSuggestions();
      setState(() {
        _allSuggestions = suggestions;
        _filteredSuggestions = List.from(suggestions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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

  void _showFaqDialog() {
    final List<Map<String, String>> faqs = [
      {'question': 'How do I upload a suggestion?', 'answer': 'Tap the upload button on the home screen. Fill in the course details, select your file, and tap Submit.'},
      {'question': 'How do I search for suggestions?', 'answer': 'Use the search bar at the top. Search by course name or code.'},
      {'question': 'How do I download an attachment?', 'answer': 'Find the suggestion card and tap "Download". You need to be logged in.'},
      {'question': 'Do I need an account to browse?', 'answer': 'You can browse without an account, but you need to log in to upload, download, and access your profile.'},
      {'question': 'How do I edit my profile?', 'answer': 'Open the side menu and tap "Edit Profile".'},
      {'question': 'How do I change my password?', 'answer': 'Go to Settings from the drawer menu.'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.quiz_outlined, color: _primaryColor),
            const SizedBox(width: 10),
            const Text('FAQs', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Theme(
                data: ThemeData().copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  iconColor: _primaryColor,
                  collapsedIconColor: _primaryColor,
                  title: Text(faq['question']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  children: [
                    Text(faq['answer']!, style: TextStyle(fontSize: 13, color: _textSecondary, height: 1.4)),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: _backgroundLight,
          drawer: const AppDrawer(),
          body: Builder(
            builder: (scaffoldContext) => Column(
              children: [
                _buildHeader(),
                _buildSearchRow(scaffoldContext),
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
            elevation: 2,
            shape: const CircleBorder(side: BorderSide(color: _primaryColor, width: 2)),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      color: _primaryColor,
      child: const Center(
        child: Text(
          'Explore Suggestions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRow(BuildContext scaffoldContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: _primaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          ),
          if (!_isLoggedIn)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login, color: Colors.white, size: 28),
                  SizedBox(height: 2),
                  Text('Login', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by course name or code...',
                  hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: _textSecondary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: _textSecondary, size: 18),
                    onPressed: () => _searchController.clear(),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      suggestion.courseCode,
                      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: _starColor, size: 20),
                      const SizedBox(width: 4),
                      Text('${suggestion.stars}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => debugPrint('Vote clicked'),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _voteColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text('Vote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(suggestion.courseName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    suggestion.examType,
                    style: TextStyle(
                      color: suggestion.examType.toLowerCase() == 'final' ? _successColor : _voteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text('${suggestion.dept} • Intake ${suggestion.intake} • Sec ${suggestion.section}', style: TextStyle(color: _textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                suggestion.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: _borderColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: _textSecondary, size: 18),
                      const SizedBox(width: 6),
                      Text(suggestion.uploadedBy.name, style: TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: _primaryColor, width: 1.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text('Download', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text('View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ],
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