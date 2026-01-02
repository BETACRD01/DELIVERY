import '../../apis/notificaciones/notificaciones_api.dart';
import '../../models/core/notificacion_model.dart';
import '../../models/core/paginated_response.dart';

/// Servicio unificado de notificaciones (reemplaza domain/infrastructure)
class NotificacionesService {
  final NotificacionesApi _api;

  NotificacionesService({NotificacionesApi? api})
    : _api = api ?? NotificacionesApi();

  Future<PaginatedResponse<NotificacionModel>> getNotificaciones({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getNotificaciones(page: page, limit: limit);

    // Standard DRF pagination parsing
    if (response is Map && response.containsKey('results')) {
      final List<dynamic> results = response['results'];
      final items = results.map((e) => NotificacionModel.fromJson(e)).toList();

      return PaginatedResponse(
        data: items,
        total: response['count'] ?? 0,
        next: response['next'],
        previous: response['previous'],
      );
    }

    // Fallback for list
    if (response is List) {
      final items = response.map((e) => NotificacionModel.fromJson(e)).toList();
      return PaginatedResponse(data: items, total: items.length);
    }

    return PaginatedResponse(data: [], total: 0);
  }

  Future<void> marcarLeida(String id) async {
    await _api.marcarLeida(id);
  }

  Future<void> marcarTodasLeidas() async {
    await _api.marcarTodasLeidas();
  }
}
