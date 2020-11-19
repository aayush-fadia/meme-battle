import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final player;

  const PlayerCard({Key key, this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      color: player.ready ? Colors.green : Colors.red,
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: player.url,
              placeholder: (_, __) => CircularProgressIndicator(),
            ),
          ),
          Text(
            player.name,
            style: Theme.of(context).textTheme.headline5,
          )
        ],
      ),
    ));
  }
}
