import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/enums.dart';
import '../../domain/entities/recurring_template_entity.dart';
import '../../injection_container.dart';

final recurringTemplatesProvider =
    StreamProvider.autoDispose<List<RecurringTemplateEntity>>((ref) {
  final useCase = ref.watch(getRecurringTemplatesUseCaseProvider);
  return useCase.watch().map((result) => result.fold(
        (failure) => <RecurringTemplateEntity>[],
        (templates) => templates,
      ));
});

final activeRecurringTemplatesProvider =
    StreamProvider.autoDispose<List<RecurringTemplateEntity>>((ref) {
  final useCase = ref.watch(getRecurringTemplatesUseCaseProvider);
  return useCase.watchActive().map((result) => result.fold(
        (failure) => <RecurringTemplateEntity>[],
        (templates) => templates,
      ));
});

final dueRecurringTemplatesProvider =
    FutureProvider.autoDispose<List<RecurringTemplateEntity>>((ref) async {
  final useCase = ref.watch(getRecurringTemplatesUseCaseProvider);
  final result = await useCase.dueForExecution(DateTime.now());
  return result.fold(
    (failure) => <RecurringTemplateEntity>[],
    (templates) => templates,
  );
});

class RecurringNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  RecurringNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> createTemplate({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String walletId,
    required RecurringFrequency frequency,
    required DateTime nextExecutionDate,
    String note = '',
  }) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(createRecurringTemplateUseCaseProvider).call(
          amount: amount,
          type: type,
          categoryId: categoryId,
          walletId: walletId,
          frequency: frequency,
          nextExecutionDate: nextExecutionDate,
          note: note,
        );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> updateTemplate(RecurringTemplateEntity template) async {
    state = const AsyncValue.loading();
    final result =
        await _ref.read(updateRecurringTemplateUseCaseProvider).call(template);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> activateTemplate(String id) async {
    state = const AsyncValue.loading();
    final result =
        await _ref.read(updateRecurringTemplateUseCaseProvider).activate(id);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> deactivateTemplate(String id) async {
    state = const AsyncValue.loading();
    final result =
        await _ref.read(updateRecurringTemplateUseCaseProvider).deactivate(id);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> deleteTemplate(String id) async {
    state = const AsyncValue.loading();
    final result =
        await _ref.read(deleteRecurringTemplateUseCaseProvider).call(id);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

final recurringNotifierProvider =
    StateNotifierProvider<RecurringNotifier, AsyncValue<void>>((ref) {
  return RecurringNotifier(ref);
});
