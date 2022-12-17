import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


import 'package:equipo64_mobile/main.dart' as app;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    
    testWidgets('Not searching anything', (WidgetTester tester) async {

      app.main();
      await tester.pumpAndSettle(const Duration( seconds: 5 ));

      //button for searching
      final Finder button = find.text('Search');
      //emulate to tap the button "Search"
      await tester.tap(button);

      await tester.pumpAndSettle();
      //we expect to find a warning because we did not introduce a
      //food
      expect(find.text('Please introduce food'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Searching not-existent food', (WidgetTester tester) async {

      app.main();
      await tester.pumpAndSettle(const Duration( seconds: 5 ));

      //emulate introducing non-existent food
      await tester.enterText(find.byType(TextFormField), 'palomitas');

      final Finder button = find.text('Search');

      await tester.tap(button);

      await tester.pumpAndSettle(const Duration( seconds: 3 ));

      //we assure that there are no recipes
      expect(find.text("No recipes found!"), findsOneWidget);

      await tester.pumpAndSettle(const Duration( seconds: 3 ));

      await tester.pumpAndSettle();
    });
    
    //Test for testing everything at the same time
        testWidgets('Searching existent food',
                (WidgetTester tester) async {

                  app.main();
                  await tester.pumpAndSettle(const Duration( seconds: 5 ));

                  //button for searching
                  final Finder button = find.text('Search');

                  //Emulate to introduce the food "Carrot"
                  await tester.enterText(find.byType(TextFormField), 'Carrot');
                  //Emulate to find the "dropdown" of the selector of the "Cuisine type"
                  final Finder dropdown = find.byKey(const ValueKey('dropdown'));
                  //Emulate to tap the "dropdown" for seeing all the possible options
                  await tester.tap(dropdown);
                  //Emulate to find the warning shown when loading a new block of recipes
                  final dropdownItemFinder = find.text("Loading more recipes...");
                  //Emulate to find the name of the recipe we are searching
                  final dropdownRecipeFinder = find.text("Minted Coleslaw");

                  await tester.pumpAndSettle(const Duration( seconds: 3 ));

                  //Emulate to find the "Cuisine type" with name "Central Europe"
                  final Finder dropdownItem = find.text("Central Europe").last;
                  //Emulate to tap the "Cuisine type" with name "Central Europe"
                  await tester.tap(dropdownItem);

                  await tester.pumpAndSettle(const Duration( seconds: 3 ));

                  //Emulate to tap the button "Search".
                  await tester.tap(button);

                  await tester.pumpAndSettle(const Duration( seconds: 3 ));

                  //Emulate to find the scroll of the list of recipes
                  final dropdownListFinder = find.byType(Scrollable).last;
                  //Emulate to scroll the list of recipes until we find the warning
                  //shown when loading a new block of recipes
                  await tester.scrollUntilVisible(dropdownItemFinder, 500.0, scrollable: dropdownListFinder);

                  await tester.pumpAndSettle(const Duration( seconds: 3 ));

                  //Emulate to scroll the list of recipes until we find the recipe
                  //we are searching for
                  await tester.scrollUntilVisible(dropdownRecipeFinder, 500.0, scrollable: dropdownListFinder);

                  await tester.pumpAndSettle(const Duration( seconds: 3 ));

                  //Emulate to tap over the Recipe, for viewing an small description
                  await tester.tap(dropdownRecipeFinder);

                  await tester.pumpAndSettle(const Duration( seconds: 3 ));

                  //Emulate to find "View Details" button
                  final Finder viewDetails = find.text('View Details');
                  //Emulate to tap "View Details" button
                  await tester.tap(viewDetails);

                  await tester.pumpAndSettle(const Duration( seconds: 3 ));

                  expect(find.text('Servings:'), findsOneWidget);

                  await tester.pumpAndSettle();
            });
        
  });
}