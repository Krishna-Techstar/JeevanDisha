import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  static const List<_NavItemData> _items = [
    _NavItemData(icon: '🏠', label: 'Home'),
    _NavItemData(icon: '✦', label: 'Journey'),
    _NavItemData(icon: '📖', label: 'Study'),
    _NavItemData(icon: '🎯', label: 'Goals'),
    _NavItemData(icon: '◉', label: 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xCCFFFFFF),
            border: Border(
              top: BorderSide(
                color: Color(0xCCFFFFFF),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = currentIndex == index;

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? JeevanColors.aqua : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      JeevanColors.aqua.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.icon,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Manrope',
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? JeevanColors.tealDark
                            : JeevanColors.textSec,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;
}
