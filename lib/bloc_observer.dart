import 'dart:developer';

import 'package:bloc/bloc.dart';

class CurrencyBlocObservable extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('--onEvent: ${bloc.runtimeType}: event: $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('--onError: ${bloc.runtimeType}: error: $error \n$stackTrace');
  }
}
