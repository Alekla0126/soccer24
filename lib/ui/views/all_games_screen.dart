import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:soccer24/business_logic/models/fixtures_query.dart';
import 'package:soccer24/business_logic/routes/router.gr.dart';
import 'package:soccer24/business_logic/utils/utils.dart';

import 'package:soccer24/ui/widgets/widgets.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

import '../../business_logic/view_models/view_models.dart';

class AllGamesScreen extends StatefulWidget {
  const AllGamesScreen({Key? key}) : super(key: key);

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  @override
  Widget build(BuildContext context) {
    final calendarModel = Provider.of<CalendarViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: CustomAppBarTitle(
          title: null,
          subtitle: calendarModel.getAppDateDescription(),
        ),
        actions: const [SearchActionButton(), CalenderActionButton()],
        centerTitle: true,
        leading: const SettingsActionButton(),
      ),
      body: _buildCompetitionLoader(context, calendarModel),
    );
  }

  Widget _buildCompetitionLoader(context, CalendarViewModel calendarModel) {
    final model = Provider.of<GamesViewModel>(context, listen: true);

    return FutureBuilder<Map<String, List<FixtureDetails>>>(
      future: model.getAllGames(calendarModel.getSelectedDateApiFormat()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error occurred'),
            );
          }

          var data = snapshot.data!;
          var keys = data.keys.toList();
          bool darkMode =
              Provider.of<SettingsViewModel>(context, listen: true).darkMode;

          return GroupedListView<String, String>(
            elements: keys,
            groupBy: (key) =>
                key == kFavouriteKey ? kFavouriteKey : kOtherCompetitionsKey,
            groupSeparatorBuilder: (String groupByValue) {
              return groupByValue == kFavouriteKey
                  ? FavouriteGroupHeader(isDarkMode: darkMode)
                  : OthersGroupHeader(
                      isDarkMode: darkMode,
                      text: groupByValue,
                    );
            },
            useStickyGroupSeparators: true,
            itemBuilder: (context, key) {
              List<FixtureDetails> fixtures = data[key]!;
              return key == kFavouriteKey
                  ? _buildFavouriteTiles(context, model.getFixturesSortGroup(fixtures))
                  : _buildGameTile(fixtures, key, context);
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildFavouriteTiles(
    BuildContext context,
    Map<String, List<FixtureDetails>> fixturesSortGroup,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var entry in fixturesSortGroup.entries)
          _buildGameTile(entry.value, entry.key, context)
      ],
    );
  }

  ListTile _buildGameTile(
    List<FixtureDetails> fixtures,
    String key,
    BuildContext context,
  ) {
    return ListTile(
      title: CompetitionCard(
        imageUrl: fixtures.first.league.flag,
        text: key,
        total: fixtures.length,
      ),
      shape: MethodUtils.getTileShapeBorder(context),
      onTap: () {
        context.router.push(
          FixturesRoute(
            title: fixtures.first.league.name,
            fixtures: fixtures,
          ),
        );
      },
    );
  }
}
