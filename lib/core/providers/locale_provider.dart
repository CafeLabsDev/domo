import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// null means "follow the system locale" — same non-persisted, in-memory
/// pattern as themeModeProvider (see theme_provider.dart).
final localeProvider = StateProvider<Locale?>((ref) => null);
