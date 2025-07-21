import 'package:coding_interview_frontend/features_modules/calculator/data/models/crypto_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/data/models/fiat_currency_model.dart';
import 'package:coding_interview_frontend/features_modules/calculator/presentation/bloc/currency_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmountTextField extends StatefulWidget {
  const AmountTextField({
    super.key,
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
  State<AmountTextField> createState() => _AmountTextFieldState();
}

class _AmountTextFieldState extends State<AmountTextField> {
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
