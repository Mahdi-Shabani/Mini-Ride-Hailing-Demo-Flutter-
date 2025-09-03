import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapState.initial()) {
    on<MapInit>((e, emit) {
      emit(state.copyWith(vehicles: _allVehicles, clearRoute: true));
    });

    on<MapShowAll>((e, emit) {
      emit(state.copyWith(vehicles: _allVehicles, clearRoute: true));
    });

    on<MapShowForPlaces>((e, emit) {
      final set = <VehicleMarker>[];
      for (final t in e.titles) {
        final v = _vehiclesByPlace[t];
        if (v != null) set.addAll(v);
      }
      emit(state.copyWith(vehicles: set, clearRoute: true));
    });

    on<MapSetRoute>((e, emit) {
      final destAnchor = _placeAnchors[e.destTitle] ?? const Offset(0.55, 0.35);
      final vehicles = _vehiclesByPlace[e.destTitle] ?? const <VehicleMarker>[];
      emit(
        state.copyWith(
          vehicles: vehicles,
          routeStart: e.originNorm,
          routeEnd: destAnchor,
        ),
      );
    });
  }

  static const Map<String, Offset> _placeAnchors = {
    'Times Square': Offset(0.52, 0.34),
    'Park Avenue': Offset(0.70, 0.42),
    '5th Avenue': Offset(0.33, 0.46),
    'Harlem': Offset(0.28, 0.24),
    'Chinatown': Offset(0.42, 0.66),
    'Upper East Side': Offset(0.76, 0.28),
    'East Village': Offset(0.56, 0.62),
  };

  static const Map<String, List<VehicleMarker>> _vehiclesByPlace = {
    'Times Square': [
      VehicleMarker(dx: 0.46, dy: 0.33, rotation: 0.1),
      VehicleMarker(dx: 0.52, dy: 0.36, rotation: -0.3),
    ],
    'Park Avenue': [VehicleMarker(dx: 0.70, dy: 0.42, rotation: 0.6)],
    '5th Avenue': [
      VehicleMarker(dx: 0.35, dy: 0.48, rotation: -0.8),
      VehicleMarker(dx: 0.27, dy: 0.42, rotation: 1.2),
    ],
    'Harlem': [VehicleMarker(dx: 0.26, dy: 0.26, rotation: -0.4)],
    'Chinatown': [VehicleMarker(dx: 0.41, dy: 0.63, rotation: 0.2)],
    'Upper East Side': [VehicleMarker(dx: 0.74, dy: 0.30, rotation: -0.2)],
    'East Village': [VehicleMarker(dx: 0.58, dy: 0.60, rotation: 0.9)],
  };

  static List<VehicleMarker> get _allVehicles =>
      _vehiclesByPlace.values.expand((e) => e).toList(growable: false);
}
