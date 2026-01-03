// lib/screens/admin/dashboard/widgets/tarjeta_solicitud.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../models/auth/solicitud_cambio_rol.dart';
import '../../../../theme/jp_theme.dart';

class TarjetaSolicitud extends StatelessWidget {
  final SolicitudCambioRol solicitud;
  final VoidCallback onTap;

  const TarjetaSolicitud({
    super.key,
    required this.solicitud,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = JPCupertinoColors.surface(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        // No shadow to mimic iOS grouped list items, or very subtle one
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar con icono según el rol
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (solicitud.esProveedor
                                ? JPColors.success
                                : CupertinoColors.activeBlue)
                            .withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Icon(
                      solicitud.iconoRol,
                      color: solicitud.esProveedor
                          ? JPColors.success
                          : CupertinoColors.activeBlue,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solicitud.usuarioNombre ?? solicitud.usuarioEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: JPCupertinoColors.label(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        solicitud.esProveedor
                            ? 'Solicita ser Proveedor'
                            : 'Solicita ser Repartidor',
                        style: TextStyle(
                          fontSize: 13,
                          color: JPCupertinoColors.secondaryLabel(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
