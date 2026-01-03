import 'package:flutter/material.dart';
import '../../theme/jp_theme.dart';

class PedidoUtils {
  static Color getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmado':
        return JPColors.warning;
      case 'en_preparacion':
        return JPColors.dashboardBlue;
      case 'en_ruta':
        return JPColors.primary;
      case 'entregado':
        return JPColors.success;
      case 'cancelado':
        return JPColors.error;
      default:
        return Colors.grey;
    }
  }

  static Color getColorFondoEstado(String estado) {
    return getColorEstado(estado).withValues(alpha: 0.1);
  }

  static Widget buildEstadoBadge(String estado, String estadoDisplay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getColorFondoEstado(estado),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getColorEstado(estado).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        estadoDisplay,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: getColorEstado(estado),
        ),
      ),
    );
  }
}
