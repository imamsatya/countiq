import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_database.dart';

final localeProvider = StateProvider<String>((ref) {
  return LocalDatabase.instance.getLocale();
});
