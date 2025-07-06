import 'package:envied/envied.dart';

part 'env.g.dart';

// Allow not to define instance members
// ignore: avoid_classes_with_only_static_members
@Envied(path: 'assets/env/.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_KEY', obfuscate: true)
  static final String apiKey = _Env.apiKey;

  @EnviedField(varName: 'URL', obfuscate: true)
  static String url = _Env.url;
}
