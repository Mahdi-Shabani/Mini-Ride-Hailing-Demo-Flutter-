import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../search/search_state.dart';

class RouteState extends Equatable {
  final Offset? origin;
  final String? originLabel;
  final Place? destination;

  const RouteState({this.origin, this.originLabel, this.destination});

  RouteState copyWith({
    Offset? origin,
    String? originLabel,
    Place? destination,
    bool clearDestination = false,
  }) {
    return RouteState(
      origin: origin ?? this.origin,
      originLabel: originLabel ?? this.originLabel,
      destination: clearDestination ? null : (destination ?? this.destination),
    );
  }

  bool get hasOrigin => origin != null;
  bool get hasDestination => destination != null;
  bool get isReady => hasOrigin && hasDestination;

  @override
  List<Object?> get props => [origin, originLabel, destination];
}
