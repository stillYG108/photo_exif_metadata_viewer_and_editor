import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DiagnosticScreen extends StatelessWidget {
  const DiagnosticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get physical screen size
    final view = ui.PlatformDispatcher.instance.views.first;
    final physicalSize = view.physicalSize;
    final devicePixelRatio = view.devicePixelRatio;
    final logicalSize = physicalSize / devicePixelRatio;

    return Scaffold(
      backgroundColor: Colors.red, // Bright red so we can see SOMETHING
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Colors.blue, // Blue container
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIAGNOSTIC INFO',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Physical Size: ${physicalSize.width} x ${physicalSize.height}',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Device Pixel Ratio: $devicePixelRatio',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Logical Size: ${logicalSize.width} x ${logicalSize.height}',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Constraints: ${constraints.maxWidth} x ${constraints.maxHeight}',
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'MediaQuery Size: ${MediaQuery.of(context).size}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
