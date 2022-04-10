import 'package:equatable/equatable.dart';
import 'package:currency_checking_app/core/consts/all_currencies.dart';

class Currency extends Equatable {
  final String currencyCode;
  final String currencyName;
  final String emoji;

  const Currency({
    required this.emoji,
    required this.currencyName,
    required this.currencyCode,
  });

  @override
  List<Object?> get props => [
        currencyName,
        currencyCode,
        emoji,
      ];

  /// Returns a [Currency] model from a currency code (ISO 4217)
  factory Currency.fromCode({required String currencyCode}) {
    final currencies = AllCurrencies.currencies;
    return Currency(
      emoji: currencies[currencyCode]!.entries.first.value,
      currencyName: currencies[currencyCode]!.entries.first.key,
      currencyCode: currencies.keys.singleWhere((key) => key == currencyCode),
    );
  }
}
