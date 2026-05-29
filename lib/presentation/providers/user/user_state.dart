import '../../../domain/entities/user_entity.dart';

class UserState {
  final List<UserEntity>? allUser;
  final bool isLoadingMore;
  final String? error;

  const UserState({
    this.allUser,
    this.isLoadingMore = false,
    this.error
  });

  UserState copyWith({
    List<UserEntity>? allUser,
    bool? isLoadingMore,
    String? error
  }) {
    return UserState(
      allUser: allUser ?? this.allUser,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
