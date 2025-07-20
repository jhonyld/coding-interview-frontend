import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'features_modules/calculator/presentation/pages/home_page.dart';
import 'features_modules/calculator/data/datasources/currency_local_data_source.dart';
import 'features_modules/calculator/data/datasources/currency_api_data_source.dart';
import 'features_modules/calculator/data/repositories/currency_repository.dart';
import 'features_modules/calculator/presentation/bloc/currency_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = CurrencyRepository(
      localDataSource: CurrencyLocalDataSource(),
      apiDataSource: CurrencyApiDataSource(),
    );
    return BlocProvider(
      create: (_) => CurrencyBloc(repository)..add(LoadCurrencies()),
      child: MaterialApp(
        title: 'Crypto Currency Calculator',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    );
  }
}
