import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState()) {
    on<SearchLoadNearby>(_onLoadNearby);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchClear>(_onClear);
  }

  Future<void> _onLoadNearby(
    SearchLoadNearby event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      state.copyWith(
        nearby: const [
          Place(
            title: 'Times Square',
            subtitle: 'Broadway 10012, New York',
            etaMin: 16,
            thumb: 'assets/images/Times.jpg',
          ),
          Place(
            title: 'Park Avenue',
            subtitle: 'Park Ave, New York',
            etaMin: 18,
            thumb: 'assets/images/Park.jpg',
          ),
          Place(
            title: '5th Avenue',
            subtitle: '5th Ave, New York',
            etaMin: 9,
            thumb: 'assets/images/5th.jpg',
          ),
          Place(
            title: 'Harlem',
            subtitle: '125th St, Manhattan, New York',
            etaMin: 12,
            thumb: 'assets/images/Harlem.jpg',
          ),
          Place(
            title: 'Chinatown',
            subtitle: 'Mott St, New York',
            etaMin: 10,
            thumb: 'assets/images/Chinatown.jpg',
          ),
          Place(
            title: 'Upper East Side',
            subtitle: 'Lexington Ave, New York',
            etaMin: 18,
            thumb: 'assets/images/Side.jpg',
          ),
          Place(
            title: 'East Village',
            subtitle: 'St Marks Pl, New York',
            etaMin: 11,
            thumb: 'assets/images/Village.jpg',
          ),
        ],
      ),
    );
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final q0 = event.query;
    emit(state.copyWith(query: q0));
    await Future.delayed(const Duration(milliseconds: 220));
    if (emit.isDone || state.query != q0) return;

    final q = _norm(q0);
    if (q.isEmpty) {
      emit(state.copyWith(results: const []));
      return;
    }

    final matches = state.nearby
        .where(
          (p) =>
              _norm(p.title).startsWith(q) || _norm(p.subtitle).startsWith(q),
        )
        .toList(growable: false);

    emit(state.copyWith(results: matches));
  }

  Future<void> _onClear(SearchClear event, Emitter<SearchState> emit) async {
    emit(state.copyWith(query: '', results: const []));
  }

  String _norm(String s) => s.toLowerCase().trim();
}
