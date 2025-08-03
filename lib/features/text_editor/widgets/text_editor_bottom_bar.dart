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
  final double _space = 6;

  @override
  Widget build(BuildContext context) {
    if (widget.configs.textEditor.customTextStyles == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: widget.configs.textEditor.style.bottomBarBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildIconButtons(),
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
        child: GestureDetector(
          onTap: _showFontSelectionOverlay,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apps, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text('All', 
                    style: TextStyle(fontSize: 10, color: Colors.white, 
                                     fontWeight: FontWeight.w600)),
              ],
            ),
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

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: _space),
            child: GestureDetector(
              onTap: () => widget.onFontChange(items[index]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.blue.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Stack(
                  children: [
                    Text(
                      items[index].fontFamily ?? 'Default',
                      style: items[index].copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    
    return buttons;
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
