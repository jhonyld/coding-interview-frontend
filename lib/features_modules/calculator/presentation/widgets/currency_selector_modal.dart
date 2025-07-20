import 'package:flutter/material.dart';

class CurrencySelectorModal extends StatelessWidget {
  final List<dynamic> currencies;
  final dynamic selectedCurrency;
  final Function(dynamic) onCurrencySelected;
  final String title;
  final bool isCrypto;

  const CurrencySelectorModal({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
    required this.onCurrencySelected,
    required this.title,
    required this.isCrypto,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(title: title),
            _CurrencyList(
              currencies: currencies,
              selectedCurrency: selectedCurrency,
              onCurrencySelected: onCurrencySelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyList extends StatelessWidget {
  const _CurrencyList({
    required this.currencies,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  final List currencies;
  final dynamic selectedCurrency;
  final Function(dynamic) onCurrencySelected;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ListView.separated(
          itemCount: currencies.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final currency = currencies[index];
            final isSelected = selectedCurrency?.id == currency.id;
            return InkWell(
              //borderRadius: BorderRadius.circular(12),
              onTap: () {
                onCurrencySelected(currency);
                Navigator.of(context).pop();
              },
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.asset(
                          currency.logoPath,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currency.symbol,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currency.name,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      child:
                          isSelected
                              ? Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              )
                              : Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF6B7280), width: 2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
