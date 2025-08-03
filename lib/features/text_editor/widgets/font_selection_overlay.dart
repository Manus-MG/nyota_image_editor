import 'package:flutter/material.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';

/// Overlay widget for comprehensive font selection with search functionality
class FontSelectionOverlay extends StatefulWidget {
  /// Creates a `FontSelectionOverlay` widget.
  const FontSelectionOverlay({
    super.key,
    required this.configs,
    required this.selectedStyle,
    required this.onFontSelected,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;
  
  /// The currently selected text style.
  final TextStyle selectedStyle;
  
  /// Callback function for when a font is selected.
  final Function(TextStyle) onFontSelected;

  @override
  State<FontSelectionOverlay> createState() => _FontSelectionOverlayState();
}

class _FontSelectionOverlayState extends State<FontSelectionOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  List<TextStyle> _filteredFonts = [];
  List<TextStyle> _allFonts = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _allFonts = widget.configs.textEditor.customTextStyles ?? [];
    _filteredFonts = List.from(_allFonts);
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterFonts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFonts = List.from(_allFonts);
      } else {
        _filteredFonts = _allFonts
            .where((style) => 
                (style.fontFamily ?? 'Default')
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _closeOverlay() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(child: _buildFontGrid()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Font',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredFonts.length} fonts available',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _closeOverlay,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterFonts,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search fonts...',
          hintStyle: TextStyle(color: Colors.white60),
          prefixIcon: Icon(Icons.search, color: Colors.white60),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _filterFonts('');
                  },
                  child: Icon(Icons.clear, color: Colors.white60),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFontGrid() {
    if (_filteredFonts.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.0,
        ),
        itemCount: _filteredFonts.length,
        itemBuilder: (context, index) {
          final style = _filteredFonts[index];
          final isSelected = style.hashCode == widget.selectedStyle.hashCode;
          
          return _buildFontItem(style, isSelected, index);
        },
      ),
    );
  }

  Widget _buildFontItem(TextStyle style, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => widget.onFontSelected(style),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.blue.withValues(alpha: 0.8) 
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.blue
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Aa',
                  style: style.copyWith(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              style.fontFamily ?? 'Default',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.font_download_off,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          Text(
            'No fonts found',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}