import 'package:flutter_bloc/flutter_bloc.dart';
import 'sheet_event.dart';
import 'sheet_state.dart';

class SheetBloc extends Bloc<SheetEvent, SheetState> {
  SheetBloc() : super(const SheetState(extent: kSheetCollapsed)) {
    on<SheetDragUpdated>((e, emit) {
      emit(state.copyWith(extent: e.extent));
    });
    on<SheetSnapToCollapsed>((e, emit) {
      emit(state.copyWith(extent: kSheetCollapsed, searchFocused: false));
    });
    on<SheetSnapToHalf>((e, emit) {
      emit(state.copyWith(extent: kSheetHalf));
    });
    on<SheetSnapToExpanded>((e, emit) {
      emit(state.copyWith(extent: kSheetExpanded, searchFocused: true));
    });
    on<SheetFocusSearch>((e, emit) {
      emit(state.copyWith(searchFocused: true));
    });
    on<SheetBlurSearch>((e, emit) {
      emit(state.copyWith(searchFocused: false));
    });
  }
}
