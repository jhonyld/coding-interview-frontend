import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/crypto_currency_model.dart';
import '../../data/models/fiat_currency_model.dart';
import '../../data/repositories/currency_repository.dart';

// Events
abstract class CurrencyEvent {}

class LoadCurrencies extends CurrencyEvent {}

class SelectCryptoCurrency extends CurrencyEvent {
  final CryptoCurrencyModel crypto;
  SelectCryptoCurrency(this.crypto);
}

class SelectFiatCurrency extends CurrencyEvent {
  final FiatCurrencyModel fiat;
  SelectFiatCurrency(this.fiat);
}

class AmountChanged extends CurrencyEvent {
  final double amount;
  AmountChanged(this.amount);
}

class FetchConversionRate extends CurrencyEvent {}

class SwapCurrencies extends CurrencyEvent {}

// States
abstract class CurrencyState {}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final List<CryptoCurrencyModel> cryptocurrencies;
  final List<FiatCurrencyModel> fiatCurrencies;
  final CryptoCurrencyModel? selectedCrypto;
  final FiatCurrencyModel? selectedFiat;
  final double inputAmount;
  final double? conversionResult;
  final bool isFetchingRate;
  final String? error;

  CurrencyLoaded({
    required this.cryptocurrencies,
    required this.fiatCurrencies,
    this.selectedCrypto,
    this.selectedFiat,
    this.inputAmount = 0.0,
    this.conversionResult,
    this.isFetchingRate = false,
    this.error,
  });

  CurrencyLoaded copyWith({
    List<CryptoCurrencyModel>? cryptocurrencies,
    List<FiatCurrencyModel>? fiatCurrencies,
    CryptoCurrencyModel? selectedCrypto,
    FiatCurrencyModel? selectedFiat,
    double? inputAmount,
    double? conversionResult,
    bool? isFetchingRate,
    String? error,
  }) {
    return CurrencyLoaded(
      cryptocurrencies: cryptocurrencies ?? this.cryptocurrencies,
      fiatCurrencies: fiatCurrencies ?? this.fiatCurrencies,
      selectedCrypto: selectedCrypto ?? this.selectedCrypto,
      selectedFiat: selectedFiat ?? this.selectedFiat,
      inputAmount: inputAmount ?? this.inputAmount,
      conversionResult: conversionResult,
      isFetchingRate: isFetchingRate ?? this.isFetchingRate,
      error: error,
    );
  }
}

class CurrencyError extends CurrencyState {
  final String message;
  CurrencyError(this.message);
}

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyRepository repository;

  CurrencyBloc(this.repository) : super(CurrencyInitial()) {
    on<LoadCurrencies>(_onLoadCurrencies);
    on<SelectCryptoCurrency>(_onSelectCrypto);
    on<SelectFiatCurrency>(_onSelectFiat);
    on<AmountChanged>(_onAmountChanged);
    on<FetchConversionRate>(_onFetchConversionRate);
    on<SwapCurrencies>(_onSwapCurrencies);
  }

  Future<void> _onLoadCurrencies(LoadCurrencies event, Emitter<CurrencyState> emit) async {
    emit(CurrencyLoading());
    try {
      final data = await repository.getCurrencies();
      emit(
        CurrencyLoaded(
          cryptocurrencies: data.cryptocurrencies,
          fiatCurrencies: data.fiatCurrencies,
          selectedCrypto: data.cryptocurrencies.isNotEmpty ? data.cryptocurrencies[0] : null,
          selectedFiat: data.fiatCurrencies.isNotEmpty ? data.fiatCurrencies[0] : null,
        ),
      );
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  void _onSelectCrypto(SelectCryptoCurrency event, Emitter<CurrencyState> emit) {
    if (state is CurrencyLoaded) {
      final s = state as CurrencyLoaded;
      emit(s.copyWith(selectedCrypto: event.crypto, conversionResult: null));
    }
  }

  void _onSelectFiat(SelectFiatCurrency event, Emitter<CurrencyState> emit) {
    if (state is CurrencyLoaded) {
      final s = state as CurrencyLoaded;
      emit(s.copyWith(selectedFiat: event.fiat, conversionResult: null));
    }
  }

  void _onAmountChanged(AmountChanged event, Emitter<CurrencyState> emit) {
    if (state is CurrencyLoaded) {
      final s = state as CurrencyLoaded;
      emit(s.copyWith(inputAmount: event.amount, conversionResult: null));
    }
  }

  Future<void> _onFetchConversionRate(
    FetchConversionRate event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state is CurrencyLoaded) {
      final s = state as CurrencyLoaded;
      if (s.selectedCrypto != null && s.selectedFiat != null && s.inputAmount > 0) {
        emit(s.copyWith(isFetchingRate: true, error: null));
        try {
          final rate = await repository.getExchangeRate(
            type: 0, // Crypto->Fiat
            cryptoCurrencyId: s.selectedCrypto!.id,
            fiatCurrencyId: s.selectedFiat!.id,
            amount: s.inputAmount,
            amountCurrencyId: s.selectedCrypto!.id,
          );
          emit(s.copyWith(conversionResult: rate, isFetchingRate: false));
        } catch (e) {
          emit(s.copyWith(error: e.toString(), isFetchingRate: false));
        }
      }
    }
  }

  void _onSwapCurrencies(SwapCurrencies event, Emitter<CurrencyState> emit) {
    if (state is CurrencyLoaded) {
      final s = state as CurrencyLoaded;
      emit(
        s.copyWith(
          selectedCrypto:
              s.selectedFiat != null && s.cryptocurrencies.any((c) => c.id == s.selectedFiat!.id)
                  ? s.cryptocurrencies.firstWhere((c) => c.id == s.selectedFiat!.id)
                  : s.selectedCrypto,
          selectedFiat:
              s.selectedCrypto != null && s.fiatCurrencies.any((f) => f.id == s.selectedCrypto!.id)
                  ? s.fiatCurrencies.firstWhere((f) => f.id == s.selectedCrypto!.id)
                  : s.selectedFiat,
          conversionResult: null,
        ),
      );
    }
  }
}
