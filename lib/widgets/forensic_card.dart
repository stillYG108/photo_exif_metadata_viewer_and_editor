import 'package:flutter/material.dart';
import '../core/theme/forensic_theme.dart';

class ForensicCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool isWarning;
  final EdgeInsetsGeometry? padding;
  final bool compactPadding;

  const ForensicCard({
    super.key,
    required this.child,
    this.title,
    this.isWarning = false,
    this.padding,
    this.compactPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? ForensicColors.alert : Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: ForensicColors.cardBackground,
        border: Border(
          top: BorderSide(color: color, width: 2),
          bottom: BorderSide(color: color.withOpacity(0.3), width: 1),
          left: BorderSide(color: color.withOpacity(0.3), width: 1),
          right: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: color.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    isWarning ? Icons.warning_amber_rounded : Icons.grid_view,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title!.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        letterSpacing: 1.2,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Decorative bits
                  Container(width: 4, height: 4, color: color),
                  const SizedBox(width: 4),
                  Container(width: 4, height: 4, color: color.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Container(width: 4, height: 4, color: color.withOpacity(0.2)),
                ],
              ),
            ),
          
          // Content - removed Expanded to work in scrollable contexts
          Padding(
            padding: padding ?? (compactPadding ? const EdgeInsets.all(8.0) : const EdgeInsets.all(16.0)),
            child: child,
          ),

          // Footer decoration
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "SECURE::${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 7,
                    color: color.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 30, height: 2, color: color.withOpacity(0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
