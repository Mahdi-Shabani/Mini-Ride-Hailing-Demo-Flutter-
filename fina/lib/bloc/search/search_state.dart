import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final String title;
  final String subtitle;
  final int etaMin;
  final String thumb; // مسیر تصویر بندانگشتی

  const Place({
    required this.title,
    required this.subtitle,
    required this.etaMin,
    required this.thumb,
  });

  @override
  List<Object?> get props => [title, subtitle, etaMin, thumb];
}

class SearchState extends Equatable {
  final String query;
  final List<Place> nearby;
  final List<Place> results;

  const SearchState({
    this.query = '',
    this.nearby = const [],
    this.results = const [],
  });

  SearchState copyWith({
    String? query,
    List<Place>? nearby,
    List<Place>? results,
  }) {
    return SearchState(
      query: query ?? this.query,
      nearby: nearby ?? this.nearby,
      results: results ?? this.results,
    );
  }

  bool get hasQuery => query.trim().isNotEmpty;

  @override
  List<Object?> get props => [query, nearby, results];
}
