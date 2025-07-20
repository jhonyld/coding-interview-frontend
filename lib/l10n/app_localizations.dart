import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('es'), Locale('pt')];

  String get appTitle {
    switch (locale.languageCode) {
      case 'es':
        return 'Calculadora de Criptomonedas';
      case 'pt':
        return 'Calculadora de Criptomoedas';
      default:
        return 'Crypto Currency Calculator';
    }
  }

  String get loadingLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'Cargando...';
      case 'pt':
        return 'Carregando...';
      default:
        return 'Loading...';
    }
  }

  String get errorLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'Error: {error}';
      case 'pt':
        return 'Erro: {error}';
      default:
        return 'Error: {error}';
    }
  }

  String get cryptocurrencyLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'Criptomoneda';
      case 'pt':
        return 'Criptomoeda';
      default:
        return 'Cryptocurrency';
    }
  }

  String get fiatCurrencyLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'Moneda FIAT';
      case 'pt':
        return 'Moeda FIAT';
      default:
        return 'FIAT Currency';
    }
  }

  String get amountLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'Cantidad';
      case 'pt':
        return 'Quantidade';
      default:
        return 'Amount';
    }
  }

  String get resultLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'Resultado: {value} {currency}';
      case 'pt':
        return 'Resultado: {value} {currency}';
      default:
        return 'Result: {value} {currency}';
    }
  }

  String get enterAmountHint {
    switch (locale.languageCode) {
      case 'es':
        return 'Ingrese la cantidad y seleccione monedas';
      case 'pt':
        return 'Digite o valor e selecione as moedas';
      default:
        return 'Enter amount and select currencies';
    }
  }

  String get haveLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'TENGO';
      case 'pt':
        return 'TENHO';
      default:
        return 'HAVE';
    }
  }

  String get wantLabel {
    switch (locale.languageCode) {
      case 'es':
        return 'QUIERO';
      case 'pt':
        return 'QUERO';
      default:
        return 'WANT';
    }
  }

  String get cryptoModalTitle {
    switch (locale.languageCode) {
      case 'es':
        return 'Cripto';
      case 'pt':
        return 'Cripto';
      default:
        return 'Cripto';
    }
  }

  String get fiatModalTitle {
    switch (locale.languageCode) {
      case 'es':
        return 'FIAT';
      case 'pt':
        return 'FIAT';
      default:
        return 'FIAT';
    }
  }

  String get estimatedRate {
    switch (locale.languageCode) {
      case 'es':
        return 'Tasa estimada';
      case 'pt':
        return 'Taxa estimada';
      default:
        return 'Estimated Rate';
    }
  }

  String get youReceive {
    switch (locale.languageCode) {
      case 'es':
        return 'Recibirás';
      case 'pt':
        return 'Você receberá';
      default:
        return 'You Receive';
    }
  }

  String get estimatedTime {
    switch (locale.languageCode) {
      case 'es':
        return 'Tiempo estimado';
      case 'pt':
        return 'Tempo estimado';
      default:
        return 'Estimated Time';
    }
  }

  String get exchangeButton {
    switch (locale.languageCode) {
      case 'es':
        return 'Cambiar';
      case 'pt':
        return 'Trocar';
      default:
        return 'Exchange';
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
