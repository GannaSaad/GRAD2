import 'package:injectable/injectable.dart';
import '../entities/supplier_entity.dart';
import '../repos/auth_repo.dart';

@injectable
class GetSuppliersByCompanyUseCase {
  final AuthRepo _repository;

  GetSuppliersByCompanyUseCase(this._repository);

  Future<List<SupplierEntity>> call(String companyId) {
    return _repository.getSuppliersByCompany(companyId);
  }
}
