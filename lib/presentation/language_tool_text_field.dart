import 'package:flutter/material.dart';
import 'package:languagetool_textfield/core/controllers/language_tool_controller.dart';
import 'package:languagetool_textfield/utils/mistake_popup.dart';
import 'package:languagetool_textfield/utils/popup_overlay_renderer.dart';

/// A TextField widget that checks the grammar using the given
/// [LanguageToolController]
class LanguageToolTextField extends StatefulWidget {
  /// A Build Counter for text limit
  final Widget? Function(BuildContext,
      {required int currentLength,
      required bool isFocused,
      required int? maxLength})? buildCounter;

  /// Called when the user initiates a change to the TextField's value: when they have inserted or deleted text.
  final Function(String)? onChanged;

  /// TextInput Type for keyboard type
  final TextInputAction? textInputAction;

  /// Text Align for Text Field
  final TextAlign textAlign;

  /// A style to use for the text being edited.
  final TextStyle? style;

  /// A decoration of this [TextField].
  final InputDecoration decoration;

  /// Color scheme to highlight mistakes
  final LanguageToolController controller;

  /// Mistake popup window
  final MistakePopup? mistakePopup;

  /// The maximum number of lines to show at one time, wrapping if necessary.
  final int? maxLines;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  final int? minLines;

  /// Whether this widget's height will be sized to fill its parent.
  final bool expands;

  /// A language code like en-US, de-DE, fr, or auto to guess
  /// the language automatically.
  /// ```language``` = 'auto' by default.
  final String language;

  /// Set Color and height to cursor of TextField.
  final Color? cursorColor;
  final double? cursorHeight;

  /// Creates a widget that checks grammar errors.
  const LanguageToolTextField({
    required this.controller,
    this.style,
    this.decoration = const InputDecoration(),
    this.language = 'auto',
    this.mistakePopup,
    this.maxLines = 1,
    this.minLines,
    this.buildCounter,
    this.textInputAction,
    this.onChanged,
    this.cursorColor,
    this.cursorHeight,
    this.textAlign = TextAlign.start,
    this.expands = false,
    super.key,
  });

  @override
  State<LanguageToolTextField> createState() => _LanguageToolTextFieldState();
}

class _LanguageToolTextFieldState extends State<LanguageToolTextField> {
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller = widget.controller;

    controller.focusNode = _focusNode;
    controller.language = widget.language;
    final defaultPopup = MistakePopup(popupRenderer: PopupOverlayRenderer());
    controller.popupWidget = widget.mistakePopup ?? defaultPopup;

    controller.addListener(_textControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (_, __) {
        final fetchError = widget.controller.fetchError;

        // it would probably look much better if the error would be shown on a
        // dedicated panel with field options
        final httpErrorText = Text(
          '$fetchError',
          style: TextStyle(
            color: widget.controller.highlightStyle.misspellingMistakeColor,
          ),
        );

        final inputDecoration = widget.decoration.copyWith(
          suffix: fetchError != null ? httpErrorText : null,
        );

        return Center(
          child: TextField(
            cursorColor: widget.cursorColor,
            cursorHeight: widget.cursorHeight,
            buildCounter: widget.buildCounter,
            focusNode: _focusNode,
            controller: widget.controller,
            onChanged: widget.onChanged,
            scrollController: _scrollController,
            textInputAction: widget.textInputAction,
            textAlign: widget.textAlign,
            decoration: inputDecoration,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            expands: widget.expands,
            style: widget.style,
            selectionControls: materialTextSelectionControls,
          ),
        );
      },
    );
  }

  void _textControllerListener() =>
      widget.controller.scrollOffset = _scrollController.offset;

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
