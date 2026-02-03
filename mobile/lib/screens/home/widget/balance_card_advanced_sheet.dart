import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/balance_card_provider.dart';
import '../../../../models/balance_card_style.dart';
import '../../../../widgets/color_picker_dialog.dart';

class AdvancedCustomizeSheet extends StatefulWidget {
  final BalanceCardProvider provider;

  const AdvancedCustomizeSheet({
    super.key,
    required this.provider,
  });

  @override
  State<AdvancedCustomizeSheet> createState() => _AdvancedCustomizeSheetState();
}

class _AdvancedCustomizeSheetState extends State<AdvancedCustomizeSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.palette_rounded,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Custom Balance Card',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  isDark ? Colors.grey[400] : Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Style'),
                Tab(text: 'Warna'),
                Tab(text: 'Bentuk'),
                Tab(text: 'Efek'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StyleTab(provider: widget.provider),
                _ColorTab(provider: widget.provider),
                _ShapeTab(provider: widget.provider),
                _EffectTab(provider: widget.provider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// TAB 1: STYLE (Preset)
// ============================================
class _StyleTab extends StatelessWidget {
  final BalanceCardProvider provider;

  const _StyleTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<BalanceCardProvider>(
      builder: (context, provider, _) {
        final styles = [
          (
            'Gradient',
            BalanceCardType.gradient,
            Icons.gradient_rounded,
            Colors.blue
          ),
          ('Glass', BalanceCardType.glass, Icons.blur_on_rounded, Colors.cyan),
          (
            'Minimal',
            BalanceCardType.minimal,
            Icons.rectangle_rounded,
            Colors.grey
          ),
          (
            'Neon',
            BalanceCardType.neon,
            Icons.light_mode_rounded,
            Colors.purple
          ),
          (
            'Card',
            BalanceCardType.card,
            Icons.credit_card_rounded,
            Colors.indigo
          ),
          (
            'Modern',
            BalanceCardType.modern,
            Icons.auto_awesome_rounded,
            Colors.pink
          ),
          ('Custom', BalanceCardType.custom, Icons.tune_rounded, Colors.orange),
        ];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pilih Style Preset',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: styles.length,
              itemBuilder: (context, index) {
                final (label, type, icon, color) = styles[index];
                final isSelected = provider.currentStyle.type == type;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.updateType(type);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                color.withOpacity(0.2),
                                color.withOpacity(0.1),
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 32,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ============================================
// TAB 2: COLOR
// ============================================
class _ColorTab extends StatelessWidget {
  final BalanceCardProvider provider;

  const _ColorTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<BalanceCardProvider>(
      builder: (context, provider, _) {
        final style = provider.currentStyle;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Gradient Toggle
            _SwitchTile(
              title: 'Gunakan Gradient',
              subtitle: 'Aktifkan gradient warna',
              value: style.useGradientValue,
              onChanged: (_) => provider.toggleGradient(),
              icon: Icons.gradient_rounded,
            ),

            const SizedBox(height: 20),

            // Gradient Colors
            if (style.useGradientValue) ...[
              const Text(
                'Warna Gradient',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Color 1
              _ColorPickerTile(
                title: 'Warna 1',
                color: style.colors.isNotEmpty ? style.colors[0] : Colors.blue,
                onColorPicked: (color) {
                  final colors = List<Color>.from(style.colors);
                  if (colors.isEmpty)
                    colors.add(color);
                  else
                    colors[0] = color;
                  provider.updateColors(colors);
                },
              ),
              const SizedBox(height: 8),

              // Color 2
              _ColorPickerTile(
                title: 'Warna 2',
                color:
                    style.colors.length > 1 ? style.colors[1] : Colors.purple,
                onColorPicked: (color) {
                  final colors = List<Color>.from(style.colors);
                  while (colors.length < 2) colors.add(Colors.purple);
                  colors[1] = color;
                  provider.updateColors(colors);
                },
              ),
              const SizedBox(height: 8),

              // Color 3 (Optional)
              _ColorPickerTile(
                title: 'Warna 3 (Opsional)',
                color: style.colors.length > 2 ? style.colors[2] : Colors.pink,
                onColorPicked: (color) {
                  final colors = List<Color>.from(style.colors);
                  while (colors.length < 3) colors.add(Colors.pink);
                  colors[2] = color;
                  provider.updateColors(colors);
                },
              ),

              const SizedBox(height: 20),

              // Gradient Direction
              const Text(
                'Arah Gradient',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _GradientDirectionPicker(
                currentDirection: style.gradientDirectionValue,
                onDirectionChanged: (direction) {
                  provider.updateGradientDirection(direction);
                },
              ),
            ] else ...[
              // Solid Background Color
              _ColorPickerTile(
                title: 'Warna Background',
                color: style.backgroundColorValue ?? Colors.blue,
                onColorPicked: (color) {
                  provider.updateBackgroundColor(color);
                },
              ),
            ],

            const SizedBox(height: 20),

            // Text Color
            _ColorPickerTile(
              title: 'Warna Teks',
              subtitle: 'Kosongkan untuk otomatis',
              color: style.textColorValue ?? Colors.white,
              onColorPicked: (color) {
                provider.updateTextColor(color);
              },
              canClear: true,
              onClear: () => provider.updateTextColor(null),
            ),

            const SizedBox(height: 20),

            // Opacity
            _SliderTile(
              title: 'Opacity',
              value: style.opacityValue,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) => provider.updateOpacity(value),
              icon: Icons.opacity_rounded,
            ),
          ],
        );
      },
    );
  }
}

// ============================================
// TAB 3: SHAPE
// ============================================
class _ShapeTab extends StatelessWidget {
  final BalanceCardProvider provider;

  const _ShapeTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<BalanceCardProvider>(
      builder: (context, provider, _) {
        final style = provider.currentStyle;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Border Radius
            _SliderTile(
              title: 'Border Radius',
              value: style.borderRadiusValue,
              min: 0.0,
              max: 40.0,
              divisions: 40,
              onChanged: (value) => provider.updateBorderRadius(value),
              icon: Icons.rounded_corner_rounded,
            ),

            const SizedBox(height: 20),

            // Show Border
            _SwitchTile(
              title: 'Tampilkan Border',
              subtitle: 'Garis tepi card',
              value: style.showBorderValue,
              onChanged: (_) => provider.toggleBorder(),
              icon: Icons.border_style_rounded,
            ),

            if (style.showBorderValue) ...[
              const SizedBox(height: 20),

              // Border Color
              _ColorPickerTile(
                title: 'Warna Border',
                color: style.borderColorValue ?? Colors.grey,
                onColorPicked: (color) {
                  provider.updateBorderColor(color);
                },
              ),

              const SizedBox(height: 20),

              // Border Width
              _SliderTile(
                title: 'Ketebalan Border',
                value: style.borderWidthValue,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                onChanged: (value) => provider.updateBorderWidth(value),
                icon: Icons.line_weight_rounded,
              ),
            ],

            const SizedBox(height: 20),

            // Display Options
            const Text(
              'Tampilan Elemen',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _SwitchTile(
                    title: 'Icon Wallet',
                    value: style.showIcon,
                    onChanged: (_) => provider.toggleIcon(),
                    icon: Icons.account_balance_wallet_rounded,
                    compact: true,
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                  _SwitchTile(
                    title: 'Jumlah Dompet',
                    value: style.showWalletCount,
                    onChanged: (_) => provider.toggleWalletCount(),
                    icon: Icons.pie_chart_rounded,
                    compact: true,
                  ),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                  _SwitchTile(
                    title: 'Tanggal',
                    value: style.showDate,
                    onChanged: (_) => provider.toggleDate(),
                    icon: Icons.calendar_today_rounded,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================
// TAB 4: EFFECT (Shadow & Elevation)
// ============================================
class _EffectTab extends StatelessWidget {
  final BalanceCardProvider provider;

  const _EffectTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<BalanceCardProvider>(
      builder: (context, provider, _) {
        final style = provider.currentStyle;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Show Shadow
            _SwitchTile(
              title: 'Tampilkan Shadow',
              subtitle: 'Bayangan di bawah card',
              value: style.showShadowValue,
              onChanged: (_) => provider.toggleShadow(),
              icon: Icons.filter_drama_rounded,
            ),

            if (style.showShadowValue) ...[
              const SizedBox(height: 20),

              // Shadow Blur
              _SliderTile(
                title: 'Shadow Blur',
                value: style.shadowBlurValue,
                min: 0.0,
                max: 50.0,
                divisions: 50,
                onChanged: (value) => provider.updateShadowBlur(value),
                icon: Icons.blur_on_rounded,
              ),

              const SizedBox(height: 20),

              // Shadow Spread
              _SliderTile(
                title: 'Shadow Spread',
                value: style.shadowSpreadValue,
                min: 0.0,
                max: 20.0,
                divisions: 20,
                onChanged: (value) async {
                  final s = provider.currentStyle;
                  s.shadowSpread = value;
                  await provider.updateStyle(s);
                },
                icon: Icons.expand_rounded,
              ),
            ],

            const SizedBox(height: 20),

            // Elevation
            _SliderTile(
              title: 'Elevation',
              value: style.elevationValue,
              min: 0.0,
              max: 20.0,
              divisions: 20,
              onChanged: (value) => provider.updateElevation(value),
              icon: Icons.layers_rounded,
            ),

            const SizedBox(height: 32),

            // Reset Button
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showResetConfirm(context, provider);
                },
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Reset ke Default'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirm(BuildContext context, BalanceCardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset ke Default?'),
        content: const Text(
          'Semua pengaturan custom akan dikembalikan ke default.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateStyle(BalanceCardStyle.defaultGradient);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// HELPER WIDGETS
// ============================================

// Switch Tile
class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final bool compact;

  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          compact ? const EdgeInsets.symmetric(horizontal: 16) : null,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: value ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
    );
  }
}

// Slider Tile
class _SliderTile extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final IconData icon;

  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}

// Color Picker Tile
class _ColorPickerTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final ValueChanged<Color> onColorPicked;
  final bool canClear;
  final VoidCallback? onClear;

  const _ColorPickerTile({
    required this.title,
    this.subtitle,
    required this.color,
    required this.onColorPicked,
    this.canClear = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canClear && onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDialog<Color>(
                context: context,
                builder: (context) => ColorPickerDialog(
                  initialColor: color,
                  title: title,
                ),
              );
              if (picked != null) {
                onColorPicked(picked);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Gradient Direction Picker
class _GradientDirectionPicker extends StatelessWidget {
  final String currentDirection;
  final ValueChanged<String> onDirectionChanged;

  const _GradientDirectionPicker({
    required this.currentDirection,
    required this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final directions = [
      ('↘️', 'topLeft', 'Top Left'),
      ('↙️', 'topRight', 'Top Right'),
      ('↗️', 'bottomLeft', 'Bottom Left'),
      ('↖️', 'bottomRight', 'Bottom Right'),
      ('→', 'horizontal', 'Horizontal'),
      ('↓', 'vertical', 'Vertical'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: directions.map((direction) {
        final (emoji, value, label) = direction;
        final isSelected = currentDirection == value;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onDirectionChanged(value);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
