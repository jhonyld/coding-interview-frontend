import 'package:coding_interview_frontend/features_modules/calculator/data/models/crypto_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/data/models/fiat_currency_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/currency_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/currency_selector_modal.dart';
import 'package:flutter/services.dart';

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
                                // Currency selection row
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _CurrencySelectorButton(
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
                                      _SwapCurrency(
                                        type: state.type,
                                        selectedCrypto: selectedCrypto,
                                        selectedFiat: selectedFiat,
                                      ),
                                      _CurrencySelectorButton(
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
                                _AmountTextField(
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
                                // Exchange info
                                _ExchangeInfoRow(
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
                                _ExchangeInfoRow(
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
                                _ExchangeInfoRow(
                                  label: localizations.estimatedTime,
                                  value: '= 1 Min',
                                  bold: false,
                                ),
                                const SizedBox(height: 20),
                                _ExchangeButton(
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

class _AmountTextField extends StatefulWidget {
  const _AmountTextField({
    this.selectedCrypto,
    this.selectedFiat,
    required this.amountController,
    required this.type,
  });

  final CryptoCurrencyModel? selectedCrypto;
  final FiatCurrencyModel? selectedFiat;
  final TextEditingController amountController;
  final ConversionType type;

  @override
  State<_AmountTextField> createState() => _AmountTextFieldState();
}

class _AmountTextFieldState extends State<_AmountTextField> {
  String _rawDigits = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.amountController.text = _formatAmount(0);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatAmount(int value) {
    return '${value.toString()}.00';
  }

  void _updateController() {
    int intValue = int.tryParse(_rawDigits) ?? 0;
    widget.amountController.text = _formatAmount(intValue);
    widget.amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.amountController.text.length),
    );
    context.read<CurrencyBloc>().add(AmountChanged(intValue.toDouble()));
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.backspace) {
        if (_rawDigits.isNotEmpty) {
          setState(() {
            _rawDigits = _rawDigits.substring(0, _rawDigits.length - 1);
            _updateController();
          });
        }
      } else if (key.keyLabel.length == 1 && RegExp(r'\d').hasMatch(key.keyLabel)) {
        setState(() {
          _rawDigits += key.keyLabel;
          _updateController();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol =
        widget.type == ConversionType.cryptoToFiat
            ? widget.selectedCrypto?.symbol ?? ''
            : widget.selectedFiat?.symbol ?? '';
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF4B53F), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(
            symbol,
            style: const TextStyle(
              color: Color(0xFFF4B53F),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: KeyboardListener(
              focusNode: _focusNode,

              onKeyEvent: _handleKey,
              child: GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: AbsorbPointer(
                  child: TextField(
                    controller: widget.amountController,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00"),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExchangeButton extends StatelessWidget {
  const _ExchangeButton({
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

class _SwapCurrency extends StatelessWidget {
  const _SwapCurrency({
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
