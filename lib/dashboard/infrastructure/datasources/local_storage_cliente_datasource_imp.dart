import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sales_dashboard/dashboard/domain/domain.dart';

class IsarClienteDatasource implements ClienteDatasource {
  late Future<Isar> _isar;

  IsarClienteDatasource() {
    _initDB();
  }

  Future<void> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = Isar.open([ClienteSchema, DeudaSchema], directory: dir.path);
  }

  @override
  Future<void> insertarCliente(Cliente cliente) async {
    final isar = await _isar;
    await isar.writeTxn(() => isar.clientes.put(cliente));
  }

  @override
  Future<void> insertarDeuda(Deuda deuda, Cliente cliente) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      cliente.deudas.add(deuda);
      await isar.clientes.put(cliente);
    });
  }

  @override
  Future<List<Cliente>> obtenerClientes() async {
    final isar = await _isar;
    return await isar.clientes.where().findAll();
  }

  @override
  Future<List<Deuda>> obtenerDeudasDeCliente(int clienteId) async {
    final isar = await _isar;
    final cliente = await isar.clientes.get(clienteId);
    if (cliente != null) {
      return cliente.deudas.toList();
    } else {
      return [];
    }
  }
  ///*********************************************************************************/
    @override
  Future<void> abonarDeuda(int deudaId, double monto) async {
    final isar = await _isar;
    final deuda = await isar.deudas.get(deudaId);
    if (deuda != null) {
      deuda.totalDeAbono += monto;
      deuda.fechaUltimoAbono = DateTime.now(); // Actualiza la fecha de último abono
      await isar.writeTxn(() => isar.deudas.put(deuda));

      // Aquí puedes almacenar el abono en la tabla de pagos
      final pago = Pago(
        montoDeAbono: monto,
        fechaPago: DateTime.now(),
        deuda: deuda,
      );
      await isar.writeTxn(() => isar.pagos.put(pago));
    }
  }

  @override
  Future<List<Deuda>> obtenerDeudasMesDiferente(DateTime fechaConsulta) async {
    final isar = await _isar;
    final mesConsulta = fechaConsulta.month;
    return await isar.deudas.filter()
      .fechaUltimoAbonoBetween(
        DateTime(fechaConsulta.year, mesConsulta, 1),
        DateTime(fechaConsulta.year, mesConsulta + 1, 0),
      )
      .findAll();
  }



  double sumarPagos(List<Pago> pagos) {
    return pagos.fold<double>(0.0, (sum, pago) => sum + (pago.montoDeAbono));
  }

  @override
    Future<double> obtenerTotalAbonosMes(DateTime fechaConsulta) async {
    final isar = await _isar;

    final inicioMes = DateTime(fechaConsulta.year, fechaConsulta.month, 1);
    final finMes = DateTime(
      fechaConsulta.year,
      fechaConsulta.month < 12 ? fechaConsulta.month + 1 : 1,
      1,
    ).subtract(const Duration(days: 1));

    final List<Pago> pagos = await isar.pagos.filter()
      .fechaPagoBetween(inicioMes, finMes)
      .findAll();

    return sumarPagos(pagos);
  }
  
}