import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'route_state.dart';
import '../search/search_state.dart';

class RouteCubit extends Cubit<RouteState> {
  RouteCubit() : super(const RouteState());

  void clearAll() {
    emit(const RouteState());
  }

  void setOrigin(Offset normPoint, {String label = 'Selected location'}) {
    emit(
      state.copyWith(
        origin: normPoint,
        originLabel: label,
        clearDestination: false,
      ),
    );
  }

  void clearDestination() {
    emit(state.copyWith(clearDestination: true));
  }

  void setDestination(Place place) {
    emit(state.copyWith(destination: place));
  }
}
