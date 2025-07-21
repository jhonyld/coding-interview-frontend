import 'package:get_it/get_it.dart';
import 'features_modules/calculator/data/datasources/currency_local_data_source.dart';
import 'features_modules/calculator/data/datasources/currency_api_data_source.dart';
import 'features_modules/calculator/data/repositories/currency_repository.dart';
import 'features_modules/calculator/presentation/bloc/currency_bloc.dart';

final sl = GetIt.instance;

void setupLocator() {
  // Data sources
  sl.registerLazySingleton<ICurrencyLocalDataSource>(() => CurrencyLocalDataSource());
  sl.registerLazySingleton<ICurrencyApiDataSource>(() => CurrencyApiDataSource());

  // Repository
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepository(
      localDataSource: sl<ICurrencyLocalDataSource>(),
      apiDataSource: sl<ICurrencyApiDataSource>(),
    ),
  );

  // Bloc
  sl.registerFactory(() => CurrencyBloc(sl<CurrencyRepository>()));
}
