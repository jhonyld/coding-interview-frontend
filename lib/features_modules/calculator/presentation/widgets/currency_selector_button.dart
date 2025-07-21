import 'package:flutter/material.dart';

class CurrencySelectorButton extends StatelessWidget {
  final String label;
  final dynamic currency;
  final bool isActive;
  final VoidCallback onTap;

  const CurrencySelectorButton({
    super.key,
    required this.label,
    required this.currency,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF6B7280),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: const Color(0x33F59E0B),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currency?.logoPath != null)
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 12,
                    backgroundImage: AssetImage(currency.logoPath),
                  ),
                const SizedBox(width: 8),
                Text(
                  currency?.symbol ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: Color(0xFFF59E0B)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
