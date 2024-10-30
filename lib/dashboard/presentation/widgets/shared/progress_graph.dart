import 'package:flutter/material.dart';
//import 'package:isar/isar.dart';
import 'package:sales_dashboard/dashboard/domain/domain.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class DeudaProgressBar extends StatefulWidget {
  final ClienteRepository clienteRepository; // Repositorio para obtener datos

  const DeudaProgressBar({super.key, required this.clienteRepository});

  @override
  DeudaProgressBarState createState() => DeudaProgressBarState();
}

class DeudaProgressBarState extends State<DeudaProgressBar> {
  late Future<List<Deuda>> _deudasPasadasFuture;
  late Future<List<Deuda>> _deudasActualesFuture;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _deudasPasadasFuture = widget.clienteRepository.obtenerDeudasMesesAnteriores(now);
    _deudasActualesFuture = widget.clienteRepository.obtenerDeudasMesDiferente(now);
  }

  Future<double> _calculateTotalDeudas(List<Deuda> deudas) async {
    // Suma total de las deudas
    double total = 0;
    for (var deuda in deudas) {
      total += deuda.monto; // Asumiendo que `deuda.monto` es un Future<double>
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Deuda>>>(
      future: Future.wait<List<Deuda>>([_deudasPasadasFuture, _deudasActualesFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar deudas'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay deudas disponibles'));
        }

        // Desempaqueta las listas de deudas
        final deudasPasadas = snapshot.data![0];
        final deudasActuales = snapshot.data![1];

        return FutureBuilder<List<double>>(
          future: Future.wait([_calculateTotalDeudas(deudasPasadas), _calculateTotalDeudas(deudasActuales)]),
          builder: (context, totalsSnapshot) {
            if (totalsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (totalsSnapshot.hasError) {
              return const Center(child: Text('Error al calcular totales'));
            } else if (!totalsSnapshot.hasData || totalsSnapshot.data!.isEmpty) {
              return const Center(child: Text('No se pudieron calcular los totales'));
            }

            final totalDeudasPasadas = totalsSnapshot.data![0];
            final totalDeudasActuales = totalsSnapshot.data![1];

            // Valor de la barra de progreso como un porcentaje
            final valorPorcentaje = totalDeudasActuales / (totalDeudasActuales + totalDeudasPasadas) * 100;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SimpleCircularProgressBar(
                  valueNotifier: ValueNotifier(valorPorcentaje),
                  mergeMode: true,
                  animationDuration:2,
                  onGetText: (double value) {
                    return Text(
                      '${value.toInt()}%',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}
