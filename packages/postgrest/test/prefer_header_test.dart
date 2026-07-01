import 'package:postgrest/postgrest.dart';
import 'package:test/test.dart';

import 'custom_http_client.dart';
import 'test_utils.dart';

void main() {
  late CustomHttpClient customHttpClient;
  late PostgrestClient postgrest;

  setUp(() {
    customHttpClient = CustomHttpClient();
    postgrest = PostgrestClient(
      rootUrl,
      headers: apiHeaders,
      httpClient: customHttpClient,
    );
  });

  String? sentPrefer() => customHttpClient.lastRequest!.headers['Prefer'];

  test('insert().select() sends a clean Prefer header', () async {
    try {
      await postgrest.from('users').insert({'username': 'foo'}).select();
    } catch (_) {}

    expect(sentPrefer(), 'return=representation');
  });

  test('update().select() sends a clean Prefer header', () async {
    try {
      await postgrest
          .from('users')
          .update({'status': 'INACTIVE'})
          .eq('id', 1)
          .select();
    } catch (_) {}

    expect(sentPrefer(), 'return=representation');
  });

  test('delete().select() sends a clean Prefer header', () async {
    try {
      await postgrest.from('users').delete().eq('id', 1).select();
    } catch (_) {}

    expect(sentPrefer(), 'return=representation');
  });

  test('upsert().select() keeps its existing Prefer preferences', () async {
    try {
      await postgrest
          .from('users')
          .upsert({'id': 1, 'username': 'foo'}).select();
    } catch (_) {}

    final prefer = sentPrefer()!;
    expect(prefer, isNot(startsWith(',')));
    expect(prefer, contains('resolution=merge-duplicates'));
    expect(prefer, contains('return=representation'));
  });
}
