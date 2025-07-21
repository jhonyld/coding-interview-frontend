import 'package:coding_interview_frontend/features_modules/calculator/data/models/crypto_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/data/models/fiat_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/bloc/currency_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwapCurrency extends StatelessWidget {
  const SwapCurrency({
    super.key,
    required this.type,
    required this.selectedCrypto,
    required this.selectedFiat,
  });

  final ConversionType type;
  final CryptoCurrencyModel? selectedCrypto;
  final FiatCurrencyModel? selectedFiat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (selectedCrypto != null && selectedFiat != null) {
              context.read<CurrencyBloc>().add(SwapCurrencies());
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x33F59E0B), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: const Icon(Icons.swap_horiz, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
