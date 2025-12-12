import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  final List<Widget> children;

  const SettingCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class SettingSectionTitle extends StatelessWidget {
  final String title;

  const SettingSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}
