import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/recurring_template_entity.dart';
import '../../repositories/recurring_template_repository.dart';
import '../../validators/recurring_template_validator.dart';

class UpdateRecurringTemplateUseCase {
  final RecurringTemplateRepository repository;

  UpdateRecurringTemplateUseCase(this.repository);

  Future<Either<Failure, void>> call(RecurringTemplateEntity template) async {
    final updatedTemplate = template.copyWith(updatedAt: DateTime.now());

    final validationResult =
        RecurringTemplateValidator.validate(updatedTemplate);
    return validationResult.fold(
      (failure) => Left(failure),
      (validTemplate) => repository.updateTemplate(validTemplate),
    );
  }

  Future<Either<Failure, void>> activate(String id) {
    return repository.activateTemplate(id);
  }

  Future<Either<Failure, void>> deactivate(String id) {
    return repository.deactivateTemplate(id);
  }
}
