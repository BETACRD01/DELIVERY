// lib/screens/admin/dashboard/widgets/solicitudes_section.dart
import 'package:flutter/cupertino.dart'; // Added Cupertino
import 'package:flutter/material.dart';
import '../../../../controllers/admin/dashboard_controller.dart';
import '../../../../theme/jp_theme.dart';
import '../../../../config/routing/rutas.dart';
import '../../../../models/auth/solicitud_cambio_rol.dart';
import 'tarjeta_solicitud.dart';
import 'detalle_solicitud_modal.dart';

class SolicitudesSection extends StatelessWidget {
  final DashboardController controller;

  const SolicitudesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTarjetaResumen(context),
        const SizedBox(height: 16),

        ...controller.solicitudesPendientes.take(5).map((solicitud) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TarjetaSolicitud(
              solicitud: solicitud,
              onTap: () => _mostrarDetalleSolicitud(context, solicitud),
            ),
          );
        }),

        if (controller.solicitudesPendientesCount > 5) ...[
          const SizedBox(height: 12),
          CupertinoButton(
            // Changed to CupertinoButton
            onPressed: () {
              controller.marcarSolicitudesPendientesVistas();
              Rutas.irA(context, Rutas.adminSolicitudesRol);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ver todas (${controller.solicitudesPendientesCount})'),
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.right_chevron, size: 14),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTarjetaResumen(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: JPCupertinoColors.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.marcarSolicitudesPendientesVistas();
            Rutas.irA(context, Rutas.adminSolicitudesRol);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: JPColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    color: JPColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.solicitudesPendientesCount} Solicitudes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: JPCupertinoColors.label(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pendientes de revisión',
                        style: TextStyle(
                          fontSize: 14,
                          color: JPCupertinoColors.secondaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: JPCupertinoColors.secondaryLabel(context),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleSolicitud(
    BuildContext context,
    SolicitudCambioRol solicitud,
  ) {
    controller.marcarSolicitudesPendientesVistas();
    // Assuming DetalleSolicitudModal handles iOS style inside, or we might need to check it
    DetalleSolicitudModal.mostrar(
      context: context,
      solicitud: solicitud,
      onAceptar: (motivo) async {
        await controller.aceptarSolicitud(solicitud.id, motivo: motivo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Solicitud aceptada exitosamente'),
              backgroundColor: JPColors.success,
            ),
          );
        }
      },
      onRechazar: (motivo) async {
        await controller.rechazarSolicitud(solicitud.id, motivo);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Solicitud rechazada'),
              backgroundColor: JPColors.warning,
            ),
          );
        }
      },
    );
  }
}
