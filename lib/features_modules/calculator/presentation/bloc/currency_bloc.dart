import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/crypto_currency_model.dart';
import '../../data/models/fiat_currency_model.dart';
import '../../data/repositories/currency_repository.dart';

// Conversion direction type enum
enum ConversionType { cryptoToFiat, fiatToCrypto }

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
  final double? convertedAmount;
  final bool isFetchingRate;
  final String? error;
  final ConversionType type;

  CurrencyLoaded({
    required this.cryptocurrencies,
    required this.fiatCurrencies,
    this.selectedCrypto,
    this.selectedFiat,
    this.inputAmount = 0.0,
    this.conversionResult,
    this.convertedAmount,
    this.isFetchingRate = false,
    this.error,
    this.type = ConversionType.cryptoToFiat,
  });

  CurrencyLoaded copyWith({
    List<CryptoCurrencyModel>? cryptocurrencies,
    List<FiatCurrencyModel>? fiatCurrencies,
    CryptoCurrencyModel? selectedCrypto,
    FiatCurrencyModel? selectedFiat,
    double? inputAmount,
    double? conversionResult,
    double? convertedAmount,
    bool? isFetchingRate,
    String? error,
    ConversionType? type,
  }) {
    return CurrencyLoaded(
      cryptocurrencies: cryptocurrencies ?? this.cryptocurrencies,
      fiatCurrencies: fiatCurrencies ?? this.fiatCurrencies,
      selectedCrypto: selectedCrypto ?? this.selectedCrypto,
      selectedFiat: selectedFiat ?? this.selectedFiat,
      inputAmount: inputAmount ?? this.inputAmount,
      conversionResult: conversionResult,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      isFetchingRate: isFetchingRate ?? this.isFetchingRate,
      error: error,
      type: type ?? this.type,
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
          type: ConversionType.cryptoToFiat,
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
      if (s.inputAmount >= 10) add(FetchConversionRate());
    }
  }

  void _onSelectFiat(SelectFiatCurrency event, Emitter<CurrencyState> emit) {
    if (state is CurrencyLoaded) {
      final s = state as CurrencyLoaded;
      emit(s.copyWith(selectedFiat: event.fiat, conversionResult: null));
      if (s.inputAmount >= 10) add(FetchConversionRate());
    }
  }

  void _onAmountChanged(AmountChanged event, Emitter<CurrencyState> emit) {
    if (state is CurrencyLoaded) {
      final s = state as CurrencyLoaded;
      emit(s.copyWith(inputAmount: event.amount, conversionResult: null));
      if (event.amount >= 10) add(FetchConversionRate());
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
          final typeInt = s.type == ConversionType.cryptoToFiat ? 0 : 1;
          final rawRate = await repository.getExchangeRate(
            type: typeInt,
            cryptoCurrencyId: s.selectedCrypto!.id,
            fiatCurrencyId: s.selectedFiat!.id,
            amount: s.inputAmount,
            amountCurrencyId:
                s.type == ConversionType.cryptoToFiat ? s.selectedCrypto!.id : s.selectedFiat!.id,
          );

          final result = typeInt == 0 ? rawRate * s.inputAmount : s.inputAmount / rawRate;
          emit(
            s.copyWith(
              convertedAmount: rawRate,
              conversionResult: result.toDouble(),
              isFetchingRate: false,
            ),
          );
        } catch (e) {
          emit(s.copyWith(error: 'Failed to fetch exchange rate', isFetchingRate: false));
        }
      }
    }
  }

  void _onSwapCurrencies(SwapCurrencies event, Emitter<CurrencyState> emit) {
    if (state is CurrencyLoaded) {
      final s = state as CurrencyLoaded;
      emit(
        s.copyWith(
          type:
              s.type == ConversionType.cryptoToFiat
                  ? ConversionType.fiatToCrypto
                  : ConversionType.cryptoToFiat,
          conversionResult: null,
        ),
      );
      if (s.inputAmount >= 10) add(FetchConversionRate());
    }
  }
}
