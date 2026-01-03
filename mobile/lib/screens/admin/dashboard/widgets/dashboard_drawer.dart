import 'package:flutter/material.dart';

import '../../../../theme/jp_theme.dart';
import '../../../../config/routing/rutas.dart';
import '../../../../config/network/api_config.dart';

class DashboardDrawer extends StatelessWidget {
  final Map<String, dynamic>? usuario;
  final int solicitudesPendientesCount;
  final Function(String) onSeccionNoDisponible;
  final VoidCallback onCerrarSesion;
  final VoidCallback onSolicitudesTap;
  final Function()? onActualizarFoto;

  const DashboardDrawer({
    super.key,
    required this.usuario,
    required this.solicitudesPendientesCount,
    required this.onSeccionNoDisponible,
    required this.onCerrarSesion,
    required this.onSolicitudesTap,
    this.onActualizarFoto,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = JPCupertinoColors.background(context);

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildSectionTitle('PRINCIPAL', context),
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isActive:
                        true, // Assuming current route logic or state if needed
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.people_outline,
                    title: 'Usuarios',
                    onTap: () {
                      Navigator.pop(context);
                      Rutas.irA(context, Rutas.adminUsuariosGestion);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.store_outlined,
                    title: 'Proveedores',
                    onTap: () {
                      Navigator.pop(context);
                      Rutas.irA(context, Rutas.adminProveedoresGestion);
                    },
                  ),
                  _buildSolicitudesMenuItem(context),
                  _buildMenuItem(
                    context,
                    icon: Icons.delivery_dining_outlined,
                    title: 'Repartidores',
                    onTap: () {
                      Navigator.pop(context);
                      Rutas.irA(context, Rutas.adminRepartidoresGestion);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.card_giftcard_outlined,
                    title: 'Rifas',
                    onTap: () {
                      Navigator.pop(context);
                      Rutas.irA(context, Rutas.adminRifasGestion);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildLogoutButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final rawUrl = usuario?['foto_perfil'] as String?;
    final fotoUrl = (rawUrl != null && rawUrl.isNotEmpty)
        ? ApiConfig.getMediaUrl(rawUrl)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: JPCupertinoColors.primary(
                    context,
                  ).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  image: fotoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(fotoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: fotoUrl == null
                    ? Center(
                        child: Text(
                          (usuario?['nombre'] ?? 'A')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            color: JPCupertinoColors.primary(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      )
                    : null,
              ),
              if (onActualizarFoto != null)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: InkWell(
                    onTap: onActualizarFoto,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: JPCupertinoColors.primary(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: JPCupertinoColors.background(context),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${usuario?['nombre'] ?? 'Admin'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: JPCupertinoColors.label(context),
                  ),
                ),
                Text(
                  usuario?['email'] ?? 'admin@deliber.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: JPCupertinoColors.secondaryLabel(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: JPCupertinoColors.tertiaryLabel(context),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
    Widget? trailing,
  }) {
    final activeBg = JPCupertinoColors.primary(context).withValues(alpha: 0.1);
    final activeColor = JPCupertinoColors.primary(context);
    final inactiveColor = JPCupertinoColors.label(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? activeColor
              : JPCupertinoColors.secondaryLabel(context),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? activeColor : inactiveColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        dense: true,
      ),
    );
  }

  Widget _buildSolicitudesMenuItem(BuildContext context) {
    return _buildMenuItem(
      context,
      icon: Icons.notifications_none,
      title: 'Solicitudes',
      onTap: () {
        Navigator.pop(context);
        onSolicitudesTap();
      },
      trailing: solicitudesPendientesCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$solicitudesPendientesCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onCerrarSesion();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: JPCupertinoColors.systemGrey5(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: JPColors.error, size: 20),
            const SizedBox(width: 8),
            Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: JPColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
