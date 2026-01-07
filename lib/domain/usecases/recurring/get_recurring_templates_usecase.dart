import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/recurring_template_entity.dart';
import '../../repositories/recurring_template_repository.dart';

class GetRecurringTemplatesUseCase {
  final RecurringTemplateRepository repository;

  GetRecurringTemplatesUseCase(this.repository);

  Future<Either<Failure, List<RecurringTemplateEntity>>> call() {
    return repository.getAllTemplates();
  }

  Future<Either<Failure, List<RecurringTemplateEntity>>> active() {
    return repository.getActiveTemplates();
  }

  Future<Either<Failure, RecurringTemplateEntity?>> byId(String id) {
    return repository.getTemplateById(id);
  }

  Future<Either<Failure, List<RecurringTemplateEntity>>> dueForExecution(
      DateTime date) {
    return repository.getTemplatesDueForExecution(date);
  }

  Stream<Either<Failure, List<RecurringTemplateEntity>>> watch() {
    return repository.watchAllTemplates();
  }

  Stream<Either<Failure, List<RecurringTemplateEntity>>> watchActive() {
    return repository.watchActiveTemplates();
  }
}
