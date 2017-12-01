import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef void OnBoxItemPressed();

class BoxItem extends StatelessWidget {
  final bool isEnabled;
  final bool isValid;
  final OnBoxItemPressed onPressed;
  final String text;
  final BuildContext scaffoldContext;
  final double fontSize;

  BoxItem({
    @required this.text,
    @required this.onPressed,
    @required this.scaffoldContext,
    this.isEnabled: true,
    this.isValid: true,
    this.fontSize: 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTapUp: ((_) {
        if (isEnabled && !isValid) {
          Scaffold.of(scaffoldContext).showSnackBar(const SnackBar(
              content: const Text(
                  "This level doesn't actually exist.  This is not an error.")));
        } else if (isEnabled) {
          this.onPressed();
        }
      }),
      child: new Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: new DecoratedBox(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/images/crate.png"),
              fit: BoxFit.fill,
            ),
          ),
          key: new Key(text),
          child: new Container(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Expanded(
                  child: new Center(
                    child: new Text(
                      text,
                      style: new TextStyle(
                        fontWeight:
                            isEnabled ? FontWeight.bold : FontWeight.normal,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
