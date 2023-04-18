part of 'getemployeelist_cubit.dart';

abstract class PostState {}

class PostLoadingState extends PostState {
  final String loading;

  PostLoadingState(this.loading);
}

class PostinitialState extends PostState {
  final String initial;

  PostinitialState(this.initial);
}

class PostLoadedState extends PostState {
  final List<Employee> allemployeelist;

  PostLoadedState({required this.allemployeelist});
}

class PostErrorState extends PostState {
  final String error;
  PostErrorState(this.error);
}
