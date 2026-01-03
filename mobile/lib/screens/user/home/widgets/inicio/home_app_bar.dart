// lib/screens/user/inicio/widgets/inicio/home_app_bar.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import 'package:mobile/theme/jp_theme.dart';

/// AppBar estilo iOS para Home.
class HomeAppBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onLogoutTap;
  final int unreadCount;
  final String title;
  final String? logoAssetPath;
  final String? logoNetworkUrl;

  const HomeAppBar({
    super.key,
    this.onNotificationTap,
    this.onSearchTap,
    this.onLogoutTap,
    this.unreadCount = 0,
    this.title = 'JP Express',
    this.logoAssetPath = 'assets/images/Beta.png',
    this.logoNetworkUrl,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 16),
        decoration: BoxDecoration(
          color: JPCupertinoColors.surface(context),
          boxShadow: AppConstants.subtleShadow(context),
        ),
        child: Column(
          children: [
            // Header: Logo + Título + Acciones
            Row(
              children: [
                // Logo
                _Logo(
                  size: 60,
                  assetPath: logoAssetPath,
                  networkUrl: logoNetworkUrl,
                ),
                SizedBox(width: 14),

                // Título
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 24, // Matches iOS big title better
                      fontWeight: FontWeight.w800,
                      color: JPCupertinoColors.primary(
                        context,
                      ), // Corporate Celeste
                      letterSpacing: -0.8,
                    ),
                  ),
                ),

                // Notificaciones
                _ActionButton(
                  icon: CupertinoIcons.bell_fill,
                  badge: unreadCount,
                  color: JPCupertinoColors.primary(
                    context,
                  ), // Corporate Celeste
                  onTap: onNotificationTap,
                ),
                SizedBox(width: 8),

                // Logout
                _ActionButton(
                  icon: CupertinoIcons.square_arrow_right,
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),

            SizedBox(height: 14),

            // Barra de búsqueda
            _SearchBar(onTap: onSearchTap),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Cerrar sesión'),
        content: Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('¿Estás seguro de que deseas cerrar sesión?'),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              onLogoutTap?.call();
            },
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final double size;
  final String? assetPath;
  final String? networkUrl;

  const _Logo({required this.size, this.assetPath, this.networkUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: networkUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(context),
        errorWidget: (_, _, _) => _placeholder(context),
      );
    }

    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }

    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: JPCupertinoColors.systemGrey5(context),
      child: Icon(
        CupertinoIcons.cube_box_fill,
        color: JPCupertinoColors.systemGrey(context),
        size: size * 0.5,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int badge;
  final bool isDestructive;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    this.badge = 0,
    this.isDestructive = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDestructive
              ? JPCupertinoColors.error(context).withValues(alpha: 0.1)
              : JPCupertinoColors.systemGrey6(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? JPCupertinoColors.error(context)
                  : (color ?? JPCupertinoColors.label(context)),
              size: 22,
            ),
            if (badge > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: JPCupertinoColors.error(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: JPCupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const _SearchBar({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: JPCupertinoColors.systemGrey6(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.search,
              color: JPCupertinoColors.placeholderText(context),
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Buscar productos o tiendas',
                style: TextStyle(
                  color: JPCupertinoColors.placeholderText(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.slider_horizontal_3,
              color: JPCupertinoColors.placeholderText(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
