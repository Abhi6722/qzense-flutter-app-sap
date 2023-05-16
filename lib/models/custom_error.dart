import 'package:equatable/equatable.dart';

// to be implement on future
class CustomError extends Equatable {
  final String errorMsg;

  CustomError({this.errorMsg = " "});

  @override
  // TODO: implement props
  List<Object?> get props => [errorMsg];

  @override
  bool get stringify => true;
}
