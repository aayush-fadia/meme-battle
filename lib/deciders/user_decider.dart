import 'package:flutter/material.dart';
import 'package:meme_battle/synced_models_new/app_user.dart';
import 'package:meme_battle/views/home.dart';
import 'package:meme_battle/views/loading.dart';
import 'package:meme_battle/views/welcome.dart';
import 'package:provider/provider.dart';

class UserDecider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    switch (user.state) {
      case UserState.LOADING:
        return LoadingView();
        break;
      case UserState.UNSET:
        return Welcome();
        break;
      case UserState.SET:
        return HomePage();
        break;
    }
  }
}
