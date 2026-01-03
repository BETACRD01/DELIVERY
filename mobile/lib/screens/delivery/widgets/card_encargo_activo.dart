// lib/screens/delivery/widgets/card_encargo_activo.dart
// Widget para mostrar encargos activos con flujo de dos etapas

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/orders/pedido_repartidor.dart';
import '../../../theme/jp_theme.dart';

/// Card expandido para encargos (courier) en curso
/// Muestra flujo de dos etapas: Recoger → Entregar
class CardEncargoActivo extends StatelessWidget {
  final PedidoDetalladoRepartidor encargo;
  final VoidCallback? onMarcarRecogido;
  final VoidCallback? onMarcarEntregado;
  final VoidCallback? onNavegar;
  final VoidCallback? onLlamar;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onVerComprobante;

  const CardEncargoActivo({
    super.key,
    required this.encargo,
    this.onMarcarRecogido,
    this.onMarcarEntregado,
    this.onNavegar,
    this.onLlamar,
    this.onWhatsApp,
    this.onVerComprobante,
  });

  /// Determina si el repartidor ya recogió el paquete
  bool get _yaRecogio {
    final estado = encargo.estado.toLowerCase();
    return estado == 'en_camino' || estado == 'entregado';
  }

  /// Determina si el encargo ya fue entregado
  bool get _yaEntregado {
    return encargo.estado.toLowerCase() == 'entregado';
  }

  /// Determina si tiene comprobante de transferencia para mostrar
  bool get _tieneComprobante {
    return encargo.metodoPago.toLowerCase() == 'transferencia' &&
        encargo.transferenciaComprobanteUrl != null &&
        encargo.transferenciaComprobanteUrl!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Colors
    final cardBg = JPCupertinoColors.secondarySurface(context);
    final cardBorder = JPCupertinoColors.separator(context);
    final textPrimary = JPCupertinoColors.label(context);
    final textSecondary = JPCupertinoColors.secondaryLabel(context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    final colorEncargo = JPCupertinoColors.systemOrange(context);
    final accent = JPCupertinoColors.systemBlue(context);
    final success = JPCupertinoColors.success(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 0.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Badge + Estado
            _buildHeader(context, colorEncargo, accent, success),

            const SizedBox(height: 16),

            // Indicador de etapa visual
            _buildEtapaIndicador(
              context,
              textSecondary,
              colorEncargo,
              accent,
              success,
            ),

            const SizedBox(height: 16),

            // Direcciones (origen y destino)
            _buildDirecciones(
              context,
              textPrimary,
              textSecondary,
              colorEncargo,
              accent,
            ),

            const SizedBox(height: 16),

            // Detalles del encargo (siempre mostrar - incluye receptor e instrucciones)
            const SizedBox(height: 12),
            _buildDetallesCourier(
              context,
              colorEncargo,
              textPrimary,
              textSecondary,
              accent,
            ),

            // Comprobante de transferencia (si existe)
            if (_tieneComprobante) ...[
              const SizedBox(height: 12),
              _buildComprobanteSection(context, success, accent),
            ],

            const SizedBox(height: 16),

            // Totales
            _buildTotales(context, success, textPrimary, textSecondary),

            const SizedBox(height: 16),

            // Botones de acción
            _buildBotonesAccion(context, success, accent, colorEncargo),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color colorEncargo,
    Color accent,
    Color success,
  ) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorEncargo.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.paperplane_fill,
                  size: 18,
                  color: colorEncargo,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '📦 Encargo #${encargo.numeroPedido}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildChipEstado(colorEncargo, accent, success),
      ],
    );
  }

  Widget _buildChipEstado(Color colorEncargo, Color accent, Color success) {
    Color color;
    String texto;

    if (_yaEntregado) {
      color = success;
      texto = 'Entregado';
    } else if (_yaRecogio) {
      color = accent;
      texto = 'En Camino';
    } else {
      color = colorEncargo;
      texto = 'Por Recoger';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEtapaIndicador(
    BuildContext context,
    Color textSecondary,
    Color colorEncargo,
    Color accent,
    Color success,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (_yaRecogio ? accent : colorEncargo).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_yaRecogio ? accent : colorEncargo).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Etapa 1: Recoger
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _yaRecogio ? success : colorEncargo,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _yaRecogio
                        ? CupertinoIcons.checkmark
                        : CupertinoIcons.arrow_up_circle_fill,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _yaRecogio ? 'Recogido' : 'Ir a Recoger',
                    style: TextStyle(
                      fontWeight: _yaRecogio
                          ? FontWeight.w500
                          : FontWeight.bold,
                      fontSize: 13,
                      color: _yaRecogio ? textSecondary : colorEncargo,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Línea conectora
          Container(
            width: 30,
            height: 2,
            color: _yaRecogio ? success : Colors.grey.shade300,
          ),
          // Etapa 2: Entregar
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    _yaEntregado ? 'Entregado' : 'Ir a Entregar',
                    style: TextStyle(
                      fontWeight: _yaRecogio && !_yaEntregado
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
                      color: _yaRecogio
                          ? (_yaEntregado ? success : accent)
                          : textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _yaEntregado
                        ? success
                        : (_yaRecogio ? accent : Colors.grey.shade300),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _yaEntregado
                        ? CupertinoIcons.checkmark
                        : CupertinoIcons.location_fill,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirecciones(
    BuildContext context,
    Color textPrimary,
    Color textSecondary,
    Color colorEncargo,
    Color accent,
  ) {
    final origenActivo = !_yaRecogio;
    final destinoActivo = _yaRecogio && !_yaEntregado;

    return Column(
      children: [
        // Punto de Recogida (Origen)
        _buildDireccionItem(
          context,
          icono: CupertinoIcons.arrow_up_circle_fill,
          color: origenActivo ? colorEncargo : textSecondary,
          titulo: 'PUNTO DE RECOGIDA',
          direccion: encargo.direccionOrigen ?? 'Origen no especificado',
          activo: origenActivo,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),

        // Línea conectora
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Row(
            children: [
              Container(width: 2, height: 24, color: Colors.grey.shade300),
            ],
          ),
        ),

        // Punto de Entrega (Destino)
        _buildDireccionItem(
          context,
          icono: CupertinoIcons.location_fill,
          color: destinoActivo ? accent : textSecondary,
          titulo: 'PUNTO DE ENTREGA',
          direccion: encargo.direccionEntrega,
          activo: destinoActivo,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
      ],
    );
  }

  Widget _buildDireccionItem(
    BuildContext context, {
    required IconData icono,
    required Color color,
    required String titulo,
    required String direccion,
    required bool activo,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: activo
            ? color.withValues(alpha: 0.08)
            : JPCupertinoColors.secondarySystemFill(context),
        borderRadius: BorderRadius.circular(10),
        border: activo ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  direccion,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
                    color: activo ? textPrimary : textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (activo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ACTUAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Sección de detalles del encargo con formato ordenado
  /// Separa correctamente: Cliente (solicitante) vs Receptor (quien recibe)
  Widget _buildDetallesCourier(
    BuildContext context,
    Color colorEncargo,
    Color textPrimary,
    Color textSecondary,
    Color accent,
  ) {
    // Parsing básico
    final descripcionOriginal = encargo.descripcion ?? '';
    String tipoPaquete = 'Paquete';
    String descripcionContenido = '';
    String parteReceptor = '';

    String receptorNombre = '';
    String receptorTelefono = '';

    // Extraer el tipo de paquete
    if (descripcionOriginal.contains('Courier:')) {
      final partes = descripcionOriginal.split('Receptor:');
      if (partes.isNotEmpty) {
        final primeraParte = partes[0].replaceFirst('Courier:', '').trim();
        if (primeraParte.contains('-')) {
          final splitTipo = primeraParte.split('-');
          tipoPaquete = splitTipo[0].trim();
          descripcionContenido = splitTipo.length > 1
              ? splitTipo[1].trim()
              : '';
          if (descripcionContenido.endsWith('.')) {
            descripcionContenido = descripcionContenido.substring(
              0,
              descripcionContenido.length - 1,
            );
          }
        } else {
          descripcionContenido = primeraParte;
        }

        if (partes.length > 1) {
          parteReceptor = partes[1].trim();
        }
      }

      if (parteReceptor.isNotEmpty) {
        final regexReceptor = RegExp(r'^(.+?)\s*\((.+?)\)$');
        final match = regexReceptor.firstMatch(parteReceptor);
        if (match != null) {
          receptorNombre = match.group(1)?.trim() ?? '';
          receptorTelefono = match.group(2)?.trim() ?? '';
        } else {
          receptorNombre = parteReceptor;
        }
      }
    } else {
      descripcionContenido = descripcionOriginal;
    }

    final tieneReceptor = receptorNombre.isNotEmpty;
    final instrucciones = encargo.instruccionesEntrega ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: JPCupertinoColors.tertiarySurface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorEncargo.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Row(
            children: [
              Icon(CupertinoIcons.doc_text_fill, color: colorEncargo, size: 18),
              const SizedBox(width: 8),
              Text(
                'DETALLES DEL ENCARGO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorEncargo,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 1. Tipo de Paquete
          _buildDetalleRow(
            context,
            icono: _getIconoTipoPaquete(tipoPaquete),
            label: 'Tipo',
            valor: tipoPaquete,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          // 2. Descripción del contenido (si existe)
          if (descripcionContenido.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDetalleRow(
              context,
              icono: CupertinoIcons.text_alignleft,
              label: 'Descripción',
              valor: descripcionContenido,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              multiline: true,
            ),
          ],

          // 3. SOLICITADO POR - Cliente que pidió el encargo
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: JPCupertinoColors.systemGrey6(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📱 SOLICITADO POR:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            encargo.cliente.nombre,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textPrimary,
                            ),
                          ),
                          if (encargo.cliente.telefono != null &&
                              encargo.cliente.telefono!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.phone_fill,
                                  color: textSecondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  encargo.cliente.telefono!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 4. ENTREGAR A - Receptor del paquete
          if (tieneReceptor) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📦 ENTREGAR A:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(CupertinoIcons.person_fill, color: accent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          receptorNombre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (receptorTelefono.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.phone_fill,
                          color: accent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          receptorTelefono,
                          style: TextStyle(fontSize: 14, color: textPrimary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // 5. Instrucciones de Entrega
          if (instrucciones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_circle_fill,
                        color: Colors.amber.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'INSTRUCCIONES ESPECIALES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    instrucciones,
                    style: TextStyle(fontSize: 14, color: textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Obtiene el ícono según el tipo de paquete
  IconData _getIconoTipoPaquete(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'documentos':
        return CupertinoIcons.doc_text;
      case 'llaves':
        return CupertinoIcons.lock_fill;
      case 'otro':
        return CupertinoIcons.question_circle;
      default:
        return CupertinoIcons.cube_box_fill;
    }
  }

  /// Widget para mostrar una fila de detalle con formato consistente
  Widget _buildDetalleRow(
    BuildContext context, {
    required IconData icono,
    required String label,
    required String valor,
    required Color textPrimary,
    required Color textSecondary,
    bool multiline = false,
  }) {
    return Row(
      crossAxisAlignment: multiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icono, color: textSecondary, size: 16),
        const SizedBox(width: 8),
        if (multiline)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(valor, style: TextStyle(fontSize: 14, color: textPrimary)),
              ],
            ),
          )
        else ...[
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// Sección para mostrar el comprobante de transferencia del encargo
  Widget _buildComprobanteSection(
    BuildContext context,
    Color success,
    Color accent,
  ) {
    return GestureDetector(
      onTap: onVerComprobante,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: success,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comprobante de Transferencia',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'El cliente ya subió el comprobante',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, color: success, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTotales(
    BuildContext context,
    Color success,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      children: [
        _buildMoneyRow(
          context,
          'Total a Cobrar:',
          encargo.total,
          textPrimary,
          textSecondary,
        ),
        const SizedBox(height: 8),
        _buildMoneyRow(
          context,
          'Tu Ganancia:',
          encargo.comisionRepartidor,
          textPrimary,
          textSecondary,
          isTotal: true,
          color: success,
        ),
      ],
    );
  }

  Widget _buildMoneyRow(
    BuildContext context,
    String label,
    double? amount,
    Color textPrimary,
    Color textSecondary, {
    bool isTotal = false,
    Color? color,
  }) {
    if (amount == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            color: color ?? textSecondary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color ?? textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBotonesAccion(
    BuildContext context,
    Color success,
    Color accent,
    Color colorEncargo,
  ) {
    if (_yaEntregado) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: success),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: success, size: 20),
            const SizedBox(width: 8),
            Text(
              'Entregado',
              style: TextStyle(color: success, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Botón Navegar
        Expanded(
          child: _buildBotonAccion(
            context,
            'Navegar',
            CupertinoIcons.location_fill,
            accent,
            onNavegar,
            isSecondary: true,
          ),
        ),
        const SizedBox(width: 12),
        // Botón de acción principal
        Expanded(
          child: _buildBotonAccion(
            context,
            _yaRecogio ? 'Entregado' : 'Recogido',
            _yaRecogio
                ? CupertinoIcons.checkmark_seal_fill
                : CupertinoIcons.cube_box_fill,
            _yaRecogio ? success : colorEncargo,
            _yaRecogio ? onMarcarEntregado : onMarcarRecogido,
          ),
        ),
      ],
    );
  }

  Widget _buildBotonAccion(
    BuildContext context,
    String texto,
    IconData icono,
    Color color,
    VoidCallback? onTap, {
    bool isSecondary = false,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: isSecondary ? color.withValues(alpha: 0.1) : color,
      disabledColor: color.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: isSecondary ? color : Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: isSecondary ? color : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
