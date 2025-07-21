import 'package:flutter/material.dart';

class ExchangeInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const ExchangeInfoRow({super.key, required this.label, required this.value, required this.bold});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
