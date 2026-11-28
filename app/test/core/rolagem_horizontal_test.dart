import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geraos/core/widgets/rolagem_horizontal.dart';

void main() {
  testWidgets('A roda do mouse move a lista para o lado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 48,
              child: RolagemHorizontal(
                children: [
                  for (var i = 0; i < 10; i++)
                    SizedBox(width: 100, child: Text('Item $i')),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final rolagem = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(rolagem.position.pixels, 0);

    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(
      mouse.hover(tester.getCenter(find.byType(RolagemHorizontal))),
    );
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, 120)));
    await tester.pump();

    expect(rolagem.position.pixels, 120);
  });
}
