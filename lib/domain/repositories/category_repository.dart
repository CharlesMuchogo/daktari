import 'package:daktari/domain/entities/user.dart';

abstract class CategoryRepository {
  Future<List<Category>> categories();
}
