import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/recurring_template_entity.dart';

abstract class RecurringTemplateRepository {
  Future<Either<Failure, List<RecurringTemplateEntity>>> getAllTemplates();
  Future<Either<Failure, List<RecurringTemplateEntity>>> getActiveTemplates();
  Future<Either<Failure, RecurringTemplateEntity?>> getTemplateById(String id);
  Future<Either<Failure, List<RecurringTemplateEntity>>>
      getTemplatesDueForExecution(DateTime date);
  Stream<Either<Failure, List<RecurringTemplateEntity>>> watchAllTemplates();
  Stream<Either<Failure, List<RecurringTemplateEntity>>> watchActiveTemplates();
  Future<Either<Failure, void>> insertTemplate(
      RecurringTemplateEntity template);
  Future<Either<Failure, void>> updateTemplate(
      RecurringTemplateEntity template);
  Future<Either<Failure, void>> updateNextExecutionDate(
      String id, DateTime nextDate);
  Future<Either<Failure, void>> deactivateTemplate(String id);
  Future<Either<Failure, void>> activateTemplate(String id);
  Future<Either<Failure, void>> deleteTemplate(String id);
}
