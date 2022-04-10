import 'package:currency_checking_app/data/models/currency_model.dart';
import 'package:currency_checking_app/data/models/currency_pair.dart';
import 'package:currency_checking_app/data/repositories/currency_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState>
    with HydratedMixin {
  final CurrencyRepository currencyRepository;
  static final CurrencyPair _mockData = CurrencyPair(
    baseCurrency: Currency.fromCode(currencyCode: 'USD'),
    toCurrency: Currency.fromCode(currencyCode: 'EUR'),
    amount: 1,
    lastUpdated: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
    exchangeRate: 0.92,
    output: 1 * 0.92,
  );

  CurrencyBloc({required this.currencyRepository})
      : super(CurrencyLoadedState(_mockData)) {
    on<SwitchCurrenciesEvent>(
        (event, emit) => emit(CurrencyLoadedState(event.pair)));
    on<ConvertCurrenciesEvent>(((event, emit) async {
      try {
        var currencyPair = await currencyRepository.convertCurrencies(
          baseCurrency: event.baseCurrency,
          toCurrency: event.toCurrency,
          amount: event.amount,
        );
        emit(CurrencyLoadedState(currencyPair));
      } catch (e) {
        emit(const CurrencyFailedState(
            error: 'Something went wrong :( \n Please try again'));
        rethrow;
      }
    }));
  }

  @override
  CurrencyState? fromJson(Map<String, dynamic> json) {
    return CurrencyLoadedState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(CurrencyState state) {
    if (state is CurrencyLoadedState) {
      return state.toJson();
    }
    return null;
  }
}
