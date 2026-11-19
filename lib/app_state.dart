import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Estado global do app + persistência local (shared_preferences).
class AppState extends ChangeNotifier {
  static const _kVehicle = 'vehicle';
  static const _kRefuels = 'refuels';

  Vehicle? vehicle;
  List<Refuel> refuels = [];
  bool loading = true;

  List<Refuel> get sortedDesc =>
      [...refuels]..sort((a, b) => b.date.compareTo(a.date));

  List<Indicator> get indicators => computeIndicators(refuels);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kVehicle);
    final r = prefs.getString(_kRefuels);
    if (v != null) vehicle = Vehicle.fromJson(jsonDecode(v));
    if (r != null) {
      refuels = (jsonDecode(r) as List)
          .map((e) => Refuel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (vehicle == null) {
      await prefs.remove(_kVehicle);
    } else {
      await prefs.setString(_kVehicle, jsonEncode(vehicle!.toJson()));
    }
    await prefs.setString(
        _kRefuels, jsonEncode(refuels.map((e) => e.toJson()).toList()));
  }

  Future<void> saveVehicle(Vehicle v) async {
    vehicle = v;
    await _persist();
    notifyListeners();
  }

  /// Exclui o veículo e todos os abastecimentos associados.
  Future<void> deleteVehicle() async {
    vehicle = null;
    refuels = [];
    await _persist();
    notifyListeners();
  }

  Future<void> addRefuel(Refuel r) async {
    refuels = [...refuels, r];
    await _persist();
    notifyListeners();
  }

  Future<void> deleteRefuel(String id) async {
    refuels = refuels.where((e) => e.id != id).toList();
    await _persist();
    notifyListeners();
  }

  /// Garante que a quilometragem seja coerente com a ordem cronológica.
  String? validateKm(double km, DateTime date) {
    final sorted = [...refuels]..sort((a, b) => a.date.compareTo(b.date));
    Refuel? prev;
    Refuel? next;
    for (final r in sorted) {
      if (r.date.isBefore(date)) {
        prev = r;
      } else if (next == null) {
        next = r;
      }
    }
    if (prev != null && km <= prev.km) {
      return 'Deve ser maior que ${prev.km.toStringAsFixed(0)} km (abastecimento anterior)';
    }
    if (next != null && km >= next.km) {
      return 'Deve ser menor que ${next.km.toStringAsFixed(0)} km (próximo abastecimento)';
    }
    return null;
  }
}

final appState = AppState();
