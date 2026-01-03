// lib/screens/admin/dashboard/widgets/estadisticas_grid.dart
import 'package:flutter/material.dart';
import '../../../../controllers/admin/dashboard_controller.dart';
import '../../../../config/routing/rutas.dart';

import '../../../../theme/jp_theme.dart';

class EstadisticasGrid extends StatelessWidget {
  final DashboardController controller;

  const EstadisticasGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildCardEstadistica(
          context,
          'Usuarios',
          controller.totalUsuarios.toString(),
          Icons.people,
          JPColors.dashboardBlue,
          '+12 este mes',
        ),
        _buildCardEstadistica(
          context,
          'Proveedores',
          controller.totalProveedores.toString(),
          Icons.store,
          JPColors.dashboardGreen,
          '${controller.proveedoresPendientes} pendientes',
        ),
        InkWell(
          onTap: () {
            controller.marcarSolicitudesPendientesVistas();
            Rutas.irA(context, Rutas.adminSolicitudesRol);
          },
          borderRadius: BorderRadius.circular(16),
          child: _buildCardEstadistica(
            context,
            'Solicitudes',
            controller.solicitudesPendientesCount.toString(),
            Icons.assignment,
            JPColors.dashboardAmber,
            'Pendientes',
          ),
        ),
        _buildCardEstadistica(
          context,
          'Repartidores',
          controller.totalRepartidores.toString(),
          Icons.delivery_dining,
          JPColors.dashboardAmber,
          '${controller.totalRepartidores - 2} activos',
        ),
        _buildCardEstadistica(
          context,
          'Ventas',
          '\$${controller.ventasTotales.toStringAsFixed(0)}', // Removed cents for cleaner look
          Icons.attach_money,
          JPColors.dashboardGreen,
          '+8% vs mes anterior',
        ),
        _buildCardEstadistica(
          context,
          'Pedidos',
          controller.pedidosActivos.toString(),
          Icons.shopping_cart,
          JPColors.dashboardViolet,
          'En proceso',
        ),
      ],
    );
  }

  Widget _buildCardEstadistica(
    BuildContext context,
    String titulo,
    String valor,
    IconData icono,
    Color color,
    String subtitulo,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: JPCupertinoColors.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, color: color, size: 20),
                ),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: JPCupertinoColors.label(context),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: JPCupertinoColors.secondaryLabel(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 11,
                    color: JPCupertinoColors.tertiaryLabel(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
