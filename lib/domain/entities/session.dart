import 'package:equatable/equatable.dart';

class Session extends Equatable {
  const Session({
    required this.slnet,
    required this.userId,
    this.demo = false,
  });

  final String slnet;
  final String userId;
  final bool demo;

  @override
  List<Object?> get props => [slnet, userId, demo];
}
