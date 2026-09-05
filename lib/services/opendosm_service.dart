import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenDosmService {
  static const _baseUrl = 'https://api.data.gov.my/data-catalogue';

  Future<DistrictPopulation?> getLatestDistrictPopulation(String district) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'id': 'population_district',
        'filter': '$district@district,overall@sex,overall@age,overall@ethnicity',
        'limit': '20',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) return null;

      final rows = decoded.cast<Map<String, dynamic>>();
      rows.sort((a, b) => (b['date'] ?? '').toString().compareTo((a['date'] ?? '').toString()));
      final latest = rows.first;

      final population = latest['population'];
      if (population == null) return null;

      return DistrictPopulation(
        district: (latest['district'] ?? district).toString(),
        state: latest['state']?.toString(),
        populationThousands: (population as num).toDouble(),
        asOfDate: latest['date']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }
}

class DistrictPopulation {
  final String district;
  final String? state;
  final double populationThousands;
  final String? asOfDate;

  const DistrictPopulation({
    required this.district,
    required this.populationThousands,
    this.state,
    this.asOfDate,
  });
}
