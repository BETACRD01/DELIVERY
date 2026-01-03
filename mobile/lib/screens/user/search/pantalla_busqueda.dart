// lib/screens/user/busqueda/pantalla_busqueda.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar, NetworkImage;
import 'package:provider/provider.dart';

import '../../../config/routing/rutas.dart';
import '../../../controllers/user/busqueda_controller.dart';
import '../../../models/products/producto_model.dart';
import '../../../providers/cart/proveedor_carrito.dart';
import '../../../services/core/ui/toast_service.dart';
import '../../../theme/primary_colors.dart';
import '../../../theme/secondary_colors.dart';
import '../../../theme/jp_theme.dart';
import '../../../widgets/util/add_to_cart_debounce.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  State<PantallaBusqueda> createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusquedaController(),
      child: Consumer<BusquedaController>(
        builder: (context, controller, _) {
          return CupertinoPageScaffold(
            backgroundColor: JPCupertinoColors.background(context),
            child: CustomScrollView(
              // Cerrar teclado al deslizar
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                // AppBar iOS más compacto
                CupertinoSliverNavigationBar(
                  backgroundColor: JPCupertinoColors.surface(context),
                  largeTitle: Text(
                    'Buscar',
                    style: TextStyle(color: AppColorsSupport.textPrimary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.controladorBusqueda.text.isNotEmpty)
                        _buildFilterButton(context, controller),
                      if (controller.resultados.isNotEmpty)
                        _buildSortButton(context, controller),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: JPCupertinoColors.separator(context),
                      width: 0.5,
                    ),
                  ),
                ),

                // Barra de búsqueda pegajosa
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    child: Container(
                      color: JPCupertinoColors.background(context),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: _buildBarraBusqueda(context, controller),
                    ),
                  ),
                ),

                // Chips de filtros activos
                if (controller.tieneFiltrosActivos)
                  SliverToBoxAdapter(
                    child: _buildChipsFiltros(context, controller),
                  ),

                // Contenido
                _buildContent(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGETS MODULARES
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFilterButton(
    BuildContext context,
    BusquedaController controller,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _mostrarFiltros(context, controller),
      child: Stack(
        children: [
          Icon(
            CupertinoIcons.slider_horizontal_3,
            color: AppColorsSupport.textPrimary,
            size: 22,
          ),
          if (controller.tieneFiltrosActivos)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColorsPrimary.main,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, BusquedaController controller) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _mostrarOrdenamiento(context, controller),
      child: Icon(
        CupertinoIcons.arrow_up_arrow_down,
        color: AppColorsSupport.textPrimary,
        size: 22,
      ),
    );
  }

  Widget _buildBarraBusqueda(
    BuildContext context,
    BusquedaController controller,
  ) {
    return CupertinoTextField(
      controller: controller.controladorBusqueda,
      onChanged: (query) => controller.buscarProductos(query),
      autofocus: true,
      placeholder: 'Buscar productos o tiendas',
      prefix: Padding(
        padding: EdgeInsets.only(left: 10),
        child: Icon(
          CupertinoIcons.search,
          size: 20,
          color: JPCupertinoColors.systemGrey(context),
        ),
      ),
      suffix: controller.controladorBusqueda.text.isNotEmpty
          ? CupertinoButton(
              padding: EdgeInsets.only(right: 8),
              minimumSize: Size.zero,
              onPressed: controller.limpiarBusqueda,
              child: Icon(
                CupertinoIcons.clear_circled_solid,
                size: 20,
                color: JPCupertinoColors.systemGrey(context),
              ),
            )
          : null,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: JPCupertinoColors.systemGrey6(context),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildContent(BusquedaController controller) {
    if (controller.buscando) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CupertinoActivityIndicator(
            radius: 14,
            color: JPCupertinoColors.systemGrey(context),
          ),
        ),
      );
    }

    if (controller.error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEstadoError(controller.error!),
      );
    }

    if (controller.controladorBusqueda.text.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEstadoInicial(controller),
      );
    }

    if (controller.resultados.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildSinResultados(),
      );
    }

    return _buildListaResultados(controller);
  }

  Widget _buildEstadoInicial(BusquedaController controller) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Búsquedas recientes
          if (controller.historialBusqueda.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Búsquedas recientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColorsSupport.textPrimary,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: controller.limpiarHistorial,
                  child: Text(
                    'Limpiar todo',
                    style: TextStyle(
                      color: AppColorsPrimary.main,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...controller.historialBusqueda.take(10).map((query) {
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: JPCupertinoColors.surface(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  onPressed: () => controller.buscarDesdeHistorial(query),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 20,
                        color: JPCupertinoColors.systemGrey(context),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          query,
                          style: TextStyle(
                            color: AppColorsSupport.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () => controller.eliminarDelHistorial(query),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 18,
                          color: JPCupertinoColors.systemGrey(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 24),
          ],

          // Sugerencias
          Center(
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.search,
                  size: 80,
                  color: JPCupertinoColors.systemGrey3(context),
                ),
                SizedBox(height: 16),
                Text(
                  'Busca tus productos favoritos',
                  style: TextStyle(
                    fontSize: 18,
                    color: JPCupertinoColors.secondaryLabel(context),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Escribe en el cuadro de búsqueda',
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildSinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.search_circle,
            size: 80,
            color: JPCupertinoColors.systemGrey3(context),
          ),
          SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              fontSize: 18,
              color: JPCupertinoColors.secondaryLabel(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otros términos',
            style: TextStyle(
              fontSize: 14,
              color: JPCupertinoColors.tertiaryLabel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoError(String mensaje) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.wifi_slash,
              size: 80,
              color: JPCupertinoColors.error(context),
            ),
            SizedBox(height: 16),
            Text(
              'Fallo la conexión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColorsSupport.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: JPCupertinoColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaResultados(BusquedaController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          // Contador de resultados
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: JPCupertinoColors.surface(context),
                borderRadius: BorderRadius.circular(10),
                boxShadow: JPConstants.cardShadow(context),
              ),
              child: Text(
                '${controller.resultados.length} resultado${controller.resultados.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: JPCupertinoColors.secondaryLabel(context),
                ),
              ),
            ),
          );
        }

        final ProductoModel producto = controller.resultados[index - 1];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _ProductoCard(producto: producto),
        );
      }, childCount: controller.resultados.length + 1),
    );
  }

  // Chips de filtros activos
  Widget _buildChipsFiltros(
    BuildContext context,
    BusquedaController controller,
  ) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (controller.categoriaSeleccionada != null)
            _buildFilterChip(
              context,
              'Categoría',
              () => controller.setCategoria(null),
            ),
          if (controller.precioMin > 0 || controller.precioMax < 1000)
            _buildFilterChip(
              context,
              '\$${controller.precioMin.toInt()} - \$${controller.precioMax.toInt()}',
              () => controller.setRangoPrecio(0, 1000),
            ),
          if (controller.ratingMin > 0)
            _buildFilterChip(
              context,
              '${controller.ratingMin}+ ⭐',
              () => controller.setRatingMinimo(0),
            ),
          _buildClearAllChip(context, controller),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    VoidCallback onDelete,
  ) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onDelete,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorsPrimary.main.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColorsPrimary.main.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColorsPrimary.main,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                CupertinoIcons.xmark,
                size: 14,
                color: AppColorsPrimary.main,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearAllChip(
    BuildContext context,
    BusquedaController controller,
  ) {
    return GestureDetector(
      onTap: controller.limpiarFiltros,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: JPCupertinoColors.systemGrey6(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Limpiar filtros',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColorsSupport.textPrimary,
          ),
        ),
      ),
    );
  }

  // Modal de filtros (iOS-style)
  void _mostrarFiltros(BuildContext context, BusquedaController controller) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: JPCupertinoColors.surface(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: JPCupertinoColors.separator(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColorsPrimary.main),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColorsSupport.textPrimary,
                      ),
                    ),
                    Spacer(),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Aplicar',
                        style: TextStyle(
                          color: AppColorsPrimary.main,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: ChangeNotifierProvider.value(
                  value: controller,
                  child: Consumer<BusquedaController>(
                    builder: (context, ctrl, _) {
                      return ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          _buildCategoriesFilter(ctrl),
                          SizedBox(height: 24),
                          _buildPriceRangeFilter(ctrl),
                          SizedBox(height: 24),
                          _buildRatingFilter(ctrl),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesFilter(BusquedaController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColorsSupport.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip(
              'Todas',
              controller.categoriaSeleccionada == null,
              () {
                controller.setCategoria(null);
              },
            ),
            ...controller.categorias.map((cat) {
              return _buildCategoryChip(
                cat.nombre,
                controller.categoriaSeleccionada == cat.id,
                () => controller.setCategoria(cat.id),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColorsPrimary.main
              : JPCupertinoColors.systemGrey6(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected
                ? JPCupertinoColors.white
                : AppColorsSupport.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeFilter(BusquedaController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de precio',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColorsSupport.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mínimo',
                    style: TextStyle(
                      fontSize: 13,
                      color: JPCupertinoColors.secondaryLabel(context),
                    ),
                  ),
                  SizedBox(height: 8),
                  CupertinoSlider(
                    value: controller.precioMin,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    onChanged: (value) {
                      controller.setRangoPrecio(value, controller.precioMax);
                    },
                  ),
                  Text(
                    '\$${controller.precioMin.toInt()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColorsSupport.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Máximo',
                    style: TextStyle(
                      fontSize: 13,
                      color: JPCupertinoColors.secondaryLabel(context),
                    ),
                  ),
                  SizedBox(height: 8),
                  CupertinoSlider(
                    value: controller.precioMax,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    onChanged: (value) {
                      controller.setRangoPrecio(controller.precioMin, value);
                    },
                  ),
                  Text(
                    '\$${controller.precioMax.toInt()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColorsSupport.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter(BusquedaController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calificación mínima',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColorsSupport.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [0.0, 3.0, 4.0, 4.5].map((rating) {
            return _buildCategoryChip(
              rating == 0 ? 'Todas' : '$rating+ ⭐',
              controller.ratingMin == rating,
              () => controller.setRatingMinimo(rating),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Modal de ordenamiento (iOS-style)
  void _mostrarOrdenamiento(
    BuildContext context,
    BusquedaController controller,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Ordenar por', style: TextStyle(fontSize: 13)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              controller.setOrdenamiento('relevancia');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Relevancia'),
                if (controller.ordenamiento == 'relevancia')
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.check_mark,
                      size: 18,
                      color: AppColorsPrimary.main,
                    ),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.setOrdenamiento('precio_asc');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Precio: menor a mayor'),
                if (controller.ordenamiento == 'precio_asc')
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.check_mark,
                      size: 18,
                      color: AppColorsPrimary.main,
                    ),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.setOrdenamiento('precio_desc');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Precio: mayor a menor'),
                if (controller.ordenamiento == 'precio_desc')
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.check_mark,
                      size: 18,
                      color: AppColorsPrimary.main,
                    ),
                  ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.setOrdenamiento('rating');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Mejor calificados'),
                if (controller.ordenamiento == 'rating')
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.check_mark,
                      size: 18,
                      color: AppColorsPrimary.main,
                    ),
                  ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// PERSISTENT HEADER DELEGATE PARA SEARCH BAR
// ══════════════════════════════════════════════════════════════════════════

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchBarDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

// ══════════════════════════════════════════════════════════════════════════
// CARD DE PRODUCTO CON IMAGEN Y ADD TO CART iOS-STYLE
// ══════════════════════════════════════════════════════════════════════════

class _ProductoCard extends StatelessWidget {
  final ProductoModel producto;

  const _ProductoCard({required this.producto});

  @override
  Widget build(BuildContext context) {
    final tieneDescuento =
        producto.precioAnterior != null &&
        producto.precioAnterior! > producto.precio;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: JPCupertinoColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: JPConstants.cardShadow(context),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(14),
        onPressed: () => Rutas.irAProductoDetalle(context, producto),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: producto.imagenUrl!,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 88,
                          height: 88,
                          color: JPCupertinoColors.systemGrey6(context),
                          child: Center(
                            child: CupertinoActivityIndicator(
                              radius: 10,
                              color: JPCupertinoColors.systemGrey(context),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 88,
                          height: 88,
                          color: JPCupertinoColors.systemGrey6(context),
                          child: Icon(
                            CupertinoIcons.cube_box,
                            size: 32,
                            color: JPCupertinoColors.systemGrey3(context),
                          ),
                        ),
                      )
                    : Container(
                        width: 88,
                        height: 88,
                        color: JPCupertinoColors.systemGrey6(context),
                        child: Icon(
                          CupertinoIcons.cube_box,
                          size: 32,
                          color: JPCupertinoColors.systemGrey3(context),
                        ),
                      ),
              ),
              SizedBox(width: 12),

              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.2,
                        color: AppColorsSupport.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    _buildProveedorBadge(context),
                    SizedBox(height: 6),
                    Text(
                      producto.descripcion,
                      style: TextStyle(
                        color: JPCupertinoColors.secondaryLabel(context),
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),

                    // Rating
                    if (producto.rating > 0)
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: JPCupertinoColors.systemYellow(context),
                          ),
                          SizedBox(width: 4),
                          Text(
                            producto.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColorsSupport.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 10),

                    // Precio y botón
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tieneDescuento) ...[
                              Text(
                                producto.precioAnteriorFormateado,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: JPCupertinoColors.secondaryLabel(
                                    context,
                                  ),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(height: 2),
                            ],
                            Text(
                              producto.precioFormateado,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColorsSupport.price,
                              ),
                            ),
                          ],
                        ),

                        // Botón agregar al carrito
                        _AgregarAlCarritoButton(producto: producto),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProveedorBadge(BuildContext context) {
    final tieneLogo =
        producto.proveedorLogoUrl != null &&
        producto.proveedorLogoUrl!.isNotEmpty;
    final tieneNombre = (producto.proveedorNombre ?? '').isNotEmpty;
    if (!tieneLogo && !tieneNombre) return SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: JPCupertinoColors.systemGrey6(context),
          backgroundImage: tieneLogo
              ? NetworkImage(producto.proveedorLogoUrl!)
              : null,
          child: !tieneLogo
              ? Icon(
                  CupertinoIcons.building_2_fill,
                  size: 12,
                  color: JPCupertinoColors.systemGrey(context),
                )
              : null,
        ),
        SizedBox(width: 6),
        if (tieneNombre)
          Flexible(
            child: Text(
              producto.proveedorNombre!,
              style: TextStyle(
                fontSize: 12,
                color: JPCupertinoColors.secondaryLabel(context),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// BOTÓN AGREGAR AL CARRITO CON DEBOUNCE Y TOAST
// ══════════════════════════════════════════════════════════════════════════

class _AgregarAlCarritoButton extends StatefulWidget {
  final ProductoModel producto;

  const _AgregarAlCarritoButton({required this.producto});

  @override
  State<_AgregarAlCarritoButton> createState() =>
      _AgregarAlCarritoButtonState();
}

class _AgregarAlCarritoButtonState extends State<_AgregarAlCarritoButton> {
  bool _loading = false;

  Future<void> _agregarAlCarrito() async {
    if (_loading || !widget.producto.disponible) return;

    // Debounce check
    if (!AddToCartDebounce.canAdd(widget.producto.id.toString())) {
      ToastService().showInfo(context, 'Por favor espera un momento');
      return;
    }

    setState(() => _loading = true);

    final carrito = context.read<ProveedorCarrito>();
    final success = await carrito.agregarProducto(widget.producto);

    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      if (!context.mounted) return;
      ToastService().showSuccess(
        context,
        '${widget.producto.nombre} agregado',
        actionLabel: 'Ver Carrito',
        onActionTap: () => Rutas.irACarrito(context),
      );
    } else {
      if (!context.mounted) return;
      ToastService().showError(
        context,
        carrito.error ?? 'Error al agregar producto',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: widget.producto.disponible
          ? AppColorsPrimary.main
          : JPCupertinoColors.systemGrey4(context),
      borderRadius: BorderRadius.circular(10),
      onPressed: widget.producto.disponible ? _agregarAlCarrito : null,
      child: _loading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CupertinoActivityIndicator(
                radius: 8,
                color: JPCupertinoColors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.cart_badge_plus,
                  size: 18,
                  color: widget.producto.disponible
                      ? JPCupertinoColors.white
                      : JPCupertinoColors.systemGrey(context),
                ),
                SizedBox(width: 6),
                Text(
                  'Agregar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.producto.disponible
                        ? JPCupertinoColors.white
                        : JPCupertinoColors.systemGrey(context),
                  ),
                ),
              ],
            ),
    );
  }
}
