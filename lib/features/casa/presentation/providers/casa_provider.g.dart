// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'casa_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$casaRepositoryHash() => r'65b7f6529f9f81af4c3666ba57f425a3008cae25';

/// See also [casaRepository].
@ProviderFor(casaRepository)
final casaRepositoryProvider = AutoDisposeProvider<CasaRepository>.internal(
  casaRepository,
  name: r'casaRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$casaRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CasaRepositoryRef = AutoDisposeProviderRef<CasaRepository>;
String _$casaDoUsuarioHash() => r'fcb0be83895465d7b193e2a0b48dc2b3ae8dfe5b';

/// See also [casaDoUsuario].
@ProviderFor(casaDoUsuario)
final casaDoUsuarioProvider = AutoDisposeStreamProvider<CasaModel?>.internal(
  casaDoUsuario,
  name: r'casaDoUsuarioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$casaDoUsuarioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CasaDoUsuarioRef = AutoDisposeStreamProviderRef<CasaModel?>;
String _$membrosHash() => r'879d65b4722785886d56df81cfa9868183affb26';

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

/// See also [membros].
@ProviderFor(membros)
const membrosProvider = MembrosFamily();

/// See also [membros].
class MembrosFamily extends Family<AsyncValue<List<MembroModel>>> {
  /// See also [membros].
  const MembrosFamily();

  /// See also [membros].
  MembrosProvider call(String casaId) {
    return MembrosProvider(casaId);
  }

  @override
  MembrosProvider getProviderOverride(covariant MembrosProvider provider) {
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
  String? get name => r'membrosProvider';
}

/// See also [membros].
class MembrosProvider extends AutoDisposeStreamProvider<List<MembroModel>> {
  /// See also [membros].
  MembrosProvider(String casaId)
    : this._internal(
        (ref) => membros(ref as MembrosRef, casaId),
        from: membrosProvider,
        name: r'membrosProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$membrosHash,
        dependencies: MembrosFamily._dependencies,
        allTransitiveDependencies: MembrosFamily._allTransitiveDependencies,
        casaId: casaId,
      );

  MembrosProvider._internal(
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
    Stream<List<MembroModel>> Function(MembrosRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MembrosProvider._internal(
        (ref) => create(ref as MembrosRef),
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
  AutoDisposeStreamProviderElement<List<MembroModel>> createElement() {
    return _MembrosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MembrosProvider && other.casaId == casaId;
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
mixin MembrosRef on AutoDisposeStreamProviderRef<List<MembroModel>> {
  /// The parameter `casaId` of this provider.
  String get casaId;
}

class _MembrosProviderElement
    extends AutoDisposeStreamProviderElement<List<MembroModel>>
    with MembrosRef {
  _MembrosProviderElement(super.provider);

  @override
  String get casaId => (origin as MembrosProvider).casaId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
