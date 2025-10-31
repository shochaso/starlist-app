import 'package:flutter/material.dart';

import '../../domain/category.dart';

class StarFilterBar extends StatelessWidget {
  const StarFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final StarDataCategory? selectedCategory;
  final ValueChanged<StarDataCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final filters = StarDataCategories.filters;
    return SizedBox(
      height: 48,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: ListView.separated(
          key: ValueKey(selectedCategory),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final category = filters[index];
            final isSelected = selectedCategory == category;
            return ChoiceChip(
              label: Text(category.label),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              elevation: 0,
              pressElevation: 0,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: filters.length,
        ),
      ),
    );
  }
}
