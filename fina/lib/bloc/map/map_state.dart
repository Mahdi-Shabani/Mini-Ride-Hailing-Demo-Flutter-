import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class VehicleMarker extends Equatable {
  final double dx;
  final double dy;
  final double rotation;
  const VehicleMarker({required this.dx, required this.dy, this.rotation = 0});
  @override
  List<Object?> get props => [dx, dy, rotation];
}

class MapState extends Equatable {
  final Offset user;
  final List<VehicleMarker> vehicles;
  final Offset? routeStart;
  final Offset? routeEnd;

  const MapState({
    required this.user,
    required this.vehicles,
    this.routeStart,
    this.routeEnd,
  });

  factory MapState.initial() =>
      const MapState(user: Offset(0.5, 0.55), vehicles: []);

  MapState copyWith({
    Offset? user,
    List<VehicleMarker>? vehicles,
    Offset? routeStart,
    Offset? routeEnd,
    bool clearRoute = false,
  }) {
    return MapState(
      user: user ?? this.user,
      vehicles: vehicles ?? this.vehicles,
      routeStart: clearRoute ? null : (routeStart ?? this.routeStart),
      routeEnd: clearRoute ? null : (routeEnd ?? this.routeEnd),
    );
  }

  bool get hasRoute => routeStart != null && routeEnd != null;

  @override
  List<Object?> get props => [user, vehicles, routeStart, routeEnd];
}
