// Flutter imports:
import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import 'font_selection_overlay.dart';

/// Represents the bottom bar for the text-editor.
class TextEditorBottomBar extends StatefulWidget {
  /// Bottom bar widget for the text editor.
  ///
  /// [configs] contains configuration settings for the text editor.
  /// [selectedStyle] represents the currently selected text style.
  /// [onFontChange] callback is invoked when the font is changed.
  const TextEditorBottomBar({
    super.key,
    required this.configs,
    required this.selectedStyle,
    required this.onFontChange,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The currently selected text style.
  final TextStyle selectedStyle;

  /// Callback function for changing the text font style.
  final Function(TextStyle style) onFontChange;

  @override
  State<TextEditorBottomBar> createState() => _TextEditorBottomBarState();
}

class _TextEditorBottomBarState extends State<TextEditorBottomBar> {
  final double _space = 10;

  @override
  Widget build(BuildContext context) {
    if (widget.configs.textEditor.customTextStyles == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: widget.configs.textEditor.style.bottomBarBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: MediaQuery.sizeOf(context).width),
          child: Row(
            mainAxisAlignment:
                widget.configs.textEditor.style.bottomBarMainAxisAlignment,
            children: _buildIconButtons(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIconButtons() {
    var items = widget.configs.textEditor.customTextStyles!;
    List<Widget> buttons = [];
    
    // Add "See All" button at the beginning
    buttons.add(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: _space),
        child: IconButton(
          onPressed: _showFontSelectionOverlay,
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grid_view, size: 16),
              SizedBox(width: 4),
              Text('See All', style: TextStyle(fontSize: 12)),
            ],
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.withValues(alpha: 0.7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
    
    // Add font buttons
    buttons.addAll(
      List.generate(
        items.length,
        (index) {
          var selected = widget.selectedStyle;
          bool isSelected = selected.hashCode == items[index].hashCode;
          
          // Get contrast colors for better visibility
          Color backgroundColor = isSelected 
              ? Colors.white 
              : Colors.grey.shade800;
          Color textColor = _getContrastColor(backgroundColor);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: _space),
            child: IconButton(
              onPressed: () => widget.onFontChange(items[index]),
              icon: Text(
                items[index].fontFamily ?? 'Default',
                style: items[index].copyWith(
                  color: textColor,
                  fontSize: 12,
                ),
              ),
              style: IconButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                side: isSelected 
                    ? const BorderSide(color: Colors.blue, width: 2) 
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          );
        },
      ),
    );
    
    return buttons;
  }
  
  /// Calculate contrast color for better visibility
  Color _getContrastColor(Color backgroundColor) {
    double luminance = (0.299 * backgroundColor.r + 
        0.587 * backgroundColor.g + 0.114 * backgroundColor.b) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  /// Show font selection overlay with all fonts
  void _showFontSelectionOverlay() {
    final fonts = widget.configs.textEditor.customTextStyles;
    if (fonts == null || fonts.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FontSelectionOverlay(
        configs: widget.configs,
        selectedStyle: widget.selectedStyle,
        onFontSelected: (style) {
          widget.onFontChange(style);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
