import 'edamam.dart';

String toStringList (List<String>? elements){
  var finalString = "\n";
  elements?.forEach((element) {finalString = finalString + "${element.toString()} \n";});
  return finalString;
}

String toStringNutrientsList (List<Nutrient>? elements){
  var finalString = "\n";
  elements?.forEach((element) {finalString = finalString + "${element.label.toString()} :  ${(element.value).round()} ${(element.unit.toString())} \n";});
  return finalString;
}

String toStringTotalDailyList (List<Nutrient>? elements){
  var finalString = "\n";
  elements?.forEach((element) {finalString = finalString + "${element.label.toString()} :  ${(element.value).round()} % \n";});
  return finalString;
}