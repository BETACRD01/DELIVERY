// lib/screens/delivery/widgets/card_encargo_disponible.dart
// Widget para mostrar encargos disponibles para repartidores

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/orders/pedido_repartidor.dart';
import '../../../theme/jp_theme.dart';

/// Card para encargos (courier) disponibles
/// Diseño distintivo con icono naranja y flujo de dos destinos
class CardEncargoDisponible extends StatelessWidget {
  final PedidoDisponible encargo;
  final VoidCallback? onAceptar;
  final VoidCallback? onRechazar;

  const CardEncargoDisponible({
    super.key,
    required this.encargo,
    this.onAceptar,
    this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = JPCupertinoColors.secondarySurface(context);
    final cardBorder = JPCupertinoColors.separator(context);
    final textSecondary = JPCupertinoColors.secondaryLabel(context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    // Colores dinámicos
    final colorEncargo = JPCupertinoColors.systemOrange(context);
    final successColor = JPCupertinoColors.success(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 0.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icono + Título + Distancia
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorEncargo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    CupertinoIcons.paperplane_fill,
                    color: colorEncargo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📦 Encargo #${encargo.numeroPedido}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Servicio de Courier',
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: JPCupertinoColors.systemGrey5(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${encargo.distanciaKm.toStringAsFixed(1)} km',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Zona de entrega
            Row(
              children: [
                const Icon(
                  CupertinoIcons.location_solid,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    encargo.zonaEntrega,
                    style: TextStyle(
                      color: JPCupertinoColors.label(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tiempo y Total
            Row(
              children: [
                const Icon(CupertinoIcons.time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${encargo.tiempoEstimadoMin} min',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 20),
                const Icon(
                  CupertinoIcons.money_dollar,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '\$${encargo.totalConRecargo.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: JPCupertinoColors.label(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Método de pago y Ganancia
            Row(
              children: [
                const Icon(
                  CupertinoIcons.creditcard,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  encargo.metodoPago,
                  style: TextStyle(
                    color: JPCupertinoColors.label(context),
                    fontSize: 13,
                  ),
                ),
                if (encargo.comisionRepartidor != null) ...[
                  const Spacer(),
                  Icon(
                    CupertinoIcons.money_dollar_circle_fill,
                    size: 16,
                    color: successColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ganancia \$${encargo.gananciaTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: successColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: JPCupertinoColors.systemGrey5(context),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: onRechazar,
                    child: Text(
                      'Rechazar',
                      style: TextStyle(
                        color: JPCupertinoColors.label(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: colorEncargo,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: onAceptar,
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
