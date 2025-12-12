import 'package:flutter/material.dart';
import '../bottom_sheet_header.dart';

class BottomSheetOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final T value;
  final bool isDestructive;
  final bool isSelected;
  final Widget? trailing;

  const BottomSheetOption({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.value,
    this.isDestructive = false,
    this.isSelected = false,
    this.trailing,
  });
}

class OptionsBottomSheet<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<BottomSheetOption<T>> options;
  final bool showDivider;
  final bool dismissOnSelect;

  const OptionsBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    this.showDivider = true,
    this.dismissOnSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),
          BottomSheetHeader(
            title: title,
            subtitle: subtitle,
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16),
              itemCount: options.length,
              separatorBuilder: (_, __) => showDivider
                  ? Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                    )
                  : const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final option = options[index];
                return _OptionTile(
                  option: option,
                  onTap: () {
                    if (dismissOnSelect) {
                      Navigator.pop(context, option.value);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile<T> extends StatelessWidget {
  final BottomSheetOption<T> option;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = option.isDestructive
        ? Colors.red
        : (isDark ? Colors.white : Colors.black87);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: option.icon != null
          ? Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (option.iconColor ??
                        (option.isDestructive
                            ? Colors.red
                            : Theme.of(context).primaryColor))
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: option.iconColor ??
                    (option.isDestructive
                        ? Colors.red
                        : Theme.of(context).primaryColor),
              ),
            )
          : null,
      title: Text(
        option.title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: option.subtitle != null
          ? Text(
              option.subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            )
          : null,
      trailing: option.trailing ??
          (option.isSelected
              ? Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).primaryColor,
                )
              : Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                )),
      onTap: onTap,
    );
  }
}
