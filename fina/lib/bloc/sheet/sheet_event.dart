import 'package:equatable/equatable.dart';

abstract class SheetEvent extends Equatable {
  const SheetEvent();
  @override
  List<Object?> get props => [];
}

class SheetDragUpdated extends SheetEvent {
  final double extent; // 0..1
  const SheetDragUpdated(this.extent);
  @override
  List<Object?> get props => [extent];
}

class SheetSnapToCollapsed extends SheetEvent {
  const SheetSnapToCollapsed();
}

class SheetSnapToHalf extends SheetEvent {
  const SheetSnapToHalf();
}

class SheetSnapToExpanded extends SheetEvent {
  const SheetSnapToExpanded();
}

class SheetFocusSearch extends SheetEvent {
  const SheetFocusSearch();
}

class SheetBlurSearch extends SheetEvent {
  const SheetBlurSearch();
}
