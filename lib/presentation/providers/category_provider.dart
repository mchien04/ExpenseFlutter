import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/enums.dart';
import '../../domain/entities/category_entity.dart';
import '../../injection_container.dart';

final categoriesProvider =
    StreamProvider.autoDispose<List<CategoryEntity>>((ref) {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return useCase.watch().map((result) => result.fold(
        (failure) => <CategoryEntity>[],
        (categories) => categories,
      ));
});

final expenseCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryEntity>>((ref) {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return useCase.watchByType(TransactionType.expense).map((result) => result.fold(
        (failure) => <CategoryEntity>[],
        (categories) => categories,
      ));
});

final incomeCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryEntity>>((ref) {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return useCase.watchByType(TransactionType.income).map((result) => result.fold(
        (failure) => <CategoryEntity>[],
        (categories) => categories,
      ));
});

class CategoryNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CategoryNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> createCategory({
    required String name,
    required TransactionType type,
    required int iconCodePoint,
    required String colorHex,
  }) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(createCategoryUseCaseProvider).call(
          name: name,
          type: type,
          iconCodePoint: iconCodePoint,
          colorHex: colorHex,
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

  Future<bool> updateCategory(CategoryEntity category) async {
    state = const AsyncValue.loading();
    final result =
        await _ref.read(updateCategoryUseCaseProvider).call(category);
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

  Future<bool> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(deleteCategoryUseCaseProvider).call(id);
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

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<void>>((ref) {
  return CategoryNotifier(ref);
});
