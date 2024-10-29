import 'package:sales_dashboard/dashboard/domain/domain.dart';//importar modelo

abstract class ClienteRepository {
  Future<void> insertarCliente(Cliente cliente);
  Future<void> insertarDeuda(Deuda deuda, Cliente cliente);
  Future<List<Cliente>> obtenerClientes();
  Future<List<Deuda>> obtenerDeudasDeCliente(int clienteId);

  Future<void> abonarDeuda(int deudaId, double monto);
  Future<List<Deuda>> obtenerDeudasMesDiferente(DateTime fechaConsulta);
  Future<double> obtenerTotalAbonosMes(DateTime fechaConsulta);
}
