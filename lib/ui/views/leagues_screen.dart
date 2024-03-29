import 'package:flutter/material.dart';
import 'package:soccer24/business_logic/models/league_query.dart';
import 'package:soccer24/business_logic/utils/utils.dart';

class LeaguesScreen extends StatelessWidget with ToStandingsMixin {
  final String title;
  final List<LeagueDesc> leagues;

  const LeaguesScreen({
    Key? key,
    required this.title,
    required this.leagues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: leagues.length,
        itemBuilder: (BuildContext context, int index) {
          var league = leagues[index].league;

          return ListTile(
            title: Text(league.name),
            shape: MethodUtils.getTileShapeBorder(context),
            onTap: () async {
              goToStandingsWithId(context, league.id);
            },
          );
        },
      ),
    );
  }
}
