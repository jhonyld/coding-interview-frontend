import 'package:coding_interview_frontend/features_modules/calculator/data/models/crypto_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/data/models/fiat_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/widgets/amount_text_field.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/widgets/currency_selector_button.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/widgets/exchange_button.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/widgets/exchange_info_row.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/widgets/swap_currency.dart';
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
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final localizations = AppLocalizations.of(context)!;

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
                    } else if (state is CurrencyLoaded) {
                      final cryptocurrencies = state.cryptocurrencies;
                      final fiatCurrencies = state.fiatCurrencies;
                      final selectedCrypto = state.selectedCrypto;
                      final selectedFiat = state.selectedFiat;
                      final inputAmount = state.inputAmount;
                      final conversionResult = state.conversionResult;
                      final isFetchingRate = state.isFetchingRate;
                      final isCryptoToFiat = state.type == ConversionType.cryptoToFiat;
                      final leftCurrency = isCryptoToFiat ? selectedCrypto : selectedFiat;
                      final rightCurrency = isCryptoToFiat ? selectedFiat : selectedCrypto;
                      final leftListCurrencies = isCryptoToFiat ? cryptocurrencies : fiatCurrencies;
                      final rightListCurrencies =
                          isCryptoToFiat ? fiatCurrencies : cryptocurrencies;

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
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CurrencySelectorButton(
                                        label: localizations.haveLabel,
                                        currency: leftCurrency,
                                        isActive: true,
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder:
                                                (context) => CurrencySelectorModal(
                                                  currencies: leftListCurrencies,
                                                  selectedCurrency: leftCurrency,
                                                  onCurrencySelected: (currency) {
                                                    if (state.type == ConversionType.cryptoToFiat) {
                                                      context.read<CurrencyBloc>().add(
                                                        SelectCryptoCurrency(currency),
                                                      );
                                                    } else {
                                                      context.read<CurrencyBloc>().add(
                                                        SelectFiatCurrency(currency),
                                                      );
                                                    }
                                                  },
                                                  title:
                                                      state.type == ConversionType.cryptoToFiat
                                                          ? localizations.cryptoModalTitle
                                                          : localizations.fiatModalTitle,
                                                  isCrypto:
                                                      state.type == ConversionType.cryptoToFiat,
                                                ),
                                          );
                                        },
                                      ),
                                      SwapCurrency(
                                        type: state.type,
                                        selectedCrypto: selectedCrypto,
                                        selectedFiat: selectedFiat,
                                      ),
                                      CurrencySelectorButton(
                                        label: localizations.wantLabel,
                                        currency: rightCurrency,
                                        isActive: true,
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder:
                                                (context) => CurrencySelectorModal(
                                                  currencies: rightListCurrencies,
                                                  selectedCurrency: rightCurrency,
                                                  onCurrencySelected: (currency) {
                                                    if (state.type == ConversionType.cryptoToFiat) {
                                                      context.read<CurrencyBloc>().add(
                                                        SelectFiatCurrency(currency),
                                                      );
                                                    } else {
                                                      context.read<CurrencyBloc>().add(
                                                        SelectCryptoCurrency(currency),
                                                      );
                                                    }
                                                  },
                                                  title:
                                                      state.type == ConversionType.cryptoToFiat
                                                          ? localizations.fiatModalTitle
                                                          : localizations.cryptoModalTitle,
                                                  isCrypto:
                                                      state.type != ConversionType.cryptoToFiat,
                                                ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                AmountTextField(
                                  selectedCrypto:
                                      state.type == ConversionType.cryptoToFiat
                                          ? selectedCrypto
                                          : null,
                                  selectedFiat:
                                      state.type != ConversionType.cryptoToFiat
                                          ? selectedFiat
                                          : null,
                                  amountController: _amountController,
                                  type: state.type,
                                ),
                                const SizedBox(height: 24),
                                ExchangeInfoRow(
                                  label: localizations.estimatedRate,
                                  value:
                                      conversionResult != null && inputAmount > 0
                                          ? '=  	${(conversionResult / inputAmount).toStringAsFixed(2)} '
                                              '${rightCurrency is CryptoCurrencyModel
                                                  ? rightCurrency.symbol
                                                  : rightCurrency is FiatCurrencyModel
                                                  ? rightCurrency.symbol
                                                  : ''}'
                                          : '-',
                                  bold: false,
                                ),
                                const SizedBox(height: 8),
                                ExchangeInfoRow(
                                  label: localizations.youReceive,
                                  value:
                                      conversionResult != null && inputAmount > 0
                                          ? '= ${conversionResult.toStringAsFixed(2)} '
                                              '${rightCurrency is CryptoCurrencyModel
                                                  ? rightCurrency.symbol
                                                  : rightCurrency is FiatCurrencyModel
                                                  ? rightCurrency.symbol
                                                  : ''}'
                                          : '-',
                                  bold: false,
                                ),
                                const SizedBox(height: 8),
                                ExchangeInfoRow(
                                  label: localizations.estimatedTime,
                                  value: '= 1 Min',
                                  bold: false,
                                ),
                                const SizedBox(height: 20),
                                ExchangeButton(
                                  inputAmount: inputAmount,
                                  selectedCrypto: selectedCrypto,
                                  selectedFiat: selectedFiat,
                                  isFetchingRate: isFetchingRate,
                                  localizations: localizations,
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
