import 'package:currency_checking_app/core/consts/app_text_styles.dart';
import 'package:currency_checking_app/currency_bloc/currency_bloc.dart';
import 'package:currency_checking_app/data/models/currency_model.dart';
import 'package:currency_checking_app/data/models/currency_pair.dart';
import 'package:currency_checking_app/data/repositories/currency_repository.dart';
import 'package:currency_checking_app/ui/pages/search_page.dart';
import 'package:currency_checking_app/ui/widgets/update_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:intl/intl.dart' as intl;

import '../widgets/currency_tile.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _currencyBloc = CurrencyBloc(currencyRepository: CurrencyRepository());
  final _baseTextEditingController = TextEditingController();
  final _toTextEditingController = TextEditingController();
  late CurrencyPair _currentCurrencyPair;

  @override
  void dispose() {
    super.dispose();
    _currencyBloc.close();
    _baseTextEditingController.dispose();
    _toTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _currencyBloc,
        child: SafeArea(
          child: BlocBuilder<CurrencyBloc, CurrencyState>(
            bloc: _currencyBloc,
            builder: (context, state) {
              if (state is CurrencyLoadedState) {
                _currentCurrencyPair = state.currencyPairModel;
                _getLastUpdated();
                _setTextControllers();
                return Column(
                  children: [
                    _currencyPairWidget(),
                    _simpleCalculator(),
                    _bottomWidget(),
                  ],
                );
              } else if (state is CurrencyFailedState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                      child: Text(
                        state.error,
                        style: AppTextStyles.titleWhiteMedium
                            .copyWith(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    UpdateButton(onPressed: _addEvent),
                    _simpleCalculator(),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  /// Adds new [CurrencyEvent] to a [CurrencyBloc]
  void _addEvent() {
    _currencyBloc.add(ConvertCurrenciesEvent(
      baseCurrency: _currentCurrencyPair.baseCurrency,
      toCurrency: _currentCurrencyPair.toCurrency,
      amount: _currentCurrencyPair.amount,
    ));
  }

  // Returns a properly formatted date of a last update
  String _getLastUpdated() {
    var lastUpdated = DateTime.fromMillisecondsSinceEpoch(
        (_currentCurrencyPair.lastUpdated * 1000),
        isUtc: false);
    var hoursMinutes = intl.DateFormat.Hm().format(lastUpdated);
    var yearMonthDay = intl.DateFormat.yMd().format(lastUpdated);
    return 'Last updated: $yearMonthDay $hoursMinutes';
  }

  /// Sets and formats text property of two [TextEditingController]s for each currency in a pair
  void _setTextControllers() {
    final currencyFormat = intl.NumberFormat("#,##0.00", "en_US");
    _baseTextEditingController.text =
        currencyFormat.format(_currentCurrencyPair.amount);
    _toTextEditingController.text =
        currencyFormat.format(_currentCurrencyPair.output);
  }

  /// Returns a text and an update button
  Widget _bottomWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10),
          child: Center(
              child: Text(
            _getLastUpdated(),
          )),
        ),
        UpdateButton(onPressed: _addEvent)
      ],
    );
  }

  /// Handles the onChange function of a [SimpleCalculator]. Updates current
  /// [CurrencyPair] with a new amount and output, adds a new [SwitchCurrenciesEvent]
  /// to a [CurrencyBloc]
  void _onCalcClick(double? value) {
    _currentCurrencyPair = _currentCurrencyPair.copyWith(
        amount: value ?? 0,
        output: ((value ?? 0) * _currentCurrencyPair.exchangeRate));
    _currencyBloc.add(SwitchCurrenciesEvent(_currentCurrencyPair));
  }

  /// Returns a [SimpleCalculator] widget
  Widget _simpleCalculator() {
    return Expanded(
      child: SimpleCalculator(
        onChanged: (key, value, expression) => _onCalcClick(value),
        hideExpression: false,
        theme: const CalculatorThemeData(
            displayColor: Colors.transparent,
            displayStyle: TextStyle(color: Colors.transparent, fontSize: 0)),
      ),
    );
  }

  /// Opens a [BottomSheet] for searching a desirable [Currency] and changing the [CurrencyPair]
  void _showModalBottomSheet(bool isBaseCurrency) {
    showModalBottomSheet(
        clipBehavior: Clip.hardEdge,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        context: context,
        builder: (context) => BlocProvider.value(
              value: _currencyBloc,
              child: SearchCurrencyBottomSheet(isBaseCurrency: isBaseCurrency),
            ));
  }

  /// Returns a widget of a row with a [CurrencyTile] and a [TextField] inside
  Widget _currencyWidget({
    required Currency currency,
    required bool isBaseCurrency,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 0,
          child: GestureDetector(
              onTap: () => _showModalBottomSheet(isBaseCurrency),
              child: CurrencyTile(
                currency: currency,
                isHint: true,
              )),
        ),
        Expanded(
            flex: 1,
            child: TextField(
              textAlign: TextAlign.right,
              style: AppTextStyles.titleWhiteBig.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: .0, horizontal: 10.0),
              ),
              readOnly: true,
              controller: isBaseCurrency == true
                  ? _baseTextEditingController
                  : _toTextEditingController,
            )),
      ],
    );
  }

  /// Updates current [CurrencyPair], adds a new [SwitchCurrenciesEvent] to a
  /// [CurrencyBloc]. Basically inverts a [CurrencyPair]
  void _switchCurrencies() {
    var prevBase = _currentCurrencyPair.baseCurrency;
    var prevTo = _currentCurrencyPair.toCurrency;
    var invertRate = 1 / _currentCurrencyPair.exchangeRate;
    bool isReversed = true;
    _currentCurrencyPair = _currentCurrencyPair.copyWith(
      baseCurrency: prevTo,
      toCurrency: prevBase,
      exchangeRate:
          isReversed == true ? invertRate : _currentCurrencyPair.exchangeRate,
      output: _currentCurrencyPair.amount *
          (isReversed == true ? invertRate : _currentCurrencyPair.exchangeRate),
    );
    isReversed = false;
    _currencyBloc.add(SwitchCurrenciesEvent(_currentCurrencyPair));
  }

  /// Returns a column of two [_currencyWidget]'s and a button inside
  Widget _currencyPairWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
      child: Column(
        children: [
          _currencyWidget(
            isBaseCurrency: true,
            currency: _currentCurrencyPair.baseCurrency,
          ),
          TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                  )),
                  overlayColor:
                      MaterialStateProperty.all(Colors.black.withOpacity(0.2)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)))),
              onPressed: () => _switchCurrencies(),
              child: Icon(
                Icons.swap_vert_rounded,
                color: Colors.white.withOpacity(0.7),
              )),
          _currencyWidget(
            isBaseCurrency: false,
            currency: _currentCurrencyPair.toCurrency,
          ),
        ],
      ),
    );
  }
}
