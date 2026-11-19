enum Fuel {
  etanol('Etanol'),
  gasolina('Gasolina'),
  diesel('Diesel');

  final String label;
  const Fuel(this.label);
}

class Vehicle {
  final String brand;
  final String model;
  final int year;
  final double engine; // cilindrada em litros (ex.: 1.0)

  const Vehicle({
    required this.brand,
    required this.model,
    required this.year,
    required this.engine,
  });

  Map<String, dynamic> toJson() =>
      {'brand': brand, 'model': model, 'year': year, 'engine': engine};

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
        brand: j['brand'],
        model: j['model'],
        year: j['year'],
        engine: (j['engine'] as num).toDouble(),
      );
}

class Refuel {
  final String id;
  final Fuel fuel;
  final double pricePerLiter;
  final double km;
  final double liters;
  final DateTime date;

  const Refuel({
    required this.id,
    required this.fuel,
    required this.pricePerLiter,
    required this.km,
    required this.liters,
    required this.date,
  });

  double get total => pricePerLiter * liters;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fuel': fuel.name,
        'pricePerLiter': pricePerLiter,
        'km': km,
        'liters': liters,
        'date': date.toIso8601String(),
      };

  factory Refuel.fromJson(Map<String, dynamic> j) => Refuel(
        id: j['id'],
        fuel: Fuel.values.firstWhere((f) => f.name == j['fuel']),
        pricePerLiter: (j['pricePerLiter'] as num).toDouble(),
        km: (j['km'] as num).toDouble(),
        liters: (j['liters'] as num).toDouble(),
        date: DateTime.parse(j['date']),
      );
}

/// Indicadores de um abastecimento (nulos no primeiro registro).
class Indicator {
  final Refuel refuel;
  final double? distance;
  final double? kmPerL;
  final double? costPerKm;

  const Indicator(this.refuel, {this.distance, this.kmPerL, this.costPerKm});
}

/// Calcula os indicadores conforme a atividade:
/// distância = km atual - km anterior
/// km/L = distância / litros atuais
/// R$/km = total atual / distância
List<Indicator> computeIndicators(List<Refuel> refuels) {
  final sorted = [...refuels]..sort((a, b) => a.date.compareTo(b.date));
  final result = <Indicator>[];
  for (var i = 0; i < sorted.length; i++) {
    final cur = sorted[i];
    if (i == 0) {
      result.add(Indicator(cur));
      continue;
    }
    final dist = cur.km - sorted[i - 1].km;
    if (dist > 0 && cur.liters > 0) {
      result.add(Indicator(
        cur,
        distance: dist,
        kmPerL: dist / cur.liters,
        costPerKm: cur.total / dist,
      ));
    } else {
      result.add(Indicator(cur));
    }
  }
  return result;
}
