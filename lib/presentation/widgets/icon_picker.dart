import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class IconPicker extends StatefulWidget {
  final IconData? selectedIcon;
  final ValueChanged<IconData> onIconSelected;

  const IconPicker({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  static const List<IconData> _availableIcons = [
    // Food & Dining
    Icons.restaurant,
    Icons.fastfood,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.local_pizza,
    Icons.lunch_dining,
    Icons.dinner_dining,
    Icons.breakfast_dining,
    Icons.ramen_dining,
    Icons.icecream,
    Icons.cake,
    
    // Shopping
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.local_mall,
    Icons.store,
    Icons.storefront,
    Icons.checkroom,
    
    // Transportation
    Icons.directions_car,
    Icons.directions_bus,
    Icons.directions_subway,
    Icons.local_taxi,
    Icons.two_wheeler,
    Icons.flight,
    Icons.train,
    Icons.directions_bike,
    Icons.local_shipping,
    
    // Entertainment
    Icons.movie,
    Icons.theaters,
    Icons.sports_esports,
    Icons.sports_soccer,
    Icons.sports_basketball,
    Icons.music_note,
    Icons.headphones,
    Icons.camera_alt,
    Icons.photo_camera,
    
    // Health & Fitness
    Icons.local_hospital,
    Icons.medical_services,
    Icons.medication,
    Icons.fitness_center,
    Icons.spa,
    Icons.self_improvement,
    Icons.favorite,
    
    // Education
    Icons.school,
    Icons.menu_book,
    Icons.library_books,
    Icons.auto_stories,
    Icons.edit_note,
    
    // Home & Living
    Icons.home,
    Icons.house,
    Icons.apartment,
    Icons.bed,
    Icons.chair,
    Icons.weekend,
    Icons.kitchen,
    Icons.shower,
    Icons.lightbulb,
    Icons.water_drop,
    Icons.bolt,
    
    // Bills & Utilities
    Icons.receipt_long,
    Icons.receipt,
    Icons.phone_android,
    Icons.wifi,
    Icons.router,
    Icons.tv,
    
    // Finance
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.savings,
    Icons.credit_card,
    Icons.payment,
    Icons.attach_money,
    Icons.currency_exchange,
    Icons.trending_up,
    Icons.trending_down,
    
    // Work & Business
    Icons.work,
    Icons.business,
    Icons.business_center,
    Icons.laptop,
    Icons.computer,
    Icons.print,
    
    // Gifts & Donations
    Icons.card_giftcard,
    Icons.redeem,
    Icons.volunteer_activism,
    Icons.favorite_border,
    
    // Pets
    Icons.pets,
    
    // Travel
    Icons.luggage,
    Icons.beach_access,
    Icons.hotel,
    Icons.local_activity,
    Icons.map,
    
    // Other
    Icons.category,
    Icons.star,
    Icons.bookmark,
    Icons.label,
    Icons.local_offer,
    Icons.loyalty,
    Icons.extension,
    Icons.palette,
    Icons.brush,
    Icons.build,
    Icons.handyman,
    Icons.construction,
    Icons.cleaning_services,
    Icons.local_laundry_service,
    Icons.dry_cleaning,
    Icons.child_care,
    Icons.elderly,
    Icons.accessible,
    Icons.celebration,
    Icons.emoji_events,
    Icons.military_tech,
  ];

  String _searchQuery = '';
  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filteredIcons = _searchQuery.isEmpty
        ? _availableIcons
        : _availableIcons.where((icon) {
            final iconName = _getIconName(icon).toLowerCase();
            return iconName.contains(_searchQuery.toLowerCase());
          }).toList();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chọn biểu tượng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm biểu tượng...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredIcons.length,
                itemBuilder: (context, index) {
                  final icon = filteredIcons[index];
                  final isSelected = _selectedIcon == icon;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedIcon = icon);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.primaryDark.withAlpha(40)
                                : AppColors.primaryLight.withAlpha(40))
                            : (isDark
                                ? AppColors.cardDark
                                : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: isSelected
                            ? (isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight)
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIcon == null
                    ? null
                    : () {
                        widget.onIconSelected(_selectedIcon!);
                        Navigator.pop(context);
                      },
                child: const Text('Chọn'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    // Simple icon name extraction for search
    return icon.toString().split('(').last.split(')').first;
  }
}
