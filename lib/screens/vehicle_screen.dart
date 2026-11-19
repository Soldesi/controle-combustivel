import 'package:flutter/material.dart';
import '../api.dart';
import '../app_state.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  List<Brand> _brands = [];
  bool _loadingBrands = true;
  String? _brandError;

  Brand? _brand;
  List<String> _models = [];
  bool _loadingModels = false;
  String? _modelError;
  String? _model;
  int? _year;
  final _engine = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _loadingBrands = true;
      _brandError = null;
    });
    try {
      final b = await FipeApi.brands();
      if (!mounted) return;
      setState(() => _brands = b);
    } catch (e) {
      if (!mounted) return;
      setState(() => _brandError = 'Não foi possível carregar as marcas.');
    } finally {
      if (mounted) setState(() => _loadingBrands = false);
    }
  }

  Future<void> _onBrandSelected(Brand? b) async {
    if (b == null) return;
    setState(() {
      _brand = b;
      _model = null;
      _models = [];
      _modelError = null;
      _loadingModels = true;
    });
    try {
      final m = await FipeApi.models(b.code);
      if (!mounted || _brand != b) return;
      setState(() => _models = m);
    } catch (e) {
      if (!mounted) return;
      setState(() => _modelError = 'Não foi possível carregar os modelos.');
    } finally {
      if (mounted) setState(() => _loadingModels = false);
    }
  }

  void _msg(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  Future<void> _save() async {
    final engine = parseNum(_engine.text);
    if (_brand == null) return _msg('Selecione a marca.');
    if (_model == null) return _msg('Selecione o modelo.');
    if (_year == null) return _msg('Selecione o ano.');
    if (engine == null || engine <= 0 || engine > 12) {
      return _msg('Informe a cilindrada em litros (ex.: 1.0).');
    }
    await appState.saveVehicle(Vehicle(
      brand: _brand!.name,
      model: _model!,
      year: _year!,
      engine: engine,
    ));
    _engine.clear();
    setState(() {
      _brand = null;
      _model = null;
      _models = [];
      _year = null;
    });
  }

  Future<void> _confirmDelete() async {
    final n = appState.refuels.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir veículo?'),
        content: Text(n == 0
            ? 'O veículo será removido.'
            : 'O veículo e $n abastecimento(s) associado(s) serão removidos. '
                'Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) await appState.deleteVehicle();
  }

  @override
  Widget build(BuildContext context) {
    final v = appState.vehicle;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [v == null ? _form() : _vehicleCard(v)],
    );
  }

  Widget _vehicleCard(Vehicle v) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: kGreen,
              child: Icon(Icons.directions_car, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 16),
            Text(v.brand,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            Text(v.model,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kGreenDark)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              Chip(label: Text('Ano ${v.year}')),
              Chip(label: Text('${num2(v.engine)} L')),
              Chip(label: Text('${appState.refuels.length} abastecimento(s)')),
            ]),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir veículo'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para cadastrar outro veículo, exclua o atual.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form() {
    final years =
        List.generate(DateTime.now().year + 2 - 1970, (i) => DateTime.now().year + 1 - i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Cadastre seu veículo',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: kGreenDark)),
        const SizedBox(height: 16),
        if (_loadingBrands)
          const Center(child: CircularProgressIndicator())
        else if (_brandError != null)
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.wifi_off),
              title: Text(_brandError!),
              trailing: TextButton(
                  onPressed: _loadBrands, child: const Text('Tentar de novo')),
            ),
          )
        else
          DropdownMenu<Brand>(
            label: const Text('Marca'),
            expandedInsets: EdgeInsets.zero,
            enableFilter: true,
            requestFocusOnTap: true,
            menuHeight: 300,
            dropdownMenuEntries: _brands
                .map((b) => DropdownMenuEntry(value: b, label: b.name))
                .toList(),
            onSelected: _onBrandSelected,
          ),
        const SizedBox(height: 16),
        if (_loadingModels)
          const Center(child: CircularProgressIndicator())
        else if (_modelError != null)
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.wifi_off),
              title: Text(_modelError!),
              trailing: TextButton(
                  onPressed: () => _onBrandSelected(_brand),
                  child: const Text('Tentar de novo')),
            ),
          )
        else
          DropdownMenu<String>(
            key: ValueKey('model-${_brand?.code}'),
            label: const Text('Modelo'),
            enabled: _brand != null,
            expandedInsets: EdgeInsets.zero,
            enableFilter: true,
            requestFocusOnTap: true,
            menuHeight: 300,
            helperText: _brand == null ? 'Selecione a marca primeiro' : null,
            dropdownMenuEntries:
                _models.map((m) => DropdownMenuEntry(value: m, label: m)).toList(),
            onSelected: (m) => _model = m,
          ),
        const SizedBox(height: 16),
        DropdownMenu<int>(
          label: const Text('Ano'),
          expandedInsets: EdgeInsets.zero,
          menuHeight: 300,
          dropdownMenuEntries: years
              .map((y) => DropdownMenuEntry(value: y, label: '$y'))
              .toList(),
          onSelected: (y) => _year = y,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _engine,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Cilindrada do motor (litros)',
            hintText: 'Ex.: 1.0, 1.6, 2.0',
            suffixText: 'L',
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: const Text('Salvar veículo'),
        ),
      ],
    );
  }
}
