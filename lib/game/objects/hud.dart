import 'dart:ui';

typedef void DrawText(HudInfo info);

class HudInfo {
  final String text;
  final Canvas canvas;
  final double x;
  final double y;
  final double width;
  HudInfo({this.text, this.canvas, this.x, this.y, this.width});
}

class Hud {
  static void drawText(HudInfo info) {
    var paragraph = _buildParagraph(info.text, info.width);
    info.canvas.drawParagraph(paragraph, new Offset(info.x, info.y));
  }

  static Paragraph _buildParagraph(String text, double width) {
    var builder = new ParagraphBuilder(new ParagraphStyle(
      textAlign: TextAlign.center,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.normal,
      fontSize: 128.0,
    ))..addText(text);

    return builder.build()..layout(new ParagraphConstraints(width: width));
  }
}
