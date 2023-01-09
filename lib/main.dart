// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

@immutable
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavourite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavourite,
  });

  Film copy({
    required bool isFavourite,
  }) =>
      Film(
        id: id,
        title: title,
        description: description,
        isFavourite: isFavourite,
      );
  @override
  String toString() => 'Film(id: $id,'
      'title: $title,'
      'description: $description,'
      'isFavourite: $isFavourite)';

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavourite == other.isFavourite;

  @override
  int get hashCode => Object.hashAll(
        [
          id,
          isFavourite,
        ],
      );
}

const allFilms = [
  Film(
    id: '1',
    title: 'The Shawshank Redemption',
    description: 'Description for The Shawshank Redemption',
    isFavourite: false,
  ),
  Film(
    id: '2',
    title: 'The Godfather',
    description: 'Description for The Godfather',
    isFavourite: false,
  ),
  Film(
    id: '3',
    title: 'Schindler\'s List',
    description: 'Description for Schindler\'s List',
    isFavourite: false,
  ),
  Film(
    id: '4',
    title: 'The Dark Knight',
    description: 'Description for The Dark Knight',
    isFavourite: false,
  ),
  Film(
    id: '5',
    title: '12 Angry Men',
    description: 'Description for 12 Angry Men',
    isFavourite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavourite) {
    state = state
        .map((thisFilm) => thisFilm.id == film.id
            ? thisFilm.copy(isFavourite: isFavourite)
            : thisFilm)
        .toList();
  }
}

enum FavouriteStatus {
  all,
  favourite,
  notFavourite,
}

final favouriteStatusProvider = StateProvider<FavouriteStatus>(
  (_) => FavouriteStatus.all,
);

final allFilmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>(
  (_) => FilmsNotifier(),
);

final favouriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where(
        (film) => film.isFavourite,
      ),
);

final notFavouriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where(
        (film) => !film.isFavourite,
      ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Example 6',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Films'),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          const FilterWidget(),
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(favouriteStatusProvider);

              switch (filter) {
                case FavouriteStatus.all:
                  return FilmsList(
                    provider: allFilmsProvider,
                  );

                case FavouriteStatus.favourite:
                  return FilmsList(
                    provider: favouriteFilmsProvider,
                  );
                case FavouriteStatus.notFavourite:
                  return FilmsList(
                    provider: notFavouriteFilmsProvider,
                  );
              }
            },
          )
        ],
      ),
    );
  }
}

class FilmsList extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;

  const FilmsList({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final favouriteIcon = film.isFavourite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border);
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.description),
            trailing: IconButton(
              icon: favouriteIcon,
              onPressed: () {
                final isFavourite = !film.isFavourite;
                ref.read(allFilmsProvider.notifier).update(
                      film,
                      isFavourite,
                    );
              },
            ),
          );
        },
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
          value: ref.watch(favouriteStatusProvider),
          items: FavouriteStatus.values
              .map(
                (fs) => DropdownMenuItem(
                    value: fs,
                    child: Text(
                      fs.toString().split('.').last,
                    )),
              )
              .toList(),
          onChanged: (fs) {
            ref
                .read(
                  favouriteStatusProvider.notifier,
                )
                .state = fs!;
          },
        );
      },
    );
  }
}
