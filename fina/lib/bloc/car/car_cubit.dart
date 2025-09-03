import 'package:bloc/bloc.dart';
import 'car_state.dart';

class CarCubit extends Cubit<CarState> {
  CarCubit() : super(const CarState());

  void loadForRoute({
    required String originLabel,
    required String destinationTitle,
  }) {
    final items = <CarItem>[
      CarItem(
        id: 'audi_r8',
        name: 'Audi R8',
        price: 200,
        etaMin: 1,
        imageAsset: 'assets/images/Image.png',
      ),
      CarItem(
        id: 'mercedes_gle',
        name: 'Mercedes GLE',
        price: 225,
        etaMin: 2,
        imageAsset: 'assets/images/Image (1).png',
      ),
      CarItem(
        id: 'audi_s5',
        name: 'Audi S5',
        price: 200,
        etaMin: 3,
        imageAsset: 'assets/images/Image (2).png',
      ),
      CarItem(
        id: 'alfa_romeo_f4',
        name: 'Alfa Romeo F4',
        price: 220,
        etaMin: 6,
        imageAsset: 'assets/images/Image (3).png',
      ),
      CarItem(
        id: 'limousine',
        name: 'Limousine',
        price: 320,
        etaMin: 9,
        imageAsset: 'assets/images/Image (5).png',
      ),
      CarItem(
        id: 'bmw_classic',
        name: 'BMW',
        price: 210,
        etaMin: 11,
        imageAsset: 'assets/images/image5.png',
      ),
    ];

    // clearSelection = true تا انتخاب قبلی پاک شود و گرید تازه نمایش داده شود
    emit(state.copyWith(cars: items, loaded: true, clearSelection: true));
  }

  void select(String id) => emit(state.copyWith(selectedId: id));

  void toggleFav(String id) {
    final updated = state.cars
        .map((c) => c.id == id ? c.copyWith(fav: !c.fav) : c)
        .toList(growable: false);
    emit(state.copyWith(cars: updated));
  }

  void clear() => emit(const CarState());
}
