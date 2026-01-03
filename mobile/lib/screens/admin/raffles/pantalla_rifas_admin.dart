import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../apis/admin/rifas_admin_api.dart';
import '../../../config/network/api_config.dart';
import '../../../theme/jp_theme.dart';
import 'pantalla_crear_rifa.dart';
import 'pantalla_rifa_detalle.dart';

class PantallaRifasAdmin extends StatefulWidget {
  const PantallaRifasAdmin({super.key});

  @override
  State<PantallaRifasAdmin> createState() => _PantallaRifasAdminState();
}

class _PantallaRifasAdminState extends State<PantallaRifasAdmin> {
  final _api = RifasAdminApi();

  List<dynamic> _rifas = [];
  bool _cargando = true;
  String? _error;
  String _filtroEstado = 'activa';
  int _paginaActual = 1;

  static const Map<String, String> _etiquetasEstado = {
    'activa': 'Activas',
    'finalizada': 'Finalizadas',
    'cancelada': 'Canceladas',
  };

  @override
  void initState() {
    super.initState();
    _cargarRifas();
  }

  Future<void> _cargarRifas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final response = await _api.listarRifas(
        estado: _filtroEstado,
        pagina: _paginaActual,
      );

      if (!mounted) return;

      setState(() {
        _rifas = response['results'] ?? [];
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar rifas';
        _cargando = false;
      });
    }
  }

  void _cambiarFiltro(String nuevoFiltro) {
    if (nuevoFiltro != _filtroEstado) {
      setState(() {
        _filtroEstado = nuevoFiltro;
        _paginaActual = 1;
      });
      _cargarRifas();
    }
  }

  void _mostrarCrearRifa() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaCrearRifa()),
    );
    if (result == true) await _cargarRifas();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = JPCupertinoColors.background(context);
    final primaryColor = JPCupertinoColors.primary(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Gestión de Rifas'),
        backgroundColor: bgColor,
        scrolledUnderElevation: 0,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: JPCupertinoColors.label(context),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.add_circled_solid,
              color: primaryColor,
              size: 28,
            ),
            onPressed: _mostrarCrearRifa,
          ),
        ],
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Column(
        children: [
          // Segmented Control
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: bgColor,
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<String>(
              groupValue: _filtroEstado,
              children: {
                'activa': Text(_etiquetasEstado['activa']!),
                'finalizada': Text(_etiquetasEstado['finalizada']!),
                'cancelada': Text(_etiquetasEstado['cancelada']!),
              },
              onValueChanged: (val) {
                if (val != null) _cambiarFiltro(val);
              },
              thumbColor: JPCupertinoColors.surface(context),
              backgroundColor: JPCupertinoColors.systemGrey5(context),
            ),
          ),

          Expanded(
            child: _cargando
                ? const Center(child: CupertinoActivityIndicator())
                : _error != null
                ? _buildError(primaryColor)
                : _rifas.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    onRefresh: _cargarRifas,
                    color: primaryColor,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rifas.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildRifaCard(_rifas[index], primaryColor);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRifaCard(Map<String, dynamic> rifa, Color primaryColor) {
    final title = rifa['titulo'] ?? 'Sin Título';
    final participantes = rifa['total_participantes'] ?? 0;
    final imagen = rifa['imagen_url'] ?? rifa['imagen'];
    final cardColor = JPCupertinoColors.surface(context);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaRifaDetalle(rifaId: rifa['id']),
          ),
        );
        if (result == true) await _cargarRifas();
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          // iOS style subtle shadow or border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            if (imagen != null && imagen.toString().isNotEmpty)
              _buildImagenRifa(imagen)
            else
              Container(
                height: 120,
                width: double.infinity,
                color: JPCupertinoColors.systemGrey5(context),
                child: Center(
                  child: Icon(
                    CupertinoIcons.ticket,
                    size: 48,
                    color: JPCupertinoColors.tertiaryLabel(context),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: JPCupertinoColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: JPCupertinoColors.secondaryLabel(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$participantes Participantes',
                        style: TextStyle(
                          color: JPCupertinoColors.secondaryLabel(context),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        CupertinoIcons.chevron_forward,
                        size: 16,
                        color: JPCupertinoColors.secondaryLabel(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagenRifa(dynamic imagen) {
    final url = imagen.toString().startsWith('http')
        ? imagen.toString()
        : '${ApiConfig.baseUrl}$imagen';
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: JPCupertinoColors.systemGrey5(context),
          child: const Center(child: Icon(Icons.image_not_supported)),
        ),
      ),
    );
  }

  Widget _buildError(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: JPColors.error),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Error desconocido',
            style: TextStyle(color: JPCupertinoColors.secondaryLabel(context)),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            onPressed: _cargarRifas,
            child: Text('Reintentar', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.ticket,
            size: 64,
            color: JPCupertinoColors.secondaryLabel(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay rifas ${_filtroEstado}s',
            style: TextStyle(
              fontSize: 16,
              color: JPCupertinoColors.secondaryLabel(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
