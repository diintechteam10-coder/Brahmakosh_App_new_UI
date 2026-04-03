import 'package:flutter/material.dart';
import '../../core/localization/translate_helper.dart';

/// A Text widget that automatically translates its content using [TranslateHelper].
/// It wraps around [Text] and uses a [FutureBuilder] to fetch the translation asynchronously.
class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: TranslateHelper.translate(text),
      builder: (context, snapshot) {
        // Show original text while loading, with a slight fade if desired, 
        // or just the original text (which might already be translated in static cache).
        final displayedText = snapshot.data ?? text;
        
        return Text(
          displayedText,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor,
        );
      },
    );
  }
}
