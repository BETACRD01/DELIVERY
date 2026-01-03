import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../apis/admin/acciones_admin_api.dart';
import '../../../../theme/jp_theme.dart';

class ActividadTab extends StatefulWidget {
  const ActividadTab({super.key});

  @override
  State<ActividadTab> createState() => _ActividadTabState();
}

class _ActividadTabState extends State<ActividadTab> {
  final _api = AccionesAdminAPI();
  bool _loading = true;
  String? _error;
  List<dynamic> _acciones = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.listar(pageSize: 20);
      if (!mounted) return;

      final results = data['results'];
      setState(() {
        _acciones = results is List ? results : [];
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo cargar el historial');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: JPColors.error)),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: _cargar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_acciones.isEmpty) {
      return Center(
        child: Text(
          'Sin actividad reciente',
          style: TextStyle(color: JPCupertinoColors.secondaryLabel(context)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      color: JPCupertinoColors.primary(context),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _acciones.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: JPCupertinoColors.separator(context)),
        itemBuilder: (context, index) {
          final a = _acciones[index] as Map<String, dynamic>;
          final titulo =
              a['tipo_accion_display'] ?? a['tipo_accion'] ?? 'Acción';
          final desc = a['descripcion'] ?? a['resumen'] ?? '';
          final admin = a['admin_email'] ?? 'Admin';
          final fecha = a['fecha_accion']?.toString() ?? '';
          final exitosa = a['exitosa'] != false;

          return _buildListItem(
            titulo: titulo,
            descripcion: desc,
            admin: admin,
            fecha: fecha,
            exitosa: exitosa,
          );
        },
      ),
    );
  }

  Widget _buildListItem({
    required String titulo,
    required String descripcion,
    required String admin,
    required String fecha,
    required bool exitosa,
  }) {
    final color = exitosa ? JPColors.success : JPColors.error;
    final icon = exitosa ? Icons.check : Icons.error_outline;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: JPCupertinoColors.label(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fecha,
                      style: TextStyle(
                        fontSize: 11,
                        color: JPCupertinoColors.tertiaryLabel(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: JPCupertinoColors.secondaryLabel(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  admin,
                  style: TextStyle(
                    fontSize: 12,
                    color: JPCupertinoColors.tertiaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
