import 'package:flutter/material.dart';

class IconSelector extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onChanged;

  const IconSelector({
    super.key,
    required this.selectedIcon,
    required this.onChanged,
  });

  // Icon name dan IconData mapping
  static const Map<String, IconData> availableIcons = {
    // Makanan & Minuman
    'restaurant': Icons.restaurant_rounded,
    'fastfood': Icons.fastfood_rounded,
    'local_cafe': Icons.local_cafe_rounded,
    'local_bar': Icons.local_bar_rounded,
    'bakery_dining': Icons.bakery_dining_rounded,
    'ramen_dining': Icons.ramen_dining_rounded,

    // Belanja
    'shopping_bag': Icons.shopping_bag_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'storefront': Icons.storefront_rounded,
    'local_mall': Icons.local_mall_rounded,

    // Transportasi
    'directions_car': Icons.directions_car_rounded,
    'two_wheeler': Icons.two_wheeler_rounded,
    'local_gas_station': Icons.local_gas_station_rounded,
    'directions_bus': Icons.directions_bus_rounded,
    'train': Icons.train_rounded,
    'flight': Icons.flight_rounded,
    'local_taxi': Icons.local_taxi_rounded,

    // Rumah & Utilitas
    'home': Icons.home_rounded,
    'bolt': Icons.bolt_rounded,
    'water_drop': Icons.water_drop_rounded,
    'wifi': Icons.wifi_rounded,
    'phone_android': Icons.phone_android_rounded,
    'router': Icons.router_rounded,

    // Kesehatan
    'local_hospital': Icons.local_hospital_rounded,
    'medical_services': Icons.medical_services_rounded,
    'medication': Icons.medication_rounded,
    'healing': Icons.healing_rounded,

    // Pendidikan
    'school': Icons.school_rounded,
    'menu_book': Icons.menu_book_rounded,
    'auto_stories': Icons.auto_stories_rounded,
    'science': Icons.science_rounded,

    // Hiburan
    'sports_esports': Icons.sports_esports_rounded,
    'movie': Icons.movie_rounded,
    'music_note': Icons.music_note_rounded,
    'theaters': Icons.theaters_rounded,
    'sports_soccer': Icons.sports_soccer_rounded,
    'sports_basketball': Icons.sports_basketball_rounded,

    // Lifestyle
    'fitness_center': Icons.fitness_center_rounded,
    'spa': Icons.spa_rounded,
    'checkroom': Icons.checkroom_rounded,
    'dry_cleaning': Icons.dry_cleaning_rounded,
    'content_cut': Icons.content_cut_rounded,

    // Hewan
    'pets': Icons.pets_rounded,
    'cruelty_free': Icons.cruelty_free_rounded,

    // Keuangan & Bisnis
    'work': Icons.work_rounded,
    'business_center': Icons.business_center_rounded,
    'account_balance': Icons.account_balance_rounded,
    'credit_card': Icons.credit_card_rounded,
    'payments': Icons.payments_rounded,
    'savings': Icons.savings_rounded,
    'trending_up': Icons.trending_up_rounded,
    'attach_money': Icons.attach_money_rounded,
    'monetization_on': Icons.monetization_on_rounded,

    // Gift & Charity
    'card_giftcard': Icons.card_giftcard_rounded,
    'redeem': Icons.redeem_rounded,
    'volunteer_activism': Icons.volunteer_activism_rounded,
    'favorite': Icons.favorite_rounded,

    // Transfer
    'swap_horiz': Icons.swap_horiz_rounded,
    'sync_alt': Icons.sync_alt_rounded,
    'compare_arrows': Icons.compare_arrows_rounded,

    // Lainnya
    'receipt_long': Icons.receipt_long_rounded,
    'sell': Icons.sell_rounded,
    'local_offer': Icons.local_offer_rounded,
    'handyman': Icons.handyman_rounded,
    'build': Icons.build_rounded,
    'camera_alt': Icons.camera_alt_rounded,
    'child_friendly': Icons.child_friendly_rounded,
    'cake': Icons.cake_rounded,
    'celebration': Icons.celebration_rounded,
    'beach_access': Icons.beach_access_rounded,
    'luggage': Icons.luggage_rounded,
    'more_horiz': Icons.more_horiz_rounded,
  };

  // Get IconData from name
  static IconData getIconData(String? iconName) {
    return availableIcons[iconName] ?? Icons.receipt_long_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconNames = availableIcons.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_emotions_rounded,
              size: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Pilih Ikon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: iconNames.length,
            itemBuilder: (context, index) {
              final iconName = iconNames[index];
              final iconData = availableIcons[iconName]!;
              final isSelected = selectedIcon == iconName;

              return GestureDetector(
                onTap: () => onChanged(iconName),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    size: 22,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              );
            },
          ),
        ),

        // Preview selected icon
        if (selectedIcon.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  getIconData(selectedIcon),
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Icon terpilih',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
