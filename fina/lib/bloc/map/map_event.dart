import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class MapInit extends MapEvent {
  const MapInit();
}

class MapShowAll extends MapEvent {
  const MapShowAll();
}

class MapShowForPlaces extends MapEvent {
  final List<String> titles;
  const MapShowForPlaces(this.titles);
  @override
  List<Object?> get props => [titles];
}

class MapSetRoute extends MapEvent {
  final Offset originNorm;
  final String destTitle;
  const MapSetRoute({required this.originNorm, required this.destTitle});
  @override
  List<Object?> get props => [originNorm, destTitle];
}
