import 'package:currency_checking_app/core/consts/all_currencies.dart';
import 'package:currency_checking_app/core/consts/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../currency_bloc/currency_bloc.dart';
import '../../data/models/currency_model.dart';
import '../../data/repositories/currency_repository.dart';
import '../widgets/currency_tile.dart';

class SearchCurrencyBottomSheet extends StatefulWidget {
  const SearchCurrencyBottomSheet({
    Key? key,
    required this.isBaseCurrency,
  }) : super(key: key);

  final bool isBaseCurrency;

  @override
  State<SearchCurrencyBottomSheet> createState() =>
      _SearchCurrencyBottomSheetState();
}

class _SearchCurrencyBottomSheetState extends State<SearchCurrencyBottomSheet> {
  late CurrencyBloc _currencyConversionBloc;
  List<Currency> _currenciesFound = [];
  final _allCurrencies = CurrencyRepository().getAllCurrencies();

  @override
  void initState() {
    _currenciesFound = _allCurrencies;
    _currencyConversionBloc = context.read<CurrencyBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.75,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        color: Colors.black.withOpacity(0.3),
        child: Column(
          children: [
            _lineDecoration(),
            _textField(),
            _buildListView(scrollController),
          ],
        ),
      ),
    );
  }

  /// A decorative long rounded line
  Widget _lineDecoration() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 7,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }

  /// A [TextField] for the [_onTileTap]
  Widget _textField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: TextField(
        decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'USD / American dollar / 🇺🇸'),
        onChanged: (value) {
          setState(() {
            _searchCurrencies(value);
          });
        },
      ),
    );
  }

  /// [BlocBuilder] builds a ListView for displaying all found currencies if
  /// the [CurrencyState] is [CurrencyLoadedState]
  BlocBuilder<CurrencyBloc, CurrencyState> _buildListView(
      ScrollController scrollController) {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      bloc: _currencyConversionBloc,
      builder: (context, state) {
        return Expanded(
          child: _currenciesFound.isNotEmpty
              ? ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _currenciesFound.length,
                  itemBuilder: (context, index) {
                    if (state is CurrencyLoadedState) {
                      return GestureDetector(
                        onTap: () => _onTileTap(index, state),
                        child: CurrencyTile(
                          currency: _currenciesFound[index],
                          isHint: false,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              : Text(
                  'No currency found',
                  style: AppTextStyles.titleWhiteBig.copyWith(fontSize: 15),
                ),
        );
      },
    );
  }

  /// Searches for a desirable currency among [AllCurrencies.currencies],
  /// takes in a [String], returns a list of [Currency]
  List<Currency> _searchCurrencies(String searchText) {
    if (searchText.isNotEmpty) {
      _currenciesFound = _allCurrencies.where((element) {
        if (element.currencyCode
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          return true;
        } else if (element.currencyName
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          return true;
        } else if (element.emoji.contains(searchText)) {
          return true;
        }
        return false;
      }).toList();
    } else {
      _currenciesFound = _allCurrencies;
    }
    return _currenciesFound;
  }

  /// Adds a new [ConvertCurrenciesEvent] to [CurrencyBloc] ands closes
  /// [showModalBottomSheet]
  void _onTileTap(int index, CurrencyLoadedState state) {
    Navigator.of(context).pop();
    if (widget.isBaseCurrency) {
      _currencyConversionBloc.add(ConvertCurrenciesEvent(
        amount: state.currencyPairModel.amount,
        baseCurrency: _currenciesFound[index],
        toCurrency: state.currencyPairModel.toCurrency,
      ));
    } else if (!widget.isBaseCurrency) {
      _currencyConversionBloc.add(ConvertCurrenciesEvent(
        amount: state.currencyPairModel.amount,
        baseCurrency: state.currencyPairModel.baseCurrency,
        toCurrency: _currenciesFound[index],
      ));
    }
  }
}
