import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_dashboard/dashboard/domain/domain.dart';

class IsarClienteDatasource implements ClienteDatasource {
  late Future<Isar> _isar;

  IsarClienteDatasource() {
    _isar = _initDB(); // Asigna el resultado de la inicialización
  }

  Future<Isar> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open([ClienteSchema, DeudaSchema, PagoSchema], directory: dir.path);
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
      // Vincula la deuda con el cliente
      deuda.cliente.value = cliente;
      await isar.deudas.put(deuda); // Guarda la deuda en la base de datos
      
      // Agrega la deuda al cliente y guarda el cliente actualizado
      cliente.deudas.add(deuda);
      await isar.clientes.put(cliente); // Guarda el cliente en la base de datos
      
      // Asegura que las relaciones se actualicen en la base de datos
      await cliente.deudas.save();
      await deuda.cliente.save();
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
      await cliente.deudas.load(); // Carga la relación explícitamente
      return cliente.deudas.toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> abonarDeuda(int deudaId, double monto) async {
    final isar = await _isar;
    final deuda = await isar.deudas.get(deudaId);
    if (deuda != null) {
      deuda.totalDeAbono += monto;
      deuda.fechaUltimoAbono = DateTime.now();
      
      await isar.writeTxn(() async {
        await isar.deudas.put(deuda);
        print('Deuda actualizada: ${deuda.totalDeAbono}, Último abono: ${deuda.fechaUltimoAbono}');
      });
      
      // Inserta el abono en pagos
      final pago = Pago(
        montoDeAbono: monto,
        fechaPago: DateTime.now(),
        deuda: deuda,
      );
      await isar.writeTxn(() => isar.pagos.put(pago));
    } else {
      print('Error: Deuda no encontrada');
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

  @override
  Future<List<Deuda>> obtenerDeudasMesesAnteriores(DateTime fechaConsulta) async {
    final isar = await _isar;

    // Calcula la fecha de hace un mes
    final fechaLimite = DateTime(fechaConsulta.year, fechaConsulta.month - 1, fechaConsulta.day);

    return await isar.deudas.filter()
      .fechaUltimoAbonoLessThan(fechaLimite)
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
