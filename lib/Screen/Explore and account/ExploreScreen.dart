import 'package:flutter/material.dart';
import 'package:suggestion_sharing_platform/Screen/profile%20and%20dashboard/Profile.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/Servies/explore_suggestion_Servies.dart';
import 'package:suggestion_sharing_platform/Screen/Explore%20and%20account/model/explore_suggestion_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SuggestionService _suggestionService = SuggestionService();

  List<Suggestion> _allSuggestions = [];
  List<Suggestion> _filteredSuggestions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
    _searchController.addListener(_onSearchChanged);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3E5F5), // light purple bg
        drawer: _buildDrawer(),
        body: Builder(
          builder: (scaffoldContext) => Column(
            children: [
              // ── Header ──
              _buildHeader(),

              // ── Search Row ──
              _buildSearchRow(scaffoldContext),

              // ── Card List ──
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C2D91)))
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                  const SizedBox(height: 12),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                        _errorMessage = null;
                                      });
                                      _fetchSuggestions();
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filteredSuggestions.isEmpty
                            ? const Center(
                                child: Text(
                                  'No suggestions found',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchSuggestions,
                                color: const Color(0xFF5C2D91),
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 8, bottom: 80,
                                  ),
                                  itemCount: _filteredSuggestions.length,
                                  itemBuilder: (context, index) {
                                    return _buildSuggestionCard(_filteredSuggestions[index]);
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),

        // ── FAB ──
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Upload action placeholder
          },
          backgroundColor: Colors.white,
          shape: const CircleBorder(
            side: BorderSide(color: Color(0xFF5C2D91), width: 2),
          ),
          child: const Icon(Icons.upload, color: Color(0xFF5C2D91), size: 28),
        ),
      ),
    );
  }

  // ─────────────────── HEADER ───────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF5C2D91), // deep purple
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Row(
        children: [
          // Back arrow
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Home Screen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Profile icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Profile()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF7B3FA0),
                child: Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── SEARCH ROW ───────────────────
  Widget _buildSearchRow(BuildContext scaffoldContext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF5C2D91),
      child: Row(
        children: [
          // Drawer hamburger icon
          IconButton(
            onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 8),
          // Search field
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Suggestion',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── SUGGESTION CARD ───────────────────
  Widget _buildSuggestionCard(Suggestion suggestion) {
    // Extract attachment filename from URL
    String attachmentName = 'attachment.pdf';
    try {
      attachmentName = Uri.parse(suggestion.attachmentUrl).pathSegments.last;
      if (attachmentName.length > 20) {
        attachmentName = '${attachmentName.substring(0, 17)}...';
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF5C2D91), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: course code + stars + vote ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  suggestion.courseCode,
                  style: const TextStyle(
                    color: Color(0xFF5C2D91),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      '${suggestion.stars}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF5C2D91),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'vote',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Course name ──
            Text(
              suggestion.courseName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            // ── Exam type + dept section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  suggestion.examType,
                  style: TextStyle(
                    color: suggestion.examType.toLowerCase() == 'final'
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${suggestion.dept}:${suggestion.section}',
                  style: const TextStyle(
                    color: Color(0xFF5C2D91),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Description ──
            Text(
              suggestion.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 10),

            // ── Attachment + Download ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attachment, color: Color(0xFF5C2D91), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Attachment: $attachmentName',
                      style: const TextStyle(
                        color: Color(0xFF5C2D91),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(suggestion.attachmentUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text(
                    'Download',
                    style: TextStyle(
                      color: Color(0xFF5C2D91),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── DRAWER ───────────────────
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF5C2D91)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: Color(0xFF5C2D91)),
                ),
                SizedBox(height: 10),
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF5C2D91)),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF5C2D91)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Profile()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF5C2D91)),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
