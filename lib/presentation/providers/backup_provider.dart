import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../data/services/backup_service.dart';
import '../../data/services/recurring_transaction_service.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/usecases/backup/backup_usecases.dart';
import '../../domain/usecases/recurring/process_recurring_usecase.dart';
import '../../injection_container.dart';

// ============================================================================
// BACKUP SERVICES & REPOSITORIES
// ============================================================================

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

final recurringTransactionServiceProvider =
    Provider<RecurringTransactionService>((ref) {
  return RecurringTransactionService(ref.watch(databaseProvider));
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl(ref.watch(backupServiceProvider));
});

// ============================================================================
// BACKUP USECASES
// ============================================================================

final exportDataUseCaseProvider = Provider<ExportDataUseCase>((ref) {
  return ExportDataUseCase(ref.watch(backupRepositoryProvider));
});

final importDataUseCaseProvider = Provider<ImportDataUseCase>((ref) {
  return ImportDataUseCase(ref.watch(backupRepositoryProvider));
});

final processRecurringUseCaseProvider = Provider<ProcessRecurringUseCase>((ref) {
  return ProcessRecurringUseCase(ref.watch(recurringTransactionServiceProvider));
});

// ============================================================================
// BACKUP NOTIFIER
// ============================================================================

class BackupState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const BackupState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  BackupState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class BackupNotifier extends StateNotifier<BackupState> {
  final Ref _ref;

  BackupNotifier(this._ref) : super(const BackupState());

  Future<void> exportToJson() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    final result = await _ref.read(exportDataUseCaseProvider).toJson();

    await result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (jsonData) async {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final fileName = 'expense_backup_$timestamp.json';
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(jsonData);

          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'Expense Tracker Backup',
          );

          state = state.copyWith(
            isLoading: false,
            successMessage: 'Xuất dữ liệu JSON thành công',
          );
        } catch (e) {
          state = state.copyWith(
            isLoading: false,
            error: 'Lỗi lưu file: $e',
          );
        }
      },
    );
  }

  Future<void> exportToCsv() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    final result = await _ref.read(exportDataUseCaseProvider).toCsv();

    await result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (csvData) async {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final fileName = 'expense_transactions_$timestamp.csv';
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(csvData);

          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'Expense Tracker Transactions',
          );

          state = state.copyWith(
            isLoading: false,
            successMessage: 'Xuất dữ liệu CSV thành công',
          );
        } catch (e) {
          state = state.copyWith(
            isLoading: false,
            error: 'Lỗi lưu file: $e',
          );
        }
      },
    );
  }

  Future<void> importFromJson() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final file = File(result.files.single.path!);
      final jsonData = await file.readAsString();

      final importResult =
          await _ref.read(importDataUseCaseProvider).fromJson(jsonData);

      importResult.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message);
        },
        (_) {
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Khôi phục dữ liệu thành công',
          );
          // Invalidate all data providers
          _invalidateAllProviders();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi đọc file: $e',
      );
    }
  }

  Future<void> clearAllData() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    final result = await _ref.read(importDataUseCaseProvider).clearAllData();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Đã xóa toàn bộ dữ liệu',
        );
        _invalidateAllProviders();
      },
    );
  }

  void _invalidateAllProviders() {
    // This will cause all providers to refresh
    _ref.invalidateSelf();
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

final backupNotifierProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier(ref);
});

// ============================================================================
// RECURRING TRANSACTION PROCESSING
// ============================================================================

class RecurringProcessNotifier extends StateNotifier<AsyncValue<int>> {
  final Ref _ref;

  RecurringProcessNotifier(this._ref) : super(const AsyncValue.data(0));

  Future<void> processRecurringTransactions() async {
    state = const AsyncValue.loading();

    final result = await _ref.read(processRecurringUseCaseProvider).call();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (transactions) {
        state = AsyncValue.data(transactions.length);
      },
    );
  }

  Future<void> updatePendingTransactions() async {
    final result =
        await _ref.read(processRecurringUseCaseProvider).updatePendingStatus();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (count) {
        state = AsyncValue.data(count);
      },
    );
  }
}

final recurringProcessNotifierProvider =
    StateNotifierProvider<RecurringProcessNotifier, AsyncValue<int>>((ref) {
  return RecurringProcessNotifier(ref);
});
