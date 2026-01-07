import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../repositories/recurring_template_repository.dart';

class DeleteRecurringTemplateUseCase {
  final RecurringTemplateRepository repository;

  DeleteRecurringTemplateUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTemplate(id);
  }
}
