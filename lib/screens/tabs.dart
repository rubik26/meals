import 'package:cookies/models/meal.dart';
import 'package:cookies/providers/favorites_provider.dart';
import 'package:cookies/providers/meals_provider.dart';
import 'package:cookies/screens/categories.dart';
import 'package:cookies/screens/filters.dart';
import 'package:cookies/screens/meals.dart';
import 'package:cookies/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kInitialFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false,
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoriteMeals = [];
  Map<Filter, bool> _selectedFiltres = kInitialFilters;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String indetifire) async {
    if (indetifire != 'filters') {
      Navigator.of(context).pop();
    } else {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (context) => FiltersScreen(
            currentFilters: _selectedFiltres,
          ),
        ),
      );
      setState(() {
        _selectedFiltres = result ?? kInitialFilters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);

    final availableMeals = meals.where((meal) {
      if (_selectedFiltres[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (_selectedFiltres[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (_selectedFiltres[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (_selectedFiltres[Filter.vegan]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();
    Widget activePage = CategoriesScreen(
      avaibleMeals: availableMeals,
    );
    String activePageTitle = 'Categories';

    if (_selectedPageIndex == 1) {
      final FavoriteMeals = ref.watch(favoriteMealsProvider);
      activePage = MealsScreen(
        meals: _favoriteMeals,
      );
      activePageTitle = 'Your Favorites';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: MainDrawer(
        onSelectScreen: _setScreen,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
