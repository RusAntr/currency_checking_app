part of 'currency_bloc.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object> get props => [];
}

class CurrencyLoadingState extends CurrencyState {}

class CurrencyLoadedState extends CurrencyState {
  final CurrencyPair currencyPairModel;

  const CurrencyLoadedState(this.currencyPairModel);

  @override
  List<Object> get props => [currencyPairModel];

  Map<String, dynamic> toJson() {
    return {'value': currencyPairModel.toJson()};
  }

  factory CurrencyLoadedState.fromJson(Map<String, dynamic> json) {
    return CurrencyLoadedState(CurrencyPair.fromJson(json['value']));
  }
}

class CurrencyFailedState extends CurrencyState {
  final String error;
  const CurrencyFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
