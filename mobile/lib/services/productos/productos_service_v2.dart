import 'dart:convert';
import '../../apis/productos/productos_api.dart';
import '../../models/core/paginated_response.dart';
import '../../models/products/producto_model.dart';

/// Servicio unificado de productos (reemplaza domain/infrastructure)
class ProductosServiceV2 {
  final ProductosApi _api;

  ProductosServiceV2({ProductosApi? api}) : _api = api ?? ProductosApi();

  Future<PaginatedResponse<ProductoModel>> getProductos({
    int page = 1,
    int limit = 20,
    String? busqueda,
    String? categoriaId,
  }) async {
    final response = await _api.getProductos(
      busqueda: busqueda,
      categoriaId: categoriaId,
      page: page,
      pageSize: limit,
    );

    // Parse DRF pagination format
    if (response is Map) {
      dynamic paginatedData = response;
      if (response.containsKey('raw_data')) {
        final raw = response['raw_data'];
        if (raw is String) {
          paginatedData = jsonDecode(raw);
        } else {
          paginatedData = raw;
        }
      }

      if (paginatedData is Map && paginatedData.containsKey('results')) {
        final List<dynamic> results = paginatedData['results'];
        final List<ProductoModel> productos = results
            .map((e) => ProductoModel.fromJson(e))
            .toList();

        return PaginatedResponse(
          data: productos,
          total: paginatedData['count'] ?? 0,
          next: paginatedData['next'],
          previous: paginatedData['previous'],
        );
      }
    }

    if (response is List) {
      final List<ProductoModel> productos = response
          .map((e) => ProductoModel.fromJson(e))
          .toList();
      return PaginatedResponse(data: productos, total: productos.length);
    }

    if (response is Map &&
        response.containsKey('data') &&
        response['data'] is List) {
      final List<dynamic> list = response['data'];
      final List<ProductoModel> productos = list
          .map((e) => ProductoModel.fromJson(e))
          .toList();
      return PaginatedResponse(data: productos, total: productos.length);
    }

    return PaginatedResponse(data: [], total: 0);
  }
}
