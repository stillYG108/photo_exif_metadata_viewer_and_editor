import 'package:flutter/material.dart';
import '../theme/color_constants.dart';
import '../theme/typography.dart';
import 'forensic_button.dart';

class ForensicErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  
  const ForensicErrorWidget({
    Key? key,
    required this.errorMessage,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ForensicSpacing.space24),
      decoration: BoxDecoration(
        color: ColorConstants.bgPrimary,
        border: Border.all(
          color: ColorConstants.textError,
          width: ForensicSpacing.borderMedium,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: ColorConstants.textError,
            size: 48,
          ),
          SizedBox(height: ForensicSpacing.space16),
          Text(
            '⚠️ SYSTEM ERROR',
            style: ForensicTypography.header2(ColorConstants.textError),
          ),
          SizedBox(height: ForensicSpacing.space8),
          Text(
            errorMessage,
            style: ForensicTypography.body(ColorConstants.textError),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: ForensicSpacing.space16),
            ForensicButton(
              label: 'RETRY',
              onPressed: onRetry!,
              color: ColorConstants.textError,
            ),
          ],
        ],
      ),
    );
  }
}
