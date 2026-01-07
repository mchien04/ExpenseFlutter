import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/category_entity.dart';

class CategoryValidator {
  static Either<ValidationFailure, CategoryEntity> validate(
    CategoryEntity category,
  ) {
    if (category.name.trim().isEmpty) {
      return const Left(
        ValidationFailure('Tên danh mục không được để trống'),
      );
    }

    if (category.name.length > 100) {
      return const Left(
        ValidationFailure('Tên danh mục không được quá 100 ký tự'),
      );
    }

    if (category.colorHex.length < 6 || category.colorHex.length > 8) {
      return const Left(
        ValidationFailure('Mã màu không hợp lệ'),
      );
    }

    return Right(category);
  }

  static Either<ValidationFailure, String> validateName(String name) {
    if (name.trim().isEmpty) {
      return const Left(
        ValidationFailure('Tên danh mục không được để trống'),
      );
    }

    if (name.length > 100) {
      return const Left(
        ValidationFailure('Tên danh mục không được quá 100 ký tự'),
      );
    }

    return Right(name);
  }
}
