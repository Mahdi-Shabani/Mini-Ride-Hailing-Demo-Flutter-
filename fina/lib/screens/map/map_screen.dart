import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/responsive/dimens.dart';
import '../../widgets/top_bar.dart';

import '../../bloc/sheet/sheet_bloc.dart';
import '../../bloc/sheet/sheet_event.dart';
import '../../bloc/sheet/sheet_state.dart';

import '../../bloc/search/search_bloc.dart';
import '../../bloc/search/search_event.dart';
import '../../bloc/search/search_state.dart';
import '../../bloc/search/search_state.dart' show Place;

import '../../bloc/map/map_bloc.dart';
import '../../bloc/map/map_event.dart';
import '../../bloc/map/map_state.dart';

import '../../bloc/route/route_cubit.dart';
import '../../bloc/route/route_state.dart';
import '../route/route_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SheetBloc>(create: (_) => SheetBloc()),
        BlocProvider<SearchBloc>(
          create: (_) => SearchBloc()..add(const SearchLoadNearby()),
        ),
        BlocProvider<MapBloc>(create: (_) => MapBloc()..add(const MapInit())),
        BlocProvider<RouteCubit>(create: (_) => RouteCubit()),
      ],
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView({super.key});

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  final _sheetController = DraggableScrollableController();
  final _searchFocus = FocusNode();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _sheetController.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _animateSheet(double extent) {
    _sheetController.animateTo(
      extent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  // باز کردن صفحه مبدا/مقصد با فیلدهای خالی (از سرچ بار)
  Future<void> _openRouteEmpty() async {
    context.read<RouteCubit>().clearAll();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider<RouteCubit>.value(
          value: context.read<RouteCubit>(),
          child: const RouteScreen(startEmpty: true),
        ),
      ),
    );
    if (result == true) {
      final r = context.read<RouteCubit>().state;
      if (r.isReady) {
        context.read<MapBloc>().add(MapShowForPlaces([r.destination!.title]));
      }
    }
  }

  Future<void> _onMapTapDown(TapDownDetails d, Size size) async {
    final dx = (d.localPosition.dx / size.width).clamp(0.0, 1.0);
    final dy = (d.localPosition.dy / size.height).clamp(0.0, 1.0);
    context.read<RouteCubit>().setOrigin(
      Offset(dx, dy),
      label: 'Selected location',
    );

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider<RouteCubit>.value(
          value: context.read<RouteCubit>(),
          child: const RouteScreen(),
        ),
      ),
    );

    if (result == true) {
      final r = context.read<RouteCubit>().state;
      if (r.isReady) {
        context.read<MapBloc>().add(MapShowForPlaces([r.destination!.title]));
      }
    }
  }

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

  Future<void> _onSelectOrigin(Place p) async {
    final anchor = _anchorForPlace(p.title);
    context.read<RouteCubit>().setOrigin(anchor, label: p.title);

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider<RouteCubit>.value(
          value: context.read<RouteCubit>(),
          child: const RouteScreen(),
        ),
      ),
    );

    if (result == true) {
      final r = context.read<RouteCubit>().state;
      if (r.isReady) {
        context.read<MapBloc>().add(MapShowForPlaces([r.destination!.title]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayHeight = Dimens.overlayHeightFor(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (_, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              // نقشه (پس‌زمینه) + انتخاب مبدا با تپ
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _onMapTapDown(d, size),
                  child: Image.asset(
                    'assets/images/Map.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.topCenter,
                child: IgnorePointer(
                  child: Container(
                    height: overlayHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const MarkersLayer(),

              const SafeArea(child: TopBar()),

              Positioned(
                top: 64,
                left: 0,
                right: 0,
                child: Center(
                  child: BlocBuilder<RouteCubit, RouteState>(
                    builder: (_, r) {
                      final vehiclesCount = context
                          .watch<MapBloc>()
                          .state
                          .vehicles
                          .length;
                      if (!r.isReady || vehiclesCount == 0)
                        return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$vehiclesCount car${vehiclesCount == 1 ? '' : 's'} nearby',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              NotificationListener<DraggableScrollableNotification>(
                onNotification: (n) {
                  context.read<SheetBloc>().add(SheetDragUpdated(n.extent));
                  return false;
                },
                child: BlocBuilder<SheetBloc, SheetState>(
                  buildWhen: (p, c) => p.extent != c.extent,
                  builder: (context, sheetState) {
                    return DraggableScrollableSheet(
                      controller: _sheetController,
                      minChildSize: kSheetCollapsed,
                      maxChildSize: kSheetExpanded,
                      initialChildSize: kSheetCollapsed,
                      snap: true,
                      snapSizes: const [
                        kSheetCollapsed,
                        kSheetHalf,
                        kSheetExpanded,
                      ],
                      builder: (context, scrollController) {
                        final contentMaxW = Dimens.contentMaxWidth(context);
                        final bodyOpacity =
                            ((sheetState.extent - kSheetCollapsed) /
                                    (kSheetHalf - kSheetCollapsed))
                                .clamp(0.0, 1.0);

                        return Dimens.limitTextScale(
                          context: context,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF262043),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            child: ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                10,
                                16,
                                16,
                              ),
                              children: [
                                Center(
                                  child: Container(
                                    width: 44,
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: contentMaxW,
                                    ),
                                    child: _SearchBar(
                                      controller: _searchController,
                                      focusNode: _searchFocus,
                                      onTapCollapsed: () =>
                                          _animateSheet(kSheetHalf),
                                      onClear: () {
                                        context.read<SearchBloc>().add(
                                          const SearchClear(),
                                        );
                                        _searchController.clear();
                                      },
                                      onTapToRoute: _openRouteEmpty,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Opacity(
                                  opacity: bodyOpacity,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: contentMaxW,
                                    ),
                                    child: _NearbyList(
                                      onSelect: _onSelectOrigin,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTapCollapsed;
  final VoidCallback onClear;
  final VoidCallback? onTapToRoute;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onTapCollapsed,
    required this.onClear,
    this.onTapToRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapToRoute ?? onTapCollapsed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1936),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (q) =>
                        context.read<SearchBloc>().add(SearchQueryChanged(q)),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Where to?',
                      hintStyle: const TextStyle(color: Colors.white54),
                      isDense: true,
                      border: InputBorder.none,
                      suffixIcon: value.text.isEmpty
                          ? null
                          : InkWell(
                              onTap: onClear,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white54,
                                size: 18,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyList extends StatelessWidget {
  final void Function(Place) onSelect;
  const _NearbyList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (_, state) {
        final items = state.hasQuery ? state.results : state.nearby;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              state.hasQuery ? 'Results' : 'Frequent locations',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...items
                .map((p) => _NearbyTile(place: p, onTap: () => onSelect(p)))
                .toList(),
          ],
        );
      },
    );
  }
}

class _NearbyTile extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;
  const _NearbyTile({required this.place, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1936),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                place.thumb,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 42,
                  height: 42,
                  color: const Color(0xFF2A1F52),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2349),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'min away',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarkersLayer extends StatefulWidget {
  const MarkersLayer({super.key});

  @override
  State<MarkersLayer> createState() => _MarkersLayerState();
}

class _MarkersLayerState extends State<MarkersLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        return BlocBuilder<MapBloc, MapState>(
          builder: (_, state) {
            final vehicles = state.vehicles;
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final t = _ctrl.value; // 0..1
                final wave = math.sin(2 * math.pi * t); // -1..1
                final pulse = 0.5 + 0.5 * math.sin(2 * math.pi * t); // 0..1
                const ampPx = 14.0;

                return Stack(
                  children: [
                    Positioned(
                      left: state.user.dx * w - 14,
                      top: state.user.dy * h - 14,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0.25 + 0.45 * pulse,
                            child: Container(
                              width: 36 + 6 * pulse,
                              height: 36 + 6 * pulse,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/icons/Start.png',
                            width: 28,
                            height: 28,
                          ),
                        ],
                      ),
                    ),

                    ...vehicles.map((v) {
                      final dxPx = math.cos(v.rotation) * ampPx * wave;
                      final dyPx = math.sin(v.rotation) * ampPx * wave;

                      final left = v.dx * w + dxPx - 12;
                      final top = v.dy * h + dyPx - 12;

                      return Positioned(
                        left: left,
                        top: top,
                        child: Transform.rotate(
                          angle: v.rotation,
                          child: Image.asset(
                            'assets/icons/Car.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
