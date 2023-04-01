import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' as foundation;

class AppMainBlocObserver extends BlocObserver {
  const AppMainBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    foundation.debugPrint('${bloc.runtimeType} $change');
  }
}
