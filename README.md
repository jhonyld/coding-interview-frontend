# Crypto Currency Calculator

A Flutter application for iOS and Android that serves as a cryptocurrency to FIAT currency calculator with responsive design, clean architecture, and internationalization (English, Spanish, Portuguese).

## Features
- Crypto-to-FIAT and FIAT-to-crypto conversion
- Local asset data for currencies
- Responsive UI for phones and tablets
- Internationalization (i18n) with 3 languages
- State management with BLOC
- Clean architecture and SOLID principles

## Project Structure
```
lib/
├── core/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   └── widgets/
├── l10n/
└── main.dart
```

## Setup Instructions
1. **Install dependencies:**
   ```sh
   flutter pub get
   ```
2. **Run the app:**
   ```sh
   flutter run
   ```
   (Choose your device: iOS, Android, or web)

## Adding New Cryptocurrencies
1. Open `assets/data/currencies.json`.
2. Add a new entry to the `cryptocurrencies` array with fields:
   - `id`, `name`, `symbol`, `logoPath`, `conversionRates` (map of fiat IDs to rates)
3. Add the logo image to `assets/cripto_currencies/`.
4. Update `pubspec.yaml` if you add new asset folders.

## Internationalization
- Edit `lib/l10n/app_en.arb`, `app_es.arb`, and `app_pt.arb` for translations.

## Architecture
- **Get IT** for dependency injection
- **Provider** for state management
- **Bloc/Cubit** logic via ChangeNotifier
- **Clean architecture**: data, domain, and presentation layers

## Layout Reference
- The following images are provided in the `assets/` folder for layout and design reference:
  - `screen_1.jpg`
  - `sheet_1.jpg`
  - `sheet_2.jpg`
- Use these images to match the UI as closely as possible to the intended design.

## License
MIT
