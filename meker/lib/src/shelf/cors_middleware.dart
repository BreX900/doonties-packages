import 'package:shelf/shelf.dart';

class const CorsMiddleware({required final String? origin}) {
  Handler call(Handler handler) {
    return (request) async {
      final requestOrigin = request.headers['origin'];
      if (requestOrigin == null) return handler(request);

      final headers = {
        'Access-Control-Allow-Origin': (origin ?? request.headers['origin'])!,
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Max-Age': '86400',
        'Access-Control-Allow-Credentials': 'true',
      };
      if (request.method == 'OPTIONS') return Response.ok('', headers: headers);

      final response = await handler(request);

      return response.change(headers: {...headers, ...response.headers});
    };
  }
}
