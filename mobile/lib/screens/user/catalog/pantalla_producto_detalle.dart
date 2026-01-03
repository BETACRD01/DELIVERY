// lib/screens/user/catalogo/pantalla_producto_detalle.dart

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../config/routing/rutas.dart';
import '../../../../../providers/cart/proveedor_carrito.dart';
import '../../../../../theme/primary_colors.dart';
import '../../../../../theme/secondary_colors.dart';
import '../../../../../theme/jp_theme.dart';
import '../../../models/products/producto_model.dart';
import '../../../services/productos/productos_service.dart';
import '../../../services/core/ui/toast_service.dart';
import '../../../widgets/ratings/star_rating_display.dart';
import '../../../widgets/util/add_to_cart_debounce.dart';

/// Pantalla de detalle completo de un producto
class PantallaProductoDetalle extends StatefulWidget {
  const PantallaProductoDetalle({super.key});

  @override
  State<PantallaProductoDetalle> createState() =>
      _PantallaProductoDetalleState();
}

class _PantallaProductoDetalleState extends State<PantallaProductoDetalle> {
  int _cantidad = 1;
  bool _loading = false; // ✅ AGREGADO
  final ProductosService _productosService = ProductosService();
  List<ProductoModel> _sugeridos = [];
  bool _cargandoSugeridos = false;
  bool _sugerenciasCargadas = false;
  String? _ultimoProductoId;

  @override
  Widget build(BuildContext context) {
    final producto = Rutas.obtenerArgumentos<ProductoModel>(context);

    if (producto == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: const Center(child: Text('Producto no encontrado')),
      );
    }

    // Cargar sugerencias al construir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarSugerencias(producto);
    });

    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(
        context,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // AppBar con imagen
              _buildSliverAppBar(producto),

              // Contenido
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(producto),
                    const Divider(height: 32),
                    _buildDescripcion(producto),
                    SizedBox(height: 24),
                    _buildInformacionAdicional(producto),
                    SizedBox(height: 20),
                    _buildSugerencias(),
                    SizedBox(height: 100), // Espacio para el botón flotante
                  ],
                ),
              ),
            ],
          ),
          // FAB del carrito flotante - Versión circular compacta
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(child: _CarritoCircularButton()),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(producto),
    );
  }

  Widget _buildSliverAppBar(ProductoModel producto) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: JPCupertinoColors.surface(context),
      foregroundColor: JPCupertinoColors.label(context),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen del producto
            Container(
              color: JPCupertinoColors.systemGrey6(context),
              child: producto.imagenUrl != null
                  ? Image.network(
                      producto.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),

            // Gradiente para mejorar legibilidad
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      JPCupertinoColors.transparent,
                      JPCupertinoColors.black.withValues(
                        alpha: 0.7,
                      ), // ✅ CORREGIDO
                    ],
                  ),
                ),
              ),
            ),

            // Badge de disponibilidad
            if (!producto.disponible)
              Positioned(
                top: 80,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: JPCupertinoColors.error(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NO DISPONIBLE',
                    style: TextStyle(
                      color: JPCupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: JPCupertinoColors.systemGrey5(context),
      child: Icon(
        Icons.restaurant_menu,
        size: 120,
        color: JPCupertinoColors.systemGrey3(context),
      ),
    );
  }

  Widget _buildHeader(ProductoModel producto) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del producto
          Text(
            producto.nombre,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: JPCupertinoColors.label(context),
            ),
          ),
          SizedBox(height: 8),
          _buildProveedorBadge(producto),
          SizedBox(height: 12),

          // Rating y reseñas
          _buildRatingSummary(producto),
          SizedBox(height: 16),

          // Precio
          Row(
            children: [
              Text(
                producto.precioFormateado,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColorsSupport.price,
                ),
              ),
              Spacer(),
              // Selector de cantidad
              _buildCantidadSelector(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorBadge(ProductoModel producto) {
    final logo = producto.proveedorLogoUrl;
    final nombre = producto.proveedorNombre;
    if ((logo == null || logo.isEmpty) && (nombre == null || nombre.isEmpty)) {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: JPCupertinoColors.systemGrey5(context),
          backgroundImage: (logo != null && logo.isNotEmpty)
              ? NetworkImage(logo)
              : null,
          child: (logo == null || logo.isEmpty)
              ? Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: JPCupertinoColors.systemGrey(context),
                )
              : null,
        ),
        if (nombre != null && nombre.isNotEmpty) ...[
          SizedBox(width: 8),
          Text(
            nombre,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: JPCupertinoColors.label(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingSummary(ProductoModel producto) {
    final rating = producto.rating;
    final totalResenas = producto.totalResenas;
    final hasResenas = totalResenas > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: JPCupertinoColors.background(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: JPCupertinoColors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StarRatingDisplay(
            rating: rating,
            reviewCount: totalResenas,
            size: 18,
            showCount: false,
          ),
          SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: JPCupertinoColors.label(context),
            ),
          ),
          SizedBox(width: 8),
          Text(
            hasResenas ? '$totalResenas resenas' : 'Sin resenas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: JPCupertinoColors.secondaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCantidadSelector() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.all(10),
            onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
            minimumSize: Size(0, 0),
            child: Icon(
              CupertinoIcons.minus,
              size: 18,
              color: _cantidad > 1
                  ? AppColorsPrimary.main
                  : CupertinoColors.systemGrey3,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _cantidad.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColorsSupport.textPrimary,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.all(10),
            onPressed: () => setState(() => _cantidad++),
            minimumSize: Size(0, 0),
            child: Icon(
              CupertinoIcons.plus,
              size: 18,
              color: AppColorsPrimary.main,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescripcion(ProductoModel producto) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            producto.descripcion,
            style: TextStyle(
              fontSize: 15,
              color: JPCupertinoColors.secondaryLabel(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionAdicional(ProductoModel producto) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información adicional',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          if (producto.proveedorNombre != null)
            _InfoItem(
              icono: Icons.store,
              titulo: 'Proveedor',
              valor: producto.proveedorNombre!,
            ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSugerencias() {
    if (_cargandoSugeridos) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'También te puede gustar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: JPCupertinoColors.label(context),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, _) => SizedBox(width: 12),
                itemBuilder: (_, _) => Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: JPCupertinoColors.systemGrey5(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_sugeridos.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'También te puede gustar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: JPCupertinoColors.label(context),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sugeridos.length,
              separatorBuilder: (_, _) => SizedBox(width: 12),
              itemBuilder: (context, index) {
                final prod = _sugeridos[index];
                return Container(
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: CupertinoColors.systemBackground.resolveFrom(
                      context,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: JPCupertinoColors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        Rutas.productoDetalle,
                        arguments: prod,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: SizedBox(
                            height: 86,
                            width: double.infinity,
                            child:
                                prod.imagenUrl != null &&
                                    prod.imagenUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: prod.imagenUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => Container(
                                      color: JPCupertinoColors.systemGrey5(
                                        context,
                                      ),
                                    ),
                                    errorWidget: (_, _, _) => Container(
                                      color: JPCupertinoColors.systemGrey5(
                                        context,
                                      ),
                                      child: Icon(
                                        Icons.fastfood,
                                        color:
                                            JPCupertinoColors.placeholderText(
                                              context,
                                            ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: JPCupertinoColors.systemGrey5(
                                      context,
                                    ),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: JPCupertinoColors.placeholderText(
                                        context,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prod.nombre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: JPCupertinoColors.label(context),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                prod.precioFormateado,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColorsSupport.price,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ProductoModel producto) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: JPCupertinoColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: JPCupertinoColors.black.withValues(
              alpha: 0.08,
            ), // ✅ CORREGIDO
            blurRadius: 8,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: JPCupertinoColors.secondaryLabel(context),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '\$${(producto.precio * _cantidad).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColorsSupport.price,
                    ),
                  ),
                ],
              ),
            ),

            // Botón agregar al carrito
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: producto.disponible && !_loading
                    ? () => _agregarAlCarrito(producto)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JPCupertinoColors.primary(context),
                  foregroundColor: JPCupertinoColors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CupertinoActivityIndicator(radius: 14),
                      )
                    : Icon(Icons.shopping_cart),
                label: Text(
                  _loading ? 'Agregando...' : 'Agregar al carrito',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ CORREGIDO - Método completo con toast iOS
  void _agregarAlCarrito(ProductoModel producto) async {
    if (_loading) return;

    // Debounce check
    if (!AddToCartDebounce.canAdd(producto.id.toString())) {
      ToastService().showInfo(context, 'Por favor espera un momento');
      return;
    }

    setState(() => _loading = true);

    final carrito = context.read<ProveedorCarrito>();

    final success = await carrito.agregarProducto(
      producto,
      cantidad: _cantidad,
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      // Resetear cantidad
      setState(() => _cantidad = 1);

      if (!context.mounted) return;

      // ✅ Capturar navigator ANTES del toast para evitar acceso a context disposed
      final navigator = Navigator.of(context);

      ToastService().showSuccess(
        context,
        '${producto.nombre} agregado',
        actionLabel: 'Ver Carrito',
        onActionTap: () => navigator.pushNamed(Rutas.carrito),
      );
    } else {
      if (!context.mounted) return;
      ToastService().showError(
        context,
        carrito.error ?? 'Error al agregar producto',
      );
    }
  }

  Future<void> _cargarSugerencias(ProductoModel producto) async {
    final mismoProducto = _ultimoProductoId == producto.id;
    if (mismoProducto && _sugerenciasCargadas) return;
    _ultimoProductoId = producto.id;
    _sugerenciasCargadas = true;

    setState(() => _cargandoSugeridos = true);

    try {
      final List<ProductoModel> candidatos = [];

      if (producto.proveedorId != null && producto.proveedorId!.isNotEmpty) {
        final porProveedor = await _productosService.obtenerProductos(
          proveedorId: producto.proveedorId,
        );
        candidatos.addAll(porProveedor);
      }

      if (producto.categoriaId.isNotEmpty) {
        final porCategoria = await _productosService.obtenerProductos(
          categoriaId: producto.categoriaId,
        );
        candidatos.addAll(porCategoria);
      }

      // Complementar con populares/ofertas para cubrir otros proveedores
      final populares = await _productosService.obtenerProductosMasPopulares(
        random: true,
      );
      candidatos.addAll(populares);
      final ofertas = await _productosService.obtenerProductosEnOferta(
        random: true,
      );
      candidatos.addAll(ofertas);

      // Filtrar duplicados y el producto actual
      final seen = <String>{producto.id};
      final dedup = <ProductoModel>[];
      for (final p in candidatos) {
        if (p.id.isEmpty) continue;
        if (seen.contains(p.id)) continue;
        seen.add(p.id);
        dedup.add(p);
      }

      // Dar prioridad a disponibles y mezclar para variar el orden
      dedup.sort((a, b) {
        if (a.disponible == b.disponible) return 0;
        return a.disponible ? -1 : 1;
      });
      dedup.shuffle(Random());

      // Limitar a 8–10 sugerencias
      final lista = dedup.where((p) => p.disponible).take(10).toList();
      if (lista.length < 6) {
        // si faltan, permitir algunos no disponibles solo para completar la grilla
        final restantes = dedup.where((p) => !p.disponible).take(2);
        lista.addAll(restantes);
      }

      if (!mounted) return;
      setState(() {
        _sugeridos = lista;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _sugeridos = []);
    } finally {
      if (mounted) {
        setState(() => _cargandoSugeridos = false);
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ══════════════════════════════════════════════════════════════════════════════

/// Botón circular compacto del carrito para pantallas de detalle
class _CarritoCircularButton extends StatelessWidget {
  const _CarritoCircularButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProveedorCarrito>(
      builder: (context, carrito, _) {
        final cantidad = carrito.cantidadTotal;

        return GestureDetector(
          onTap: () => Rutas.irACarrito(context),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: JPCupertinoColors.surface(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: JPCupertinoColors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_rounded,
                  color: AppColorsPrimary.main,
                  size: 28,
                ),
                if (cantidad > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: JPCupertinoColors.error(context),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        cantidad > 9 ? '9+' : '$cantidad',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: JPCupertinoColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _InfoItem({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icono,
            size: 20,
            color: JPCupertinoColors.secondaryLabel(context),
          ),
          SizedBox(width: 12),
          Text(
            '$titulo:',
            style: TextStyle(
              color: JPCupertinoColors.secondaryLabel(context),
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: JPCupertinoColors.label(context),
            ),
          ),
        ],
      ),
    );
  }
}
