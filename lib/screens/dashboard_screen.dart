import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onGoToVehicle;
  const DashboardScreen({super.key, required this.onGoToVehicle});

  @override
  Widget build(BuildContext context) {
    if (appState.vehicle == null) {
      return _msg(Icons.directions_car_outlined,
          'Cadastre um veículo para ver o dashboard.',
          action: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
            onPressed: onGoToVehicle,
            child: const Text('Cadastrar veículo'),
          ));
    }
    final ind = appState.indicators;
    if (ind.isEmpty) {
      return _msg(Icons.insights_outlined,
          'Registre abastecimentos para ver os indicadores.');
    }

    final withData = ind.where((e) => e.kmPerL != null).toList();
    final totalSpent = ind.fold<double>(0, (s, e) => s + e.refuel.total);
    final avgKmL = withData.isEmpty
        ? null
        : withData.map((e) => e.kmPerL!).reduce((a, b) => a + b) /
            withData.length;
    final avgCost = withData.isEmpty
        ? null
        : withData.map((e) => e.costPerKm!).reduce((a, b) => a + b) /
            withData.length;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            _Summary('Total gasto', money(totalSpent), Icons.payments),
            _Summary('Média km/L', avgKmL == null ? '—' : num2(avgKmL),
                Icons.speed),
            _Summary('Média R\$/km', avgCost == null ? '—' : money(avgCost),
                Icons.route),
          ],
        ),
        _ChartCard(
          title: 'Valor de cada abastecimento (R\$)',
          child: _valueChart(ind),
        ),
        _ChartCard(
          title: 'Consumo (km/L)',
          note: withData.length < 2
              ? 'Registre ao menos 2 abastecimentos com km crescente para ver a evolução.'
              : null,
          child: withData.isEmpty
              ? const SizedBox(height: 40)
              : _lineChart(
                  withData,
                  (e) => e.kmPerL!,
                  kGreen,
                  (v) => '${num2(v)} km/L',
                ),
        ),
        _ChartCard(
          title: 'Custo por quilômetro (R\$/km)',
          child: withData.isEmpty
              ? const SizedBox(height: 40)
              : _lineChart(
                  withData,
                  (e) => e.costPerKm!,
                  kTeal,
                  (v) => '${money(v)}/km',
                ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text('Detalhes por abastecimento',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: kGreenDark)),
        ),
        ...ind.reversed.map(_detailTile),
      ],
    );
  }

  Widget _msg(IconData icon, String text, {Widget? action}) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: kGreenLight),
              const SizedBox(height: 12),
              Text(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
              if (action != null) ...[const SizedBox(height: 16), action],
            ],
          ),
        ),
      );

  Widget _detailTile(Indicator e) {
    final isFirst = e.kmPerL == null;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateTimeStr(e.refuel.date),
                    style: const TextStyle(color: Colors.black54)),
                Text(money(e.refuel.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: kGreenDark)),
              ],
            ),
            const SizedBox(height: 6),
            Text(isFirst
                ? 'Abastecimento de referência (sem indicadores)'
                : 'Distância: ${num0(e.distance!)} km  |  '
                    '${num2(e.kmPerL!)} km/L  |  ${money(e.costPerKm!)}/km'),
          ],
        ),
      ),
    );
  }

  // ---------- Gráficos ----------

  static Widget _bottom(List<DateTime> dates, double value, TitleMeta meta) {
    final i = value.toInt();
    if (value != i.toDouble() || i < 0 || i >= dates.length) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(shortDate(dates[i]), style: const TextStyle(fontSize: 10)),
    );
  }

  static double _interval(int n) => max(1, (n / 5).ceil()).toDouble();

  static FlTitlesData _titles(List<DateTime> dates, int decimals) {
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: _interval(dates.length),
          getTitlesWidget: (v, m) => _bottom(dates, v, m),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          getTitlesWidget: (v, m) => Text(
            v.toStringAsFixed(decimals),
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _valueChart(List<Indicator> ind) {
    final dates = ind.map((e) => e.refuel.date).toList();
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: _titles(dates, 0),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                money(rod.toY),
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < ind.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: ind[i].refuel.total,
                  color: kGreen,
                  width: 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _lineChart(
    List<Indicator> data,
    double Function(Indicator) pick,
    Color color,
    String Function(double) tooltip,
  ) {
    final dates = data.map((e) => e.refuel.date).toList();
    final values = data.map(pick).toList();
    final lo = values.reduce(min);
    final hi = values.reduce(max);
    var pad = (hi - lo) * 0.2;
    if (pad == 0) pad = max(hi * 0.1, 0.1);
    final decimals = hi < 10 ? 2 : 1;
    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: max(data.length - 1, 1).toDouble(),
            minY: max(0, lo - pad),
            maxY: hi + pad,
            titlesData: _titles(dates, decimals),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(drawVerticalLine: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          tooltip(s.y),
                          const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ))
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < values.length; i++)
                    FlSpot(i.toDouble(), values[i]),
                ],
                isCurved: true,
                color: color,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData:
                    BarAreaData(show: true, color: color.withOpacity(0.15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Summary(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: kGreen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String? note;
  final Widget child;
  const _ChartCard({required this.title, required this.child, this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kGreenDark)),
            const SizedBox(height: 12),
            child,
            if (note != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(note!,
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
