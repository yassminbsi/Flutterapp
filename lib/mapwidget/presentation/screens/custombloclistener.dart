import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomBlocListener<B extends StateStreamable<S>, S>
    extends BlocListenerBase<B, S> {
  /// {@macro bloc_listener}
  /// {@macro bloc_listener_listen_when}
  const CustomBlocListener({
    required BlocWidgetListener<S> listener,
    Key? key,
    B? bloc,
    BlocListenerCondition<S>? listenWhen,
    Widget? child,
  }) : super(
          key: key,
          child: child,
          listener: listener,
          bloc: bloc,
          listenWhen: listenWhen,
        );
}