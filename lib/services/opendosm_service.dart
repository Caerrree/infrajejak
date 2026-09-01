import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches district-level population data from OpenDOSM — Malaysia's
/// official statistics open-data platform — via the real, public
/// data.gov.my Open API:
///
///   https://api.data.gov.my/data-catalogue?id=population_district
///
/// Dataset: "Population Table: Administrative Districts" (DOSM), licensed
/// CC BY 4.0. Fields include date, state, district, sex, age, ethnicity,
/// and population. See https://open.dosm.gov.my/data-catalogue/population_district
///
/// This is a genuinely live call to a real Malaysian government dataset —
/// unlike the bundled JKR sample (which is a local static file, see
/// db_helper.dart), this hits the network each time and reflects whatever
/// DOSM currently publishes. Used to give administrators population
/// context for a hazard's district when reviewing/prioritising reports
/// (Section 24 of the brief — a transparent, explainable input, not a
/// black-box risk score).
class OpenDosmService {
  static const _baseUrl = 'https://api.data.gov.my/data-catalogue';

  /// Returns the latest known total population (in thousands, as published
  /// by DOSM) for [district], or null if the lookup fails or the district
  /// name doesn't match DOSM's naming exactly. Never throws — hazard
  /// details should still render fine without this context.
  Future<DistrictPopulation?> getLatestDistrictPopulation(String district) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'id': 'population_district',
        // DOSM breaks totals down by sex/age/ethnicity; 'overall' rows
        // give the combined total for the district.
        'filter': '$district@district,overall@sex,overall@age,overall@ethnicity',
        'limit': '20',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) return null;

      // Rows are per-year; pick the most recent date.
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
      // Network unavailable, district name didn't match, API shape
      // changed, etc. Fail quietly — this is supplementary context only.
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
