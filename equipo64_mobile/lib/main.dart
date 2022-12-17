import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edamam.dart';
import 'utilities.dart';

const int breakPoint = 600;



void main() {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SearchModel()),
            ChangeNotifierProvider(create: (_) => RecipesModel()),
            ChangeNotifierProvider(create: (_) => TabletInfo()),
          ],
          child: const MyApp()
      )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFF000000,
          <int, Color>{
            50: Color(0xFF000000),
            100: Color(0xFF000000),
            200: Color(0xFF000000),
            300: Color(0xFF000000),
            400: Color(0xFF000000),
            500: Color(0xFF000000),
            600: Color(0xFF000000),
            700: Color(0xFF000000),
            800: Color(0xFF000000),
            900: Color(0xFF000000),
          },
        ),
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}
class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) => ScreenSelector(),
            )
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image.asset('assets/images/LogoApp.png'),
    );
  }
}

class ScreenSelector extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints){
          bool chooseScreen = (
              constraints.smallest.longestSide > breakPoint &&
                  MediaQuery.of(context).orientation == Orientation.landscape
          );
          return chooseScreen ? TabletScreen() : MobileScreen();
        }
    );
  }
}


class MobileScreen extends StatelessWidget {
  const MobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text("RecipeApp"), centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            SearchBar(),
            const RecipesList(isMobile: true,),
          ],
        ),
      ),
    );
  }
}


class TabletInfo extends ChangeNotifier{
  var recipe = null;

  void setRecipe(Recipe value) {
    recipe = value;
    notifyListeners();
  }
}

class TabletScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    var recipeTablet = context.watch<TabletInfo>().recipe;
    return Scaffold(
        appBar: AppBar(title:const Text("RecipeApp"), centerTitle: true,),
        body:
          Row(
            children: <Widget>[
              Flexible(
                flex: 13,
                child: Material(
                  elevation: 4.0,
                  child:Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          SearchBar(),
                          const RecipesList(isMobile: false,),
                        ],
                      )
                  ),
                ),
              ),
              Flexible(
                  flex: 27,
                  child: recipeTablet == null
                      ? Center(
                    child: Image.asset('assets/images/icon.png'),
                  )
                      : DetailsPage(recipe: recipeTablet, isMobile: false,)
              )
            ]
        )
    );
  }

}

class SearchModel extends ChangeNotifier {
  var foodKeyword = " ";
  var cuisineType = "Everywhere";

  void setFoodKeyword(String value) {
    foodKeyword = value;
    notifyListeners();
  }

  void setCuisineType(String value) {
    cuisineType = value;
    notifyListeners();
  }

}

class RecipesModel extends ChangeNotifier {
  List<RecipeBlock> blocks = [];
  List<Recipe> recipes = [];

  void searchRecipes(String foodKeyword, String cuisineType, List<RecipeBlock> blockList) {
    var futureRecipes = search_recipes(foodKeyword, cuisineType, blockList);
    futureRecipes.then((retrievedRecipes) {
      blocks = retrievedRecipes;
      updateRecipesList(blocks);
      notifyListeners();
    });
  }

  void updateRecipesList(List<RecipeBlock> blocks){
    List<Recipe> recipeList = [];
    for (var block in blocks)
      recipeList.addAll(block.getListRecipes() ?? []);
    recipes = recipeList;
    notifyListeners();
  }

}

class SearchBar extends StatefulWidget {
  static final searchKey = GlobalKey<FormState>();

  SearchBar({super.key});

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: SearchBar.searchKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(hintText: "Introduce some food"),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty || value.trim() == "") {
                return "Please introduce food";
              }
              context.read<SearchModel>().setFoodKeyword(value);
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.all(10.0),),
          const Text("Cuisine type:",
            style:
            TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold
            ),
          ),
          DropdownButton<String>(
            key: const ValueKey('dropdown'),
            items: [
              "Everywhere",
              "American",
              "Asian",
              "British",
              "Caribbean",
              "Central Europe",
              "Chinese",
              "Eastern Europe",
              "French",
              "Indian",
              "Italian",
              "Japanese",
              "Kosher",
              "Mediterranean",
              "Mexican",
              "Middle Eastern",
              "Nordic",
              "South American",
              "South East Asian"
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            elevation: 8,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_sharp),
            value: context.watch<SearchModel>().cuisineType,
            onChanged: (value) {
              context.read<SearchModel>().setCuisineType(value!);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ElevatedButton(
              onPressed: () {
                if (SearchBar.searchKey.currentState!.validate()) {
                  String foodKeyword = context.read<SearchModel>().foodKeyword;
                  String cuisineType = context.read<SearchModel>().cuisineType;
                  context.read<RecipesModel>().searchRecipes(foodKeyword, cuisineType, []);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Searching..."),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: const Text("Search"),
            ),
          ),
        ],
      ),
    );
  }
}


class RecipesList extends StatelessWidget {

  final bool isMobile;
  const RecipesList({super.key, required this.isMobile});
  @override
  Widget build(BuildContext context) {
    List<Recipe> recipes = context.watch<RecipesModel>().recipes;
    String keyword = context.read<SearchModel>().foodKeyword;
    return recipes == null || keyword == " "
        ? const Center(
      child: Text("Search some recipes!",
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 20,
        ),
      ),
    )
        : recipes.isEmpty
        ? const Center(child:
    Text("No recipes found!",
      style: TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: 20,
      ),
    ),
    )
        : Expanded(
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (scrollEnd) {
            final metrics = scrollEnd.metrics;
            if (metrics.atEdge) {
              bool isTop = metrics.pixels == 0;
              if (!(isTop)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Loading more recipes..."),
                    duration: Duration(seconds: 1),
                  ),
                );
                String foodKeyword = context.read<SearchModel>().foodKeyword;
                String cuisineType = context.read<SearchModel>().cuisineType;
                List<RecipeBlock> blocks = context.read<RecipesModel>().blocks;
                context.read<RecipesModel>().searchRecipes(foodKeyword, cuisineType, blocks);
              }
            }
            return true;
          },
          child:ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, i) {
              var recipe = recipes[i];
              if(isMobile){
                return Card(
                  color: const Color(0xBEC2FFAB),
                  child: ExpansionTile(
                    key: ValueKey("recipe-${recipe.uri}"),
                    title: Text(
                      utf8.decode("${recipe.label}".codeUnits),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(padding: EdgeInsets.all(8.0),),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child:  FadeInImage(
                              image: NetworkImage("${(recipe.thumbnail)}"),
                              fadeInDuration: Duration(milliseconds:25),
                              fadeOutDuration: Duration(milliseconds:25),
                              placeholder: AssetImage('assets/images/errorGifSmall.gif'),
                              imageErrorBuilder:
                                (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/error.png',
                                fit: BoxFit.fitWidth);
                              },
                              fit: BoxFit.fitWidth,
                            )
                          ),
                          const Padding(padding: EdgeInsets.all(8.0),),
                          Text("Servings: ${(recipe.servings)?.round()} people\n"
                              "Calories: ${(recipe.calories)?.round()} kcal",
                            style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsPage(recipe: recipe, isMobile: isMobile,)),
                          );
                        },
                        child: const Text("View Details"),
                      ),
                    ],
                  ),
                );

              }else{
                return Card(
                    child: ElevatedButton(
                        onPressed: () {
                          context.read<TabletInfo>().setRecipe(recipe);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child:Text(
                            utf8.decode("${recipe.label}".codeUnits),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xBEC2FFAB),
                        )
                    )
                );
              }

            },
          ),
        )
    );
  }
}

class DetailsPage extends StatelessWidget {
  Recipe recipe;
  bool isMobile;
  DetailsPage({super.key, required this.recipe, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if(isMobile){
      return Scaffold(
        appBar: AppBar(
          title: const Text("Recipe detail"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.all(6.0),),
              Text(
                utf8.decode("${recipe.label}".codeUnits),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Padding(padding: EdgeInsets.all(8.0),),
              RecipeInfo(recipe: recipe)
            ],
          ),
        ),
      );
    }else{
      return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.all(6.0),),
              Text(
                utf8.decode("${recipe.label}".codeUnits),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Padding(padding: EdgeInsets.all(8.0),),
              RecipeInfo(recipe: recipe)
            ],
          ),
        ),
      );
    }

  }
}

class DetailsRow extends StatelessWidget {
  IconData icon;
  String title;
  String info;
  DetailsRow({super.key, required this.icon, required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xBEC2FFAB),
      child: Row(
        children: [
          Padding(padding: const EdgeInsets.only(left: 14.0)),
          Icon(
            icon,
            color: Colors.black,
            size: 30.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
          ),
          Flexible(
              child: new Text(
                utf8.decode(info.codeUnits),
                style: TextStyle(
                  fontSize: 18,
                ),
              )
          )
        ],
      ),
    );
  }
}

class DetailsRowExpanded extends StatelessWidget {
  IconData icon;
  String title;
  String info;
  DetailsRowExpanded({super.key, required this.icon, required this.title, required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xBEC2FFAB),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_right_rounded),
        children: <Widget>[
          Text(
            utf8.decode(info.codeUnits),
            style: TextStyle(fontSize: 18),
          )
        ],
      ),
    );
  }
}

class RecipeInfo extends StatelessWidget {
  Recipe recipe;
  RecipeInfo({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child:  FadeInImage(
                      image: NetworkImage("${(recipe.image)}"),
                      fadeInDuration: Duration(milliseconds:25),
                      fadeOutDuration: Duration(milliseconds:25),
                      placeholder: AssetImage('assets/images/errorGifBig.gif'),
                      imageErrorBuilder:
                          (context, error, stackTrace) {
                        return Image.asset(
                            'assets/images/errorImageBig.png',
                            fit: BoxFit.fitWidth);
                      },
                      fit: BoxFit.fitWidth,
                    )
                  )
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
              ),
              DetailsRow(
                icon: Icons.people,
                title: "Servings:",
                info: "\n${(recipe.servings)?.round()} people\n",
              ),
              DetailsRow(
                icon: Icons.local_fire_department_rounded,
                title: "Calories: ",
                info: "\n${(recipe.calories)?.round()} kcal per serving\n",
              ),
              DetailsRow(
                icon: Icons.info,
                title: "Source:",
                info: "\n${(recipe.source)}\n",
              ),
              DetailsRowExpanded(
                icon: Icons.health_and_safety_rounded,
                title: "Health Labels: ",
                info: "${toStringList(recipe.healthLabels)}",
              ),
              DetailsRowExpanded(
                icon: Icons.thumb_up_rounded,
                title: "Diet Labels: ",
                info: "${toStringList(recipe.dietLabels)}",
              ),
              DetailsRowExpanded(
                icon: Icons.warning_rounded,
                title: "Cautions: ",
                info: "${toStringList(recipe.cautions)}",
              ),
              DetailsRowExpanded(
                icon: Icons.local_restaurant_rounded,
                title: "Ingredients: ",
                info: "${toStringList(recipe.ingredients)}",
              ),
              DetailsRow(
                  icon: Icons.breakfast_dining_rounded,
                  title: "Glycemic Index:",
                  info: "\n${(recipe.calories)?.round()}\n"
              ),
              DetailsRow(
                  icon: Icons.co2_rounded,
                  title: "Total CO2 Emissions:",
                  info: "\n${(recipe.totalCO2Emissions)?.round()}\n"
              ),
              DetailsRow(
                  icon: Icons.co2_rounded,
                  title: "CO2 Emissions Class:",
                  info: "\n${(recipe.co2EmissionsClass)}\n"
              ),
              DetailsRow(
                  icon: Icons.timer,
                  title: "Total Time:",
                  info: "\n${(recipe.totalTime)?.round()}\n"
              ),
              DetailsRow(
                icon: Icons.south_america_rounded,
                title: "Cuisine Type:",
                info: "${toStringList(recipe.cuisineType)}",
              ),
              DetailsRow(
                icon: Icons.lunch_dining_rounded,
                title: "Meal Type:",
                info: "${toStringList(recipe.mealType)}",
              ),
              DetailsRow(
                icon: Icons.table_bar_rounded,
                title: "Dish Type:",
                info: "${toStringList(recipe.dishType)}",
              ),
              DetailsRowExpanded(
                icon: Icons.calculate_rounded,
                title: "Total Nutrients:",
                info: "${toStringNutrientsList(recipe.totalNutrients)}",
              ),
              DetailsRowExpanded(
                icon: Icons.percent_rounded,
                title: "Total Daily:",
                info: "${toStringTotalDailyList(recipe.totalDaily)}",
              ),
            ],
          ),
        )
    );
  }
}