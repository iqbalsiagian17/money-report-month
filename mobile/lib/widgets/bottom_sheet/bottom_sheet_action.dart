import 'package:flutter/material.dart';

class BottomSheetActions extends StatelessWidget {
  final String? primaryText;
  final String? secondaryText;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool isLoading;
  final bool primaryEnabled;
  final bool showSecondary;
  final Axis direction;
  final EdgeInsets padding;
  final IconData? primaryIcon;
  final IconData? secondaryIcon;

  const BottomSheetActions({
    super.key,
    this.primaryText,
    this.secondaryText,
    this.onPrimary,
    this.onSecondary,
    this.primaryColor,
    this.secondaryColor,
    this.isLoading = false,
    this.primaryEnabled = true,
    this.showSecondary = true,
    this.direction = Axis.horizontal,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 24),
    this.primaryIcon,
    this.secondaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = primaryColor ?? Theme.of(context).primaryColor;

    if (direction == Axis.vertical) {
      return Padding(
        padding: padding,
        child: Column(
          children: [
            if (primaryText != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: primaryEnabled && !isLoading ? onPrimary : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (primaryIcon != null) ...[
                              Icon(primaryIcon, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              primaryText!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            if (showSecondary && secondaryText != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: !isLoading ? onSecondary : null,
                  style: TextButton.styleFrom(
                    foregroundColor: secondaryColor ??
                        (isDark ? Colors.grey[400] : Colors.grey[700]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (secondaryIcon != null) ...[
                        Icon(secondaryIcon, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        secondaryText!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Horizontal layout
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (showSecondary && secondaryText != null) ...[
            Expanded(
              child: SizedBox(
                height: 52,
                child: TextButton(
                  onPressed: !isLoading ? onSecondary : null,
                  style: TextButton.styleFrom(
                    foregroundColor: secondaryColor ??
                        (isDark ? Colors.grey[400] : Colors.grey[700]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    secondaryText!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (primaryText != null)
            Expanded(
              flex: showSecondary ? 1 : 1,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: primaryEnabled && !isLoading ? onPrimary : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          primaryText!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
