import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/currency_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/currency_selector_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_amountFocusNode.hasFocus) {
      context.read<CurrencyBloc>().add(FetchConversionRate());
    }
  }

  @override
  void dispose() {
    _amountFocusNode.removeListener(_onFocusChange);
    _amountFocusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    const String tax = '0.5%';
    const String estimatedTime = '2 min';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(loc.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: BlocBuilder<CurrencyBloc, CurrencyState>(
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
            if (_amountController.text != (inputAmount == 0.0 ? '' : inputAmount.toString())) {
              _amountController.text = inputAmount == 0.0 ? '' : inputAmount.toString();
            }
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: Card(
                    elevation: 8,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Currency selectors row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Crypto selector
                              Expanded(
                                child: _CurrencyButton(
                                  selected: selectedCrypto,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder:
                                          (context) => CurrencySelectorModal(
                                            currencies: cryptocurrencies,
                                            selectedCurrency: selectedCrypto,
                                            onCurrencySelected:
                                                (currency) => context.read<CurrencyBloc>().add(
                                                  SelectCryptoCurrency(currency),
                                                ),
                                            title: 'Select Cryptocurrency',
                                            isCrypto: true,
                                          ),
                                    );
                                  },
                                ),
                              ),
                              // Switch button
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Material(
                                  color: Colors.blueAccent,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                                    onPressed: () {
                                      if (selectedCrypto != null && selectedFiat != null) {
                                        context.read<CurrencyBloc>().add(
                                          SelectCryptoCurrency(
                                            cryptocurrencies.firstWhere(
                                              (c) => c.id == selectedFiat.id,
                                              orElse: () => selectedCrypto,
                                            ),
                                          ),
                                        );
                                        context.read<CurrencyBloc>().add(
                                          SelectFiatCurrency(
                                            fiatCurrencies.firstWhere(
                                              (f) => f.id == selectedCrypto.id,
                                              orElse: () => selectedFiat,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    tooltip: 'Switch',
                                  ),
                                ),
                              ),
                              // Fiat selector
                              Expanded(
                                child: _CurrencyButton(
                                  selected: selectedFiat,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder:
                                          (context) => CurrencySelectorModal(
                                            currencies: fiatCurrencies,
                                            selectedCurrency: selectedFiat,
                                            onCurrencySelected:
                                                (currency) => context.read<CurrencyBloc>().add(
                                                  SelectFiatCurrency(currency),
                                                ),
                                            title: 'Select FIAT Currency',
                                            isCrypto: false,
                                          ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Amount input
                          Text(
                            loc.amountLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF5F6FA),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              hintText: '0.00',
                              prefixIcon: const Icon(Icons.edit, color: Colors.blueAccent),
                            ),
                            onChanged: (value) {
                              final amount = double.tryParse(value) ?? 0.0;
                              context.read<CurrencyBloc>().add(AmountChanged(amount));
                            },
                          ),
                          const SizedBox(height: 18),
                          // Tax and estimated time row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.percent, color: Colors.grey, size: 18),
                                  const SizedBox(width: 4),
                                  Text('Tax: $tax', style: theme.textTheme.bodySmall),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.grey, size: 18),
                                  const SizedBox(width: 4),
                                  Text('Est. $estimatedTime', style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Exchange button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed:
                                  inputAmount > 0 && selectedCrypto != null && selectedFiat != null
                                      ? () {
                                        // Conversion happens on focus loss
                                      }
                                      : null,
                              child: const Text('Exchange'),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Result
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child:
                                  isFetchingRate
                                      ? const CircularProgressIndicator()
                                      : Text(
                                        conversionResult != null
                                            ? loc.resultLabel
                                                .replaceFirst(
                                                  '{value}',
                                                  conversionResult.toString(),
                                                )
                                                .replaceFirst(
                                                  '{currency}',
                                                  selectedFiat?.symbol ?? '',
                                                )
                                            : error != null
                                            ? loc.errorLabel.replaceFirst('{error}', error!)
                                            : loc.enterAmountHint,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _CurrencyButton extends StatelessWidget {
  final dynamic selected;
  final VoidCallback onTap;

  const _CurrencyButton({required this.selected, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              CircleAvatar(
                backgroundImage: AssetImage(selected.logoPath),
                radius: 16,
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                selected.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ] else ...[
              const Icon(Icons.currency_exchange, color: Colors.grey),
              const SizedBox(width: 10),
              const Text('Select', style: TextStyle(color: Colors.grey)),
            ],
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
