import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x11_flutter/x11_flutter.dart';

class X11View extends StatefulWidget {
  @override
  _X11ViewState createState() => _X11ViewState();
}

class _X11ViewState extends State<X11View> {
  int? textureId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: (event) {
          // Convert local position to X11 coordinates (scale if needed)
          X11Flutter.sendPointerDown(event.localPosition.dx, event.localPosition.dy, 1);
        },
        onPointerMove: (event) {
          X11Flutter.sendPointerMove(event.localPosition.dx, event.localPosition.dy);
        },
        onPointerUp: (event) {
          X11Flutter.sendPointerUp(event.localPosition.dx, event.localPosition.dy, 1);
        },
        child: Container(
          color: Colors.black, // Placeholder - replace with Texture when available
          child: textureId != null
            ? Texture(textureId: textureId!)
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('X11 Texture loading...', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}