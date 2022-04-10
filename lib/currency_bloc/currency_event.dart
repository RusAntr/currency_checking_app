part of 'currency_bloc.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();
}

class SwitchCurrenciesEvent extends CurrencyEvent {
  final CurrencyPair pair;

  const SwitchCurrenciesEvent(this.pair);
  @override
  List<Object> get props => [pair];
}

class ConvertCurrenciesEvent extends CurrencyEvent {
  final Currency baseCurrency;
  final Currency toCurrency;
  final double amount;

  const ConvertCurrenciesEvent({
    required this.amount,
    required this.baseCurrency,
    required this.toCurrency,
  });

  @override
  List<Object> get props => [
        baseCurrency,
        toCurrency,
        amount,
      ];
}
