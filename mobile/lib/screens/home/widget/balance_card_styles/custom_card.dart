import 'package:flutter/material.dart';
import '../balance_card.dart';

class CustomBalanceCard extends StatelessWidget {
  final BalanceCardProps props;

  const CustomBalanceCard({super.key, required this.props});

  @override
  Widget build(BuildContext context) {
    final style = props.style;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: style.useGradientValue
            ? LinearGradient(
                colors: style.colors
                    .map((c) => c.withOpacity(style.opacityValue))
                    .toList(),
                begin: style.gradientBegin,
                end: style.gradientEnd,
              )
            : null,
        color: style.useGradientValue
            ? null
            : (style.backgroundColorValue ?? Colors.blue)
                .withOpacity(style.opacityValue),
        borderRadius: BorderRadius.circular(style.borderRadiusValue),
        border: style.showBorderValue
            ? Border.all(
                color: style.borderColorValue ?? Colors.white.withOpacity(0.3),
                width: style.borderWidthValue,
              )
            : null,
        boxShadow: style.showShadowValue
            ? [
                BoxShadow(
                  color: (style.useGradientValue
                          ? style.colors.first
                          : (style.backgroundColorValue ?? Colors.blue))
                      .withOpacity(0.3),
                  blurRadius: style.shadowBlurValue,
                  spreadRadius: style.shadowSpreadValue,
                  offset: Offset(0, style.elevationValue),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (style.showIcon) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (style.textColorValue ?? Colors.white)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: style.textColorValue ?? Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    'Total Saldo',
                    style: TextStyle(
                      color: style.textColorValue ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: props.onToggleVisibility,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (style.textColorValue ?? Colors.white).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    props.isBalanceVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color:
                        (style.textColorValue ?? Colors.white).withOpacity(0.7),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Balance
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              props.isBalanceVisible ? props.formattedBalance : '•••••���••••',
              key: ValueKey(props.isBalanceVisible),
              style: TextStyle(
                color: style.textColorValue ?? Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Footer
          Row(
            children: [
              if (style.showDate)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (style.textColorValue ?? Colors.white).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    props.currentMonth,
                    style: TextStyle(
                      color: (style.textColorValue ?? Colors.white)
                          .withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (style.showWalletCount) ...[
                if (style.showDate) const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (style.textColorValue ?? Colors.white).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 12,
                        color: (style.textColorValue ?? Colors.white)
                            .withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${props.walletCount} Dompet',
                        style: TextStyle(
                          color: (style.textColorValue ?? Colors.white)
                              .withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
