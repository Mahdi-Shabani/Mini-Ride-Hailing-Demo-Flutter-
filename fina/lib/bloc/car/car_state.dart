import 'package:equatable/equatable.dart';

class CarItem extends Equatable {
  final String id;
  final String name;
  final int price; // دلار (نمایش ساده)
  final int etaMin;
  final String imageAsset;
  final bool fav;

  const CarItem({
    required this.id,
    required this.name,
    required this.price,
    required this.etaMin,
    required this.imageAsset,
    this.fav = false,
  });

  CarItem copyWith({bool? fav}) => CarItem(
    id: id,
    name: name,
    price: price,
    etaMin: etaMin,
    imageAsset: imageAsset,
    fav: fav ?? this.fav,
  );

  @override
  List<Object?> get props => [id, name, price, etaMin, imageAsset, fav];
}

class CarState extends Equatable {
  final List<CarItem> cars;
  final String? selectedId;
  final bool loaded;

  const CarState({this.cars = const [], this.selectedId, this.loaded = false});

  CarState copyWith({
    List<CarItem>? cars,
    String? selectedId,
    bool? loaded,
    bool clearSelection = false,
  }) {
    return CarState(
      cars: cars ?? this.cars,
      selectedId: clearSelection ? null : (selectedId ?? this.selectedId),
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props => [cars, selectedId, loaded];
}
