// lib/widgets/floating_top_bar.dart
import 'package:flutter/material.dart';

enum FloatingTopBarLeading { menu, back, none }

class FloatingTopBar extends StatelessWidget {
  final String title;
  final FloatingTopBarLeading leading;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;

  // Cerca
  final bool showSearch;
  final ValueNotifier<bool>? searchVisible;

  // Preferiti
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  // Condividi
  final bool showShare;
  final VoidCallback? onSharePressed;

  //Filtra
  final bool showFilter;
  final bool isFilterActive;
  final VoidCallback? onFilterPressed;

  // Grafici
  final bool showCharts;
  final bool isChartsVisible;
  final VoidCallback? onChartsPressed;


  const FloatingTopBar({
    super.key,
    required this.title,
    this.leading = FloatingTopBarLeading.menu,
    this.onMenuPressed,
    this.onBackPressed,
    this.showSearch = false,
    this.searchVisible,
    this.showFilter = false,
    this.isFilterActive = false,
    this.onFilterPressed,
    this.showCharts = false,
    this.isChartsVisible = false,
    this.onChartsPressed,

    // Default azioni
    this.showFavorite = false,
    this.isFavorite = false,
    this.onFavoritePressed,
    this.showShare = false,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.9);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 30,
            offset: const Offset(0, -40),
            spreadRadius: 40,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                _buildLeading(context),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    switch (leading) {
      case FloatingTopBarLeading.menu:
        return Builder(
          builder: (ctx) => IconButton.filledTonal(
            style: IconButton.styleFrom(shape: const CircleBorder()),
            icon: const Icon(Icons.menu),
            onPressed: onMenuPressed ?? () => Scaffold.of(ctx).openDrawer(),
          ),
        );
      case FloatingTopBarLeading.back:
        return IconButton.filledTonal(
          style: IconButton.styleFrom(shape: const CircleBorder()),
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
        );
      case FloatingTopBarLeading.none:
        return const SizedBox(width: 48, height: 48);
    }
  }

  Widget _buildActions(BuildContext context) {
    final List<Widget> right = [];

    // Cerca
    if (showSearch && searchVisible != null) {
      right.add(
        ValueListenableBuilder<bool>(
          valueListenable: searchVisible!,
          builder: (context, visible, _) {
            return IconButton.filledTonal(
              style: IconButton.styleFrom(shape: const CircleBorder()),
              icon: Icon(visible ? Icons.close : Icons.search),
              onPressed: () {
                searchVisible!.value = !visible;
                FocusScope.of(context).unfocus();
              },
            );
          },
        ),
      );
    }

    // Preferiti
    if (showFavorite) {
      right.add(
        IconButton.filledTonal(
          style: IconButton.styleFrom(shape: const CircleBorder()),
          icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          onPressed: onFavoritePressed,
        ),
      );
    }

    // Condividi
    if (showShare) {
      right.add(
        IconButton.filledTonal(
          style: IconButton.styleFrom(shape: const CircleBorder()),
          icon: const Icon(Icons.share),
          onPressed: onSharePressed,
        ),
      );
    }

    //Filtra
    if (showFilter) {
      right.add(
        IconButton.filledTonal(
          style: IconButton.styleFrom(shape: const CircleBorder()),
          icon: Icon(isFilterActive ? Icons.filter_alt_off : Icons.filter_alt),
          onPressed: onFilterPressed,
        ),
      );
    }

    // Grafici
    if (showCharts) {
      right.add(
        IconButton.filledTonal(
          style: IconButton.styleFrom(shape: const CircleBorder()),
          icon: Icon(isChartsVisible ? Icons.list : Icons.auto_graph),
          onPressed: onChartsPressed,
        ),
      );
    }

    if (right.isEmpty) {
      return const SizedBox(width: 48, height: 48);
    }
    return Row(mainAxisSize: MainAxisSize.min, children: right);
  }
}
