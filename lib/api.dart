import 'dart:convert';
import 'package:http/http.dart' as http;

class Brand {
  final String name;
  final String code;
  const Brand(this.name, this.code);
}

/// Consulta marcas e modelos na BrasilAPI (tabela FIPE).
class FipeApi {
  static const _base = 'https://brasilapi.com.br/api/fipe';

  static Future<List> _get(String path) async {
    final r = await http
        .get(Uri.parse('$_base/$path'))
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) {
      throw Exception('Erro ${r.statusCode} ao consultar a API');
    }
    return jsonDecode(utf8.decode(r.bodyBytes)) as List;
  }

  static Future<List<Brand>> brands() async {
    final data = await _get('marcas/v1/carros');
    final list = data
        .map((e) => Brand(e['nome'].toString(), e['valor'].toString()))
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// Modelos de uma marca específica.
  static Future<List<String>> models(String brandCode) async {
    final data = await _get('veiculos/v1/carros/$brandCode');
    final set = data.map((e) => e['modelo'].toString()).toSet().toList();
    set.sort();
    return set;
  }
}
