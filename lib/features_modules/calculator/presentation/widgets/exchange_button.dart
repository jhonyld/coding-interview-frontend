import 'package:coding_interview_frontend/features_modules/calculator/data/models/crypto_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/data/models/fiat_currency_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExchangeButton extends StatelessWidget {
  const ExchangeButton({
    super.key,
    required this.inputAmount,
    required this.selectedCrypto,
    required this.selectedFiat,
    required this.isFetchingRate,
    required this.localizations,
  });

  final double inputAmount;
  final CryptoCurrencyModel? selectedCrypto;
  final FiatCurrencyModel? selectedFiat;
  final bool isFetchingRate;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
        onPressed:
            inputAmount >= 10 && selectedCrypto != null && selectedFiat != null && !isFetchingRate
                ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exchange successful!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                : null,
        child:
            isFetchingRate
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                : Text(localizations.exchangeButton, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
