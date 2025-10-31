import 'package:flutter/material.dart';

class ImportTypeOption extends StatelessWidget {
  const ImportTypeOption({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
    required this.isDarkTheme,
    this.leadingIcon,
    this.minWidth = 160,
    this.maxWidth = 260,
  });

  final String title;
  final String? subtitle;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;
  final bool isDarkTheme;
  final IconData? leadingIcon;
  final double minWidth;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final Color activeBackground =
        isDarkTheme ? const Color(0xFF2A2A2A) : Colors.white;
    final Color inactiveBackground =
        isDarkTheme ? const Color(0xFF262626) : const Color(0xFFF8FAFC);
    final Color borderColor = isSelected
        ? accentColor
        : (isDarkTheme ? const Color(0xFF404040) : const Color(0xFFE2E8F0));
    final Color titleColor = isDarkTheme ? Colors.white : Colors.black87;
    final Color subtitleColor = isDarkTheme ? Colors.white60 : Colors.black54;
    final Color descriptionColor =
        isDarkTheme ? Colors.white54 : Colors.black45;

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      scale: isSelected ? 1.0 : 0.98,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? activeBackground : inactiveBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leadingIcon != null)
                  Container(
                    margin: const EdgeInsets.only(right: 12, top: 2),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: accentColor,
                      size: 18,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (description != null && description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description!,
                          style: TextStyle(
                            color: descriptionColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: accentColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
