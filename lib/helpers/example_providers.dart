import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ejemplo de provider simple para mostrar el uso de Riverpod.
final counterProvider = StateProvider<int>((ref) => 0);
