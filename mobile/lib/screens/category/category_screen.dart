import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';

// Import widgets
import 'widgets/category_tile.dart';
import 'widgets/empty_category_state.dart';
import 'widgets/category_options.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // ANDROID
        statusBarBrightness: Brightness.light, // IOS
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kategori'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => CategoryOptions.showAddForm(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: Consumer<CategoryProvider>(
          builder: (context, provider, _) {
            final categories = provider.categories;

            if (categories.isEmpty) {
              return EmptyCategoryState(
                onCreateTap: () => CategoryOptions.showAddForm(context),
              );
            }

            final defaultCategories =
                categories.where((c) => c.isDefault).toList();
            final customCategories =
                categories.where((c) => !c.isDefault).toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stats Header
                _StatsHeader(
                  defaultCount: defaultCategories.length,
                  customCount: customCategories.length,
                ),
                const SizedBox(height: 20),

                // Custom Categories
                if (customCategories.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Kategori Custom',
                    icon: Icons.tune_rounded,
                    count: customCategories.length,
                    color: Colors.purple,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  ...customCategories.map((c) => CategoryTile(category: c)),
                  const SizedBox(height: 24),
                ],

                // Default Categories
                if (defaultCategories.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Kategori Default',
                    icon: Icons.verified_rounded,
                    count: defaultCategories.length,
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  ...defaultCategories.map((c) => CategoryTile(category: c)),
                ],

                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final int defaultCount;
  final int customCount;

  const _StatsHeader({required this.defaultCount, required this.customCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.category_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Kategori',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '${defaultCount + customCount} Kategori',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat(label: 'Default', count: defaultCount),
              const SizedBox(height: 4),
              _MiniStat(label: 'Custom', count: customCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int count;

  const _MiniStat({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$count $label',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}
