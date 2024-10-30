import 'package:sales_dashboard/dashboard/domain/domain.dart';


class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteDatasource _datasource;

  ClienteRepositoryImpl(this._datasource);

  @override
  Future<void> insertarCliente(Cliente cliente) async {
    await _datasource.insertarCliente(cliente);
  }

  @override
  Future<void> insertarDeuda(Deuda deuda, Cliente cliente) async {
    await _datasource.insertarDeuda(deuda, cliente);
  }

  @override
  Future<List<Cliente>> obtenerClientes() async {
    return await _datasource.obtenerClientes();
  }

  @override
  Future<List<Deuda>> obtenerDeudasDeCliente(int clienteId) async {
    return await _datasource.obtenerDeudasDeCliente(clienteId);
  }

  @override
  Future<void> abonarDeuda(int deudaId, double monto) async {
    await _datasource.abonarDeuda(deudaId, monto);
  }

  @override
  Future<List<Deuda>> obtenerDeudasMesDiferente(DateTime fechaConsulta) async {
    return await _datasource.obtenerDeudasMesDiferente(fechaConsulta);
  }
  @override
  Future<List<Deuda>> obtenerDeudasMesesAnteriores(DateTime fechaConsulta) async {
    return await _datasource.obtenerDeudasMesesAnteriores(fechaConsulta);
  }
  @override
  Future<double> obtenerTotalAbonosMes(DateTime fechaConsulta) async {
    return await _datasource.obtenerTotalAbonosMes(fechaConsulta);
  }
}
