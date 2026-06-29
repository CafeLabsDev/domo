// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispensa_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dispensaRepositoryHash() =>
    r'bfc0fb88cea63efc516f8c0bfeffd45b23e05a33';

/// See also [dispensaRepository].
@ProviderFor(dispensaRepository)
final dispensaRepositoryProvider =
    AutoDisposeProvider<DispensaRepository>.internal(
      dispensaRepository,
      name: r'dispensaRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dispensaRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DispensaRepositoryRef = AutoDisposeProviderRef<DispensaRepository>;
String _$itensHash() => r'f3308fa808e78ec7e2643d85f46ffbea5687c633';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [itens].
@ProviderFor(itens)
const itensProvider = ItensFamily();

/// See also [itens].
class ItensFamily extends Family<AsyncValue<List<PantryItem>>> {
  /// See also [itens].
  const ItensFamily();

  /// See also [itens].
  ItensProvider call(String casaId) {
    return ItensProvider(casaId);
  }

  @override
  ItensProvider getProviderOverride(covariant ItensProvider provider) {
    return call(provider.casaId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itensProvider';
}

/// See also [itens].
class ItensProvider extends AutoDisposeStreamProvider<List<PantryItem>> {
  /// See also [itens].
  ItensProvider(String casaId)
    : this._internal(
        (ref) => itens(ref as ItensRef, casaId),
        from: itensProvider,
        name: r'itensProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itensHash,
        dependencies: ItensFamily._dependencies,
        allTransitiveDependencies: ItensFamily._allTransitiveDependencies,
        casaId: casaId,
      );

  ItensProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.casaId,
  }) : super.internal();

  final String casaId;

  @override
  Override overrideWith(
    Stream<List<PantryItem>> Function(ItensRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItensProvider._internal(
        (ref) => create(ref as ItensRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        casaId: casaId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PantryItem>> createElement() {
    return _ItensProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItensProvider && other.casaId == casaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, casaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItensRef on AutoDisposeStreamProviderRef<List<PantryItem>> {
  /// The parameter `casaId` of this provider.
  String get casaId;
}

class _ItensProviderElement
    extends AutoDisposeStreamProviderElement<List<PantryItem>>
    with ItensRef {
  _ItensProviderElement(super.provider);

  @override
  String get casaId => (origin as ItensProvider).casaId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
