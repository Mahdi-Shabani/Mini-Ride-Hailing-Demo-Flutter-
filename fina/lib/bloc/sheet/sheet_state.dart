import 'package:equatable/equatable.dart';

const double kSheetCollapsed = 0.16;
const double kSheetHalf = 0.56;
const double kSheetExpanded = 0.92;

class SheetState extends Equatable {
  final double extent; // 0..1
  final bool searchFocused;

  const SheetState({required this.extent, this.searchFocused = false});

  SheetState copyWith({double? extent, bool? searchFocused}) {
    return SheetState(
      extent: extent ?? this.extent,
      searchFocused: searchFocused ?? this.searchFocused,
    );
  }

  bool get isCollapsed => extent <= kSheetCollapsed + 0.02;
  bool get isExpanded => extent >= kSheetExpanded - 0.02;
  bool get isHalf => !isCollapsed && !isExpanded;

  @override
  List<Object?> get props => [extent, searchFocused];
}
