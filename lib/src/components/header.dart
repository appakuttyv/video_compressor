
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Header extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const Header({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (showBack)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: onBack,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 24,
                          color: isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                        ),
                      ),
                    ),
                  ),
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  width: 32,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onThemeToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                size: 20,
                color: isDarkMode ? Colors.yellow.shade300 : Colors.blueGrey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
