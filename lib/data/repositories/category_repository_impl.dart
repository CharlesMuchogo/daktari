import 'package:daktari/data/network/api_client.dart';
import 'package:daktari/domain/entities/user.dart';
import 'package:daktari/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ApiClient _api;

  CategoryRepositoryImpl(this._api);

  @override
  Future<List<Category>> categories() async =>
      parseList(await _api.get('/categories'), Category.fromJson);
}
