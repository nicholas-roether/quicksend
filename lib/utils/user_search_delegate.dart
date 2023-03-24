import 'package:flutter/material.dart';

class UserSearchDelegate extends SearchDelegate {
  List<String> searchResults = ["Nicholas", "Benni", "Leo"];

  @override
  String? get searchFieldLabel => "Benutzername";

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () => query.isEmpty ? close(context, null) : query = '',
          icon: const Icon(
            Icons.clear,
          ),
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(
          Icons.arrow_back,
        ),
      );

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults.where((element) {
      final result = element.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          suggestions[index],
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: () {
          query = suggestions[index];
          showResults(context);
        },
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }
}
