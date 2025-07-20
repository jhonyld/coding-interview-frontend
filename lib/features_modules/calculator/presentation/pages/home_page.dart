import 'package:coding_interview_frontend/features_modules/calculator/data/models/crypto_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/data/models/fiat_currency_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/currency_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/currency_selector_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  //final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _amountFocusNode.addListener(_onFocusChange);
  }

  // void _onFocusChange() {
  //   if (!_amountFocusNode.hasFocus) {
  //     context.read<CurrencyBloc>().add(FetchConversionRate());
  //   }
  // }

  @override
  void dispose() {
    // _amountFocusNode.removeListener(_onFocusChange);
    // _amountFocusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE0F2FE), Colors.white],
                ),
              ),
            ),
            Positioned(
              right: width * -1.70,
              top: height * -0.40,
              child: Container(
                width: width * 2.2,
                height: height * 1.6,
                decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
              ),
            ),
            BlocListener<CurrencyBloc, CurrencyState>(
              listener: (context, state) {
                if (state is CurrencyLoaded && state.error != null && state.error!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
                  );
                }
              },
              child: Center(
                child: BlocBuilder<CurrencyBloc, CurrencyState>(
                  builder: (context, state) {
                    if (state is CurrencyLoading || state is CurrencyInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CurrencyError) {
                      return Center(child: Text(state.message));
                    } else if (state is CurrencyLoaded) {
                      final cryptocurrencies = state.cryptocurrencies;
                      final fiatCurrencies = state.fiatCurrencies;
                      final selectedCrypto = state.selectedCrypto;
                      final selectedFiat = state.selectedFiat;
                      final inputAmount = state.inputAmount;
                      final conversionResult = state.conversionResult;
                      final isFetchingRate = state.isFetchingRate;
                      final error = state.error;
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Currency selection row
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _CurrencySelectorButton(
                                        label: localizations.haveLabel,
                                        currency: selectedCrypto,
                                        isActive: true,
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder:
                                                (context) => CurrencySelectorModal(
                                                  currencies: cryptocurrencies,
                                                  selectedCurrency: selectedCrypto,
                                                  onCurrencySelected:
                                                      (currency) => context
                                                          .read<CurrencyBloc>()
                                                          .add(SelectCryptoCurrency(currency)),
                                                  title: localizations.cryptoModalTitle,
                                                  isCrypto: true,
                                                ),
                                          );
                                        },
                                      ),

                                      _SwapCurrency(
                                        selectedCrypto: selectedCrypto,
                                        selectedFiat: selectedFiat,
                                      ),
                                      _CurrencySelectorButton(
                                        label: localizations.wantLabel,
                                        currency: selectedFiat,
                                        isActive: true,
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder:
                                                (context) => CurrencySelectorModal(
                                                  currencies: fiatCurrencies,
                                                  selectedCurrency: selectedFiat,
                                                  onCurrencySelected:
                                                      (currency) => context
                                                          .read<CurrencyBloc>()
                                                          .add(SelectFiatCurrency(currency)),
                                                  title: localizations.fiatModalTitle,
                                                  isCrypto: false,
                                                ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFF4B53F), width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    children: [
                                      Text(
                                        selectedCrypto?.symbol ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFFF4B53F),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          onChanged: (value) {
                                            _amountController.text = value.replaceAll(",", ".");
                                            final parsed =
                                                double.tryParse(_amountController.text) ?? 0;
                                            context.read<CurrencyBloc>().add(AmountChanged(parsed));
                                            // No fetch here
                                          },
                                          controller: _amountController,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "0.00",
                                          ),
                                          keyboardType: TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Exchange info
                                _ExchangeInfoRow(
                                  label: localizations.estimatedRate,
                                  value:
                                      conversionResult != null && inputAmount > 0
                                          ? '= 	${(conversionResult / inputAmount).toStringAsFixed(2)} ${selectedFiat?.symbol ?? ''}'
                                          : '-',
                                  bold: false,
                                ),
                                const SizedBox(height: 8),
                                _ExchangeInfoRow(
                                  label: localizations.youReceive,
                                  value:
                                      conversionResult != null && inputAmount > 0
                                          ? '= ${conversionResult.toStringAsFixed(2)} ${selectedFiat?.symbol ?? ''}'
                                          : '-',
                                  bold: false,
                                ),
                                const SizedBox(height: 8),
                                _ExchangeInfoRow(
                                  label: localizations.estimatedTime,
                                  value: '= 1 Min',
                                  bold: false,
                                ),
                                const SizedBox(height: 20),
                                // Action button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF59E0B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed:
                                        inputAmount > 0 &&
                                                selectedCrypto != null &&
                                                selectedFiat != null &&
                                                !isFetchingRate
                                            ? () {
                                              context.read<CurrencyBloc>().add(
                                                FetchConversionRate(),
                                              );
                                            }
                                            : null,
                                    child:
                                        isFetchingRate
                                            ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(
                                              localizations.exchangeButton,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapCurrency extends StatelessWidget {
  const _SwapCurrency({required this.selectedCrypto, required this.selectedFiat});

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

class _CurrencySelectorButton extends StatelessWidget {
  final String label;
  final dynamic currency;
  final bool isActive;
  final VoidCallback onTap;

  const _CurrencySelectorButton({
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

class _ExchangeInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _ExchangeInfoRow({required this.label, required this.value, required this.bold});

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
