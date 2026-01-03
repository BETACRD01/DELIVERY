// lib/screens/user/inicio/widgets/seccion_promociones.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/theme/primary_colors.dart';
import 'package:mobile/theme/secondary_colors.dart';
import 'package:mobile/theme/jp_theme.dart';

import '../../../../../models/products/promocion_model.dart';

class SeccionPromociones extends StatefulWidget {
  final List<PromocionModel> promociones;
  final Function(PromocionModel)? onPromocionPressed;
  final bool loading;

  const SeccionPromociones({
    super.key,
    required this.promociones,
    this.onPromocionPressed,
    this.loading = false,
  });

  @override
  State<SeccionPromociones> createState() => _SeccionPromocionesState();
}

class _SeccionPromocionesState extends State<SeccionPromociones> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loading && widget.promociones.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Text(
                'Promociones Especiales',
                style: TextStyle(
                  fontSize: 20, // Slightly larger
                  fontWeight: FontWeight.bold,
                  color: AppColorsSupport.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Spacer(),
              if (widget.loading) const CupertinoActivityIndicator(radius: 10),
            ],
          ),
        ),

        SizedBox(
          height: 190,
          child: widget.loading
              ? _buildLoadingList()
              : PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.promociones.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: _PromocionCardImpacto(
                        promocion: widget.promociones[index],
                        onTap: () => widget.onPromocionPressed?.call(
                          widget.promociones[index],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Indicadores de página (dots)
        if (!widget.loading && widget.promociones.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.promociones.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColorsPrimary.main
                        : AppColorsPrimary.main.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      separatorBuilder: (_, _) => SizedBox(width: 14),
      itemBuilder: (_, _) => Container(
        width: 300,
        decoration: BoxDecoration(
          color: JPCupertinoColors.systemGrey5(context),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
      ),
    );
  }
}

/// Tarjeta de Promoción: Diseño "Impacto Visual"
class _PromocionCardImpacto extends StatelessWidget {
  final PromocionModel promocion;
  final VoidCallback? onTap;

  const _PromocionCardImpacto({required this.promocion, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Keep internal colors logic for promo card but refine shadows
    final cardColor = promocion.color;
    final vence = promocion.textoTiempoRestante;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300, // Tarjeta protagonista pero compacta
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusLarge,
          ), // Bordes suaves
          boxShadow: [
            BoxShadow(
              color: JPCupertinoColors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo color base
              Container(color: cardColor),

              _buildBackgroundImage(),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      JPCupertinoColors.black.withValues(alpha: 0.05),
                      JPCupertinoColors.black.withValues(
                        alpha: 0.65,
                      ), // Negro sólido abajo
                    ],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Badge(
                      icon: CupertinoIcons.tag_fill, // iOS Icon
                      text: promocion.descuento.isNotEmpty
                          ? promocion.descuento.toUpperCase()
                          : 'PROMO',
                      color: JPCupertinoColors.white,
                      background: JPCupertinoColors.white.withValues(
                        alpha: 0.2,
                      ),
                    ),
                    SizedBox(height: 12),

                    Text(
                      promocion.titulo,
                      style: TextStyle(
                        color: JPCupertinoColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: JPCupertinoColors.black.withValues(
                              alpha: 0.87,
                            ),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6),

                    Text(
                      promocion.descripcion,
                      style: TextStyle(
                        color: JPCupertinoColors.white.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: JPCupertinoColors.black.withValues(
                              alpha: 0.54,
                            ),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    if (vence.isNotEmpty)
                      _Badge(
                        icon: CupertinoIcons.time,
                        text: vence,
                        color: JPCupertinoColors.white,
                        background: JPCupertinoColors.black.withValues(
                          alpha: 0.3,
                        ),
                        compact: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la imagen de fondo adaptativa
  Widget _buildBackgroundImage() {
    if (promocion.imagenUrl != null && promocion.imagenUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: promocion.imagenUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Center(child: CupertinoActivityIndicator(radius: 14)),
        errorWidget: (context, url, error) => _buildFallbackDecoration(),
      );
    } else {
      return _buildFallbackDecoration();
    }
  }

  /// Decoración por si no hay imagen (Icono gigante de fondo)
  Widget _buildFallbackDecoration() {
    return Stack(
      children: [
        Positioned(
          right: -40,
          bottom: -40,
          child: Icon(
            Icons.fastfood_rounded,
            size: 180,
            color: JPCupertinoColors.white.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color background;
  final bool compact;

  const _Badge({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: compact ? 14 : 16),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
