import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ApiService {
  static const String baseUrl = 'https://robbianco.it/be';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Header di sicurezza richiesti da nginx
  static const Map<String, String> _securityHeaders = {
    'X-Frontend-Request': 'robbianco-flutter-app',
    'X-Requested-With': 'XMLHttpRequest',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET request con timeout
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      return await http
          .get(url, headers: _securityHeaders)
          .timeout(timeoutDuration);
    } on TimeoutException {
      throw ApiException('Request timeout', 408);
    } catch (e) {
      throw ApiException('Network error: $e', 500);
    }
  }

  // POST request con retry logic
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    int retries = 1,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        return await http
            .post(url, headers: _securityHeaders, body: json.encode(data))
            .timeout(timeoutDuration);
      } on TimeoutException {
        if (attempt == retries) {
          throw ApiException('Request timeout after $retries retries', 408);
        }
      } catch (e) {
        if (attempt == retries) throw ApiException('Network error: $e', 500);
      }

      // Wait before retry
      if (attempt < retries) {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }

    throw ApiException('Unexpected error', 500);
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      return await http
          .put(url, headers: _securityHeaders, body: json.encode(data))
          .timeout(timeoutDuration);
    } on TimeoutException {
      throw ApiException('Request timeout', 408);
    } catch (e) {
      throw ApiException('Network error: $e', 500);
    }
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      return await http
          .delete(url, headers: _securityHeaders)
          .timeout(timeoutDuration);
    } on TimeoutException {
      throw ApiException('Request timeout', 408);
    } catch (e) {
      throw ApiException('Network error: $e', 500);
    }
  }

  // Metodo helper per gestire le risposte con error handling migliorato
  static List<dynamic> handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        try {
          // response.body è una stringa JSON valida
          // response.body è Lis<dynamic> con i dati dei sensori
          //[{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core #1","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core #2","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core #3","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core #4","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core #5","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core #6","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core #7","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core #8","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Total","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"CPU Core Max","sensorType":"Load","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Package","sensorType":"Power","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #1","sensorType":"Clock","value":"NaN"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #1","sensorType":"Factor","value":"NaN"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #1 (SMU)","sensorType":"Power","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #1 VID","sensorType":"Voltage","value":"1.55"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #2","sensorType":"Clock","value":"NaN"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #2","sensorType":"Factor","value":"NaN"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #2 (SMU)","sensorType":"Power","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #2 VID","sensorType":"Voltage","value":"1.55"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #3","sensorType":"Clock","value":"NaN"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #3","sensorType":"Factor","value":"NaN"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #3 (SMU)","sensorType":"Power","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #3 VID","sensorType":"Voltage","value":"1.55"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #4","sensorType":"Clock","value":"NaN"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #4","sensorType":"Factor","value":"NaN"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #4 (SMU)","sensorType":"Power","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core #4 VID","sensorType":"Voltage","value":"1.55"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core (Tctl/Tdie)","sensorType":"Temperature","value":"0.00"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"Core (SVI2 TFN)","sensorType":"Voltage","value":"1.55"},{"hardware":"AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx","sensorName":"SoC (SVI2 TFN)","sensorType":"Voltage","value":"1.55"},{"hardware":"Generic Memory","sensorName":"Memory Used","sensorType":"Data","value":"0.65"},{"hardware":"Generic Memory","sensorName":"Memory Available","sensorType":"Data","value":"7.48"},{"hardware":"Generic Memory","sensorName":"Memory","sensorType":"Load","value":"8.62"},{"hardware":"Generic Memory","sensorName":"Virtual Memory Used","sensorType":"Data","value":"0.00"},{"hardware":"Generic Memory","sensorName":"Virtual Memory Available","sensorType":"Data","value":"2.00"},{"hardware":"Generic Memory","sensorName":"Virtual Memory","sensorType":"Load","value":"0.00"},{"hardware":"eth0","sensorName":"Data Uploaded","sensorType":"Data","value":"0.00"},{"hardware":"eth0","sensorName":"Data Downloaded","sensorType":"Data","value":"0.00"},{"hardware":"eth0","sensorName":"Upload Speed","sensorType":"Throughput","value":"0.00"},{"hardware":"eth0","sensorName":"Download Speed","sensorType":"Throughput","value":"0.00"},{"hardware":"eth0","sensorName":"Network Utilization","sensorType":"Load","value":"0.00"}]
          return json.decode(response.body);
        } catch (e) {
          throw ApiException('Invalid JSON response', response.statusCode);
        }
      case 400:
        throw ApiException('Bad request', 400);
      case 401:
        throw ApiException('Unauthorized', 401);
      case 403:
        throw ApiException('Forbidden - Check security headers', 403);
      case 404:
        throw ApiException('Not found', 404);
      case 429:
        throw ApiException('Too many requests - Please wait', 429);
      case 500:
        throw ApiException('Server error', 500);
      default:
        throw ApiException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          response.statusCode,
        );
    }
  }
}

// Custom exception per gestire meglio gli errori API
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
