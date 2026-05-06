import 'dart:convert';

import '../../core/common/result.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/address_local_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl extends AddressRepository {
  final AddressLocalDatasourceImpl addressLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  AddressRepositoryImpl({
    required this.addressLocalDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<List<AddressEntity>>> getAllAddress() async {
    try {
      var local = await addressLocalDatasource.getAllAddress();
      if (local.isFailure) return Result.failure(error: local.error!);

      final data = local.data ?? [];

      return Result.success(
        data: data.map((e) => e.toEntity()).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<AddressEntity?>> getAddress(String code) async {
      try {
        var local = await addressLocalDatasource.getAddress(code);
        if (local.isFailure) return Result.failure(error: local.error!);

        return Result.success(data: local.data?.toEntity());
      } catch (e) {
        return Result.failure(error: e);
      }
  }

  @override
  Future<Result<String>> createAddress(AddressEntity address) async {
    try {
      var local = await addressLocalDatasource.createAddress(AddressModel.fromEntity(address));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'UserRepositoryImpl',
          method: 'createUser',
          param: jsonEncode((AddressModel.fromEntity(address)..code = local.data!).toJson()),
          isCritical: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: local.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateAddress(AddressEntity address) async {
    try {
      final local = await addressLocalDatasource.updateAddress(AddressModel.fromEntity(address));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'AddressRepositoryImpl',
          method: 'updateAddress',
          param: jsonEncode(AddressModel.fromEntity(address).toJson()),
          isCritical: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteAddress(String code) async {
    try {
      final local = await addressLocalDatasource.deleteAddress(code);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'AddressRepositoryImpl',
          method: 'deleteAddress',
          param: code,
          isCritical: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
