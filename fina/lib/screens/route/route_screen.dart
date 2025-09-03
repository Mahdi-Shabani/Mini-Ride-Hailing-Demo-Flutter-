import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/top_bar.dart';
import '../../bloc/route/route_cubit.dart';
import '../../bloc/route/route_state.dart';

import '../../bloc/search/search_bloc.dart';
import '../../bloc/search/search_event.dart';
import '../../bloc/search/search_state.dart' show SearchState, Place;

import '../../bloc/car/car_cubit.dart';
import '../../bloc/car/car_state.dart';

import '../ride/ride_preview_screen.dart';

// گرادیان و رنگ‌های مشترک
const _kGradColors = [Color(0xFF9C22FF), Color(0xFFFB25FF), Color(0xFFFF532D)];
const _kGradStops = [0.0, 0.54, 0.98];
const _kBgDark = Color(0xFF1F1936);
const _kCardBg = Color(0xFF261F40);

enum _ActiveField { origin, destination }

class RouteScreen extends StatefulWidget {
  final bool startEmpty; // وقتی از سرچ‌بار می‌آییم: فیلدها خالی
  const RouteScreen({super.key, this.startEmpty = false});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final _destCtrl = TextEditingController();
  final _destFocus = FocusNode();
  _ActiveField _active = _ActiveField.destination;

  @override
  void initState() {
    super.initState();
    if (widget.startEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<RouteCubit>().clearAll();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _destFocus.requestFocus(),
    );
    _destFocus.addListener(() {
      if (_destFocus.hasFocus)
        setState(() => _active = _ActiveField.destination);
    });
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  // نگاشت ساده نام → مختصات تقریبی روی Map.png
  Offset _anchorForPlace(String title) {
    switch (title) {
      case 'Times Square':
        return const Offset(0.52, 0.34);
      case 'Park Avenue':
        return const Offset(0.70, 0.42);
      case '5th Avenue':
        return const Offset(0.33, 0.46);
      case 'Harlem':
        return const Offset(0.28, 0.24);
      case 'Chinatown':
        return const Offset(0.42, 0.66);
      case 'Upper East Side':
        return const Offset(0.76, 0.28);
      case 'East Village':
        return const Offset(0.56, 0.62);
      default:
        return const Offset(0.55, 0.35);
    }
  }

  @override
  Widget build(BuildContext context) {
    // RouteCubit از والد می‌آید
    final route = context.watch<RouteCubit>().state;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchBloc>(
          create: (_) => SearchBloc()..add(const SearchLoadNearby()),
        ),
        BlocProvider<CarCubit>(create: (_) => CarCubit()),
      ],
      // Builder یک context جدید زیر Providerها می‌دهد
      child: Builder(
        builder: (context) {
          return BlocListener<RouteCubit, RouteState>(
            listenWhen: (p, c) =>
                p.isReady != c.isReady || p.destination != c.destination,
            listener: (context, r) {
              final carCubit = context.read<CarCubit>();
              if (r.isReady) {
                carCubit.loadForRoute(
                  originLabel: r.originLabel ?? 'Selected location',
                  destinationTitle: r.destination!.title,
                );
                context.read<SearchBloc>().add(const SearchClear());
              } else {
                carCubit.clear();
              }
            },
            child: Scaffold(
              body: Stack(
                children: [
                  // پس‌زمینه گرادیانی
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A2348), Color(0xFF070613)],
                      ),
                    ),
                  ),
                  // نوار بالای مشترک
                  const SafeArea(child: TopBar()),
                  // محتوا
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
                      child: Column(
                        children: [
                          // هدر: Your Route وسط + بک
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context, false),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      right: 8,
                                    ),
                                    child: Image.asset(
                                      'assets/icons/Chevron.png',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                'Your Route',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // کارت دو فیلد
                          RouteFieldsCard(
                            originLabel: route.originLabel ?? 'Where from?',
                            hasDestination: route.destination != null,
                            active: _active,
                            destCtrl: _destCtrl,
                            destFocus: _destFocus,
                            onTapOrigin: () {
                              setState(() => _active = _ActiveField.origin);
                              _destFocus.unfocus();
                            },
                            onTapDestination: () {
                              setState(
                                () => _active = _ActiveField.destination,
                              );
                              _destFocus.requestFocus();
                            },
                            onClearDest: () {
                              _destCtrl.clear();
                              context.read<SearchBloc>().add(
                                const SearchClear(),
                              );
                              context.read<RouteCubit>().clearDestination();
                              context.read<CarCubit>().clear();
                              setState(() {}); // برای بازگرداندن لیست آدرس‌ها
                            },
                          ),

                          const SizedBox(height: 16),

                          // پایین صفحه: اگر مقصد تأیید شد → گرید؛ وگرنه لیست آدرس‌ها
                          Expanded(
                            child: BlocBuilder<SearchBloc, SearchState>(
                              builder: (context, state) {
                                final r = context.watch<RouteCubit>().state;
                                if (r.isReady && !state.hasQuery) {
                                  return const _CarGrid();
                                }

                                final items = state.hasQuery
                                    ? state.results
                                    : state.nearby;
                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: items.length,
                                  itemBuilder: (context, i) {
                                    final p = items[i];
                                    final parts = p.title.split(' ');
                                    final first = parts.first;
                                    final rest = p.title.substring(
                                      first.length,
                                    );
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          p.thumb,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: first,
                                              style: const TextStyle(
                                                color: Color(0xFFFF6A00),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(
                                              text: rest,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Text(
                                        p.subtitle,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white54,
                                      ),
                                      onTap: () {
                                        if (_active == _ActiveField.origin) {
                                          context.read<RouteCubit>().setOrigin(
                                            _anchorForPlace(p.title),
                                            label: p.title,
                                          );
                                        } else {
                                          context
                                              .read<RouteCubit>()
                                              .setDestination(p);
                                          _destCtrl.text = p.title;
                                          _destFocus.unfocus();
                                          context.read<SearchBloc>().add(
                                            const SearchClear(),
                                          );
                                        }
                                        setState(() {});
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// کارت فیلدها + خط و دایره‌ها
class RouteFieldsCard extends StatelessWidget {
  final String originLabel;
  final bool hasDestination;
  final _ActiveField active;
  final TextEditingController destCtrl;
  final FocusNode destFocus;
  final VoidCallback onTapOrigin;
  final VoidCallback onTapDestination;
  final VoidCallback onClearDest;

  const RouteFieldsCard({
    super.key,
    required this.originLabel,
    required this.hasDestination,
    required this.active,
    required this.destCtrl,
    required this.destFocus,
    required this.onTapOrigin,
    required this.onTapDestination,
    required this.onClearDest,
  });

  @override
  Widget build(BuildContext context) {
    const double rowH = 52.0;
    const double gap = 12.0;
    const double circle = 20.0;
    const double railW = 30.0;

    Widget buildField({
      required bool gradientBorder,
      required bool outlinedIdle,
      required Widget child,
    }) {
      if (gradientBorder) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: _kGradColors,
              stops: _kGradStops,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _kBgDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: child,
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: _kBgDark,
          borderRadius: BorderRadius.circular(16),
          border: outlinedIdle
              ? Border.all(color: const Color(0xFF7B62F4), width: 1.4)
              : null,
        ),
        child: child,
      );
    }

    final originField = GestureDetector(
      onTap: onTapOrigin,
      child: buildField(
        gradientBorder: active == _ActiveField.origin,
        outlinedIdle: false,
        child: SizedBox(
          height: rowH,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    originLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.check, color: Color(0xFFFF6A00), size: 18),
              ],
            ),
          ),
        ),
      ),
    );

    final destinationField = GestureDetector(
      onTap: onTapDestination,
      child: buildField(
        gradientBorder:
            active == _ActiveField.destination || destFocus.hasFocus,
        outlinedIdle: true,
        child: SizedBox(
          height: rowH,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: destCtrl,
                    focusNode: destFocus,
                    onChanged: (q) =>
                        context.read<SearchBloc>().add(SearchQueryChanged(q)),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Where to?',
                      hintStyle: TextStyle(color: Colors.white70),
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onClearDest,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2348),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF7B62F4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.swap_vert, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ),
    );

    // ریل چپ: دایره‌ها + خط عمودی با ارتفاع دقیق
    final lineH = gap + rowH - circle;
    Widget buildRail() {
      return SizedBox(
        width: railW,
        child: Column(
          children: [
            SizedBox(height: rowH / 2 - circle / 2),
            Image.asset(
              'assets/icons/Group1.png',
              width: circle,
              height: circle,
            ),
            hasDestination
                ? Container(
                    width: 2,
                    height: lineH,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: _kGradColors,
                        stops: _kGradStops,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  )
                : SizedBox(height: lineH),
            Image.asset(
              'assets/icons/Group2.png',
              width: circle,
              height: circle,
            ),
            SizedBox(height: rowH / 2 - circle / 2),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildRail(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                originField,
                const SizedBox(height: 12),
                destinationField,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Grid دو ستونه خودروها
class _CarGrid extends StatelessWidget {
  const _CarGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCubit, CarState>(
      builder: (context, s) {
        final cars = s.cars;
        if (cars.isEmpty) {
          return const Center(
            child: SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: cars.length,
          itemBuilder: (context, i) {
            final c = cars[i];
            final selected = s.selectedId == c.id;
            return _CarCard(item: c, selected: selected);
          },
        );
      },
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarItem item;
  final bool selected;
  const _CarCard({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: _kGradColors,
              stops: _kGradStops,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          )
        : null;

    final inner = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2245),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(item.imageAsset, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black38],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Text(
                        '${item.etaMin} min away',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price}',
                  style: const TextStyle(
                    color: Color(0xFF91E2B7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        final carCubit = context.read<CarCubit>();
        carCubit.select(item.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<RouteCubit>.value(
                  value: context.read<RouteCubit>(),
                ),
                BlocProvider<CarCubit>.value(value: carCubit),
              ],
              child: RidePreviewScreen(car: item),
            ),
          ),
        );
      },
      child: border == null
          ? inner
          : Container(
              decoration: border,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2245),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: inner,
              ),
            ),
    );
  }
}
