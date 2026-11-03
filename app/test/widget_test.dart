import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/app.dart';

void main() {
  testWidgets('App abre exibindo o nome GeraOS', (tester) async {
    await tester.pumpWidget(const GeraOsApp());
    expect(find.textContaining('GeraOS'), findsOneWidget);
  });
}