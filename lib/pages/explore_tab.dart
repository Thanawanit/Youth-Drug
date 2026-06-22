import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';
import '../constants/app_colors.dart';
import '../data/facts.dart';
import '../models/fact_model.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ทั้งหมด';
  String _searchQuery = '';
  late final Fact _topSuggestedFact;
  int _currentPageIndex = 0;

  // Stack deck drag & animation variables
  Offset _dragOffset = Offset.zero;
  bool _isAnimating = false;
  late final AnimationController _swipeAnimController;
  late Animation<Offset> _swipeAnimation;

  @override
  void initState() {
    super.initState();
    _topSuggestedFact = factsDataset[Random().nextInt(factsDataset.length)];
    _swipeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_swipeAnimController);
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'รู้ไหม':
        return Icons.lightbulb_rounded;
      case 'การป้องกัน':
        return Icons.security_rounded;
      case 'ข้อควรระวัง':
        return Icons.report_problem_rounded;
      case 'ความรู้เพิ่มเติม':
        return Icons.library_books_rounded;
      case 'ที่บันทึกไว้':
        return Icons.bookmark_rounded;
      case 'ทั้งหมด':
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  void dispose() {
    _swipeAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Fact> _getFilteredFacts(Set<String> bookmarkedIds) {
    return factsDataset.where((fact) {
      final matchesCategory = _selectedCategory == 'ทั้งหมด' ||
          (_selectedCategory == 'ที่บันทึกไว้' && bookmarkedIds.contains(fact.id)) ||
          (fact.category == _selectedCategory && _selectedCategory != 'ที่บันทึกไว้');
      
      final matchesSearch = _searchQuery.isEmpty ||
          fact.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          fact.message.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPageIndex = 0;
      _dragOffset = Offset.zero;
    });
  }

  void _shuffleToRandomPage(int factCount) {
    if (factCount <= 1) return;
    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(factCount);
    } while (newIndex == _currentPageIndex);

    setState(() {
      _currentPageIndex = newIndex;
      _dragOffset = Offset.zero;
    });
  }

  void _swipeOut(double direction, int factCount) {
    if (factCount == 0) return;
    setState(() {
      _isAnimating = true;
    });
    final start = _dragOffset;
    final end = Offset(direction * 700.0, _dragOffset.dy * 1.5);
    _swipeAnimation = Tween<Offset>(begin: start, end: end).animate(
      CurvedAnimation(parent: _swipeAnimController, curve: Curves.easeOut),
    );
    _swipeAnimController.forward(from: 0.0).then((_) {
      setState(() {
        _currentPageIndex = (_currentPageIndex + 1) % factCount;
        _dragOffset = Offset.zero;
        _isAnimating = false;
      });
    });
  }

  void _returnToCenter() {
    setState(() {
      _isAnimating = true;
    });
    final start = _dragOffset;
    _swipeAnimation = Tween<Offset>(begin: start, end: Offset.zero).animate(
      CurvedAnimation(parent: _swipeAnimController, curve: Curves.easeOutBack),
    );
    _swipeAnimController.forward(from: 0.0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
        _isAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        final isReading = state.isReadingMode;
        final fontScale = state.fontScale;

        final textColor = isDark ? Colors.white : AppColors.textDark;
        final subTextColor = isDark ? Colors.white70 : AppColors.textGrey;
        final searchBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

        final filteredFacts = _getFilteredFacts(state.bookmarkedFactIds);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'สำรวจความรู้',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              // Reading Mode toggle button
              IconButton(
                icon: Icon(
                  isReading ? Icons.chrome_reader_mode_rounded : Icons.chrome_reader_mode_outlined,
                  color: isReading ? AppColors.success : null,
                ),
                tooltip: 'โหมดการอ่าน',
                onPressed: () {
                  appStateNotifier.toggleReadingMode();
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top Suggested Random Fact Card (Mini banner)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: isDark ? AppColors.success : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'เรื่องน่าสนใจวันนี้: ${_topSuggestedFact.title}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            _showFactDetailBottomSheet(context, _topSuggestedFact, state);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'ดูเพิ่ม',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.success : AppColors.primary,
                              fontFamily: 'Prompt',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: searchBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.008),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor, fontFamily: 'Prompt', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'ค้นหาความรู้ที่อยากอ่าน...',
                        hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.6), fontFamily: 'Prompt'),
                        prefixIcon: Icon(Icons.search_rounded, color: subTextColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: subTextColor),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),

                // 3. Category Chips List (added Bookmarks chip)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      'ทั้งหมด',
                      'รู้ไหม',
                      'การป้องกัน',
                      'ข้อควรระวัง',
                      'ความรู้เพิ่มเติม',
                      'ที่บันทึกไว้',
                    ].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(cat),
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : AppColors.textDark),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat,
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : AppColors.textDark),
                                ),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: isDark ? AppColors.success : AppColors.primary,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : borderColor,
                            ),
                          ),
                          onSelected: (_) => _onCategorySelected(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Expanded(
                  child: filteredFacts.isEmpty
                      ? _buildEmptyState(isDark, subTextColor)
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return AnimatedBuilder(
                                animation: _swipeAnimController,
                                builder: (context, child) {
                                  final currentOffset = _isAnimating ? _swipeAnimation.value : _dragOffset;
                                  // Swipe progress 0..1 based on displacement
                                  final swipeProgress = (currentOffset.dx.abs() / 400.0).clamp(0.0, 1.0);
                                  final angle = (currentOffset.dx / 300.0) * (pi / 12);
                                  // Fade out as card leaves
                                  final topOpacity = (1.0 - swipeProgress * 0.8).clamp(0.0, 1.0);

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Bottom card (blank placeholder – 3rd)
                                      if (filteredFacts.length > 2)
                                        Positioned.fill(
                                          child: Transform.translate(
                                            offset: Offset(0, 20 - swipeProgress * 10),
                                            child: Transform.scale(
                                              scale: 0.88 + swipeProgress * 0.06,
                                              child: Opacity(
                                                opacity: 0.45 + swipeProgress * 0.3,
                                                child: IgnorePointer(
                                                  child: _buildBlankCard(isDark, isReading),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Middle card (blank placeholder – 2nd)
                                      if (filteredFacts.length > 1)
                                        Positioned.fill(
                                          child: Transform.translate(
                                            offset: Offset(0, 10 - swipeProgress * 10),
                                            child: Transform.scale(
                                              scale: 0.94 + swipeProgress * 0.06,
                                              child: Opacity(
                                                opacity: 0.75 + swipeProgress * 0.25,
                                                child: IgnorePointer(
                                                  child: _buildBlankCard(isDark, isReading),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Top card (draggable & interactive) – fades out as it swipes away
                                      Positioned.fill(
                                        child: GestureDetector(
                                          onPanUpdate: (details) {
                                            if (_isAnimating) return;
                                            setState(() {
                                              _dragOffset += details.delta;
                                            });
                                          },
                                          onPanEnd: (details) {
                                            if (_isAnimating) return;
                                            final threshold = 120.0;
                                            if (_dragOffset.dx > threshold) {
                                              _swipeOut(1.0, filteredFacts.length);
                                            } else if (_dragOffset.dx < -threshold) {
                                              _swipeOut(-1.0, filteredFacts.length);
                                            } else {
                                              _returnToCenter();
                                            }
                                          },
                                          child: Opacity(
                                            opacity: topOpacity,
                                            child: Transform.translate(
                                              offset: currentOffset,
                                              child: Transform.rotate(
                                                angle: angle,
                                                child: Builder(
                                                  builder: (context) {
                                                    final blurSigma = (currentOffset.dx.abs() / 40.0).clamp(0.0, 6.0);
                                                    Widget card = _buildFactCard(
                                                      context,
                                                      filteredFacts[_currentPageIndex],
                                                      state.bookmarkedFactIds.contains(filteredFacts[_currentPageIndex].id),
                                                      isDark,
                                                      isReading,
                                                      fontScale,
                                                      state,
                                                      filteredFacts.length,
                                                    );
                                                    if (blurSigma > 0.1) {
                                                      card = ImageFiltered(
                                                        imageFilter: ImageFilter.blur(
                                                          sigmaX: blurSigma,
                                                          sigmaY: 0.0,
                                                        ),
                                                        child: card,
                                                      );
                                                    }
                                                    return card;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),

                // 5. Custom Dot Indicators (• • ○ ○)
                if (filteredFacts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDotIndicators(filteredFacts.length, isDark),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, Color subTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 48,
                color: isDark ? Colors.white60 : AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ยังไม่มีการ์ดที่บันทึกไว้',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'หากเจอการ์ดที่อยากกลับมาอ่านอีกครั้ง สามารถแตะไอคอนบันทึกไว้ก่อนได้',
              style: TextStyle(
                fontSize: 13,
                color: subTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlankCard(bool isDark, bool isReading) {
    final cardBg = isReading
        ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
        : (isDark ? const Color(0xFF1E293B) : Colors.white);
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(36),
        ),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 36,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            const SizedBox(height: 8),
            Text(
              'เลื่อนดูต่อ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white12 : Colors.black12,
                fontFamily: 'Prompt',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicators(int count, bool isDark) {
    // Show maximum 8 dots to avoid overflow on small screens
    final displayCount = min(count, 8);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(displayCount, (index) {
        final isActive = index == (_currentPageIndex % displayCount);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 18 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.success : AppColors.primary)
                : (isDark ? Colors.white24 : AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildFactCard(
    BuildContext context,
    Fact fact,
    bool isBookmarked,
    bool isDark,
    bool isReading,
    double fontScale,
    AppState state,
    int filteredCount,
  ) {
    Color stripeColor;
    IconData categoryIcon;

    switch (fact.category) {
      case 'รู้ไหม':
        stripeColor = AppColors.catFact;
        categoryIcon = Icons.lightbulb_rounded;
        break;
      case 'การป้องกัน':
        stripeColor = AppColors.catPrevention;
        categoryIcon = Icons.security_rounded;
        break;
      case 'ข้อควรระวัง':
        stripeColor = AppColors.catWarning;
        categoryIcon = Icons.report_problem_rounded;
        break;
      case 'ความรู้เพิ่มเติม':
      default:
        stripeColor = AppColors.catMore;
        categoryIcon = Icons.library_books_rounded;
        break;
    }

    final cardBg = isReading
        ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
        : (isDark ? const Color(0xFF1E293B) : Colors.white);

    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(36),
        ),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isReading
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.02),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: TweenAnimationBuilder<double>(
        key: ValueKey<String>('content_${fact.id}'),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
        builder: (context, opacity, child) {
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Symbol & Category Display
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: stripeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            categoryIcon,
                            color: stripeColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fact.category,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: stripeColor,
                                fontFamily: 'Prompt',
                              ),
                            ),
                            const Text(
                              'การ์ดความรู้เสพติด',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
  
                    // 2. Fact Title
                    Text(
                      fact.title,
                      style: TextStyle(
                        fontSize: (isReading ? 21.0 : 18.0) * fontScale,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
  
                    // 3. Fact Message Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          fact.message,
                          style: TextStyle(
                            fontSize: (isReading ? 15.5 : 13.5) * fontScale,
                            color: isDark ? Colors.white70 : AppColors.textGrey,
                            height: isReading ? 1.7 : 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
  
                    // 4. Action Row: ♡ บันทึก / ⟳ สุ่ม / 📚 อ่านต่อ (Inside the card)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Bookmark toggle
                        _buildInlineActionButton(
                          icon: isBookmarked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          label: isBookmarked ? 'เก็บไว้แล้ว' : 'เก็บไว้อ่าน',
                          color: isBookmarked ? Colors.redAccent : AppColors.textGrey,
                          onPressed: () {
                            appStateNotifier.toggleBookmark(fact.id);
                          },
                        ),
                        // Shuffle Card
                        _buildInlineActionButton(
                          icon: Icons.casino_rounded,
                          label: 'สุ่มอีกใบ',
                          color: isDark ? AppColors.success : AppColors.primary,
                          onPressed: () => _shuffleToRandomPage(filteredCount),
                        ),
                        // Read related
                        _buildInlineActionButton(
                          icon: Icons.library_books_rounded,
                          label: 'อ่านแบบเต็ม',
                          color: Colors.blueAccent,
                          onPressed: () {
                            _showRelatedFactsBottomSheet(context, fact, state);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
          fontFamily: 'Prompt',
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _showFactDetailBottomSheet(BuildContext context, Fact fact, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: state.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: state.isDarkMode ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    fact.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fact.title,
                    style: TextStyle(
                      fontSize: 19 * state.fontScale,
                      fontWeight: FontWeight.w800,
                      color: state.isDarkMode ? Colors.white : AppColors.textDark,
                      fontFamily: 'Prompt',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        fact.message,
                        style: TextStyle(
                          fontSize: 14.5 * state.fontScale,
                          color: state.isDarkMode ? Colors.white70 : AppColors.textGrey,
                          height: 1.6,
                          fontFamily: 'Prompt',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.isDarkMode ? AppColors.success : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ปิดหน้าต่าง',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Prompt'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRelatedFactsBottomSheet(BuildContext context, Fact fact, AppState state) {
    // Find related facts in the same category
    final related = factsDataset.where((f) => f.category == fact.category && f.id != fact.id).take(3).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: state.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: state.isDarkMode ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'อ่านเรื่องที่เกี่ยวข้อง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Prompt',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ข้อมูลเพิ่มเติมในหมวดหมู่ "${fact.category}"',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      fontFamily: 'Prompt',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (related.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text('ไม่มีข้อมูลที่เกี่ยวข้องอื่นๆ ในขณะนี้'),
                            )
                          else
                            ...related.map((f) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: state.isDarkMode
                                    ? const Color(0xFF334155).withValues(alpha: 0.4)
                                    : AppColors.background,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                                child: ListTile(
                                  title: Text(
                                    f.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: state.isDarkMode ? Colors.white : AppColors.textDark,
                                      fontFamily: 'Prompt',
                                    ),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showFactDetailBottomSheet(context, f, state);
                                  },
                                ),
                              );
                            }),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
