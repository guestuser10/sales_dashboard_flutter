import 'package:flutter/material.dart';
import '../widgets/time/ventas_por_tiempo.dart'; // Asegúrate de importar el widget VentasPorTiempoWidget

class DashboardScreen extends StatelessWidget {
  static const String name = 'dashboard';

  const DashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Gráficas de Venta'),
      ),
      body: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(5.0),
      child: VentasPorTiempoWidget(),
    );
  }
}
