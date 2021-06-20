import 'package:flutter/material.dart';
import 'package:grad_project/screens/EditProfileScreen.dart';
import 'package:grad_project/screens/GroupChatScreen.dart';
import 'package:grad_project/screens/SingleBookScreen.dart';

// Screens
import './screens/LogInSignUpScreen.dart';
import './screens/LoginScreen.dart';
import './screens/signupScreen.dart';
import './screens/HomeScreen.dart';
import './screens/UserGroupsScreen.dart';
import './screens/SingleRoomScreen.dart';
import './screens/BookPdfScreen.dart';
import './screens/GroupMembersScreen.dart';
import './screens/FAQScreen.dart';
import 'screens/UserProfileScreen.dart';
import './screens/CategoryScreen.dart';
import './screens/FavouritesScreen.dart';
import './screens/CommentsRatingsScreen.dart';
import 'screens/UserInvitesScreen.dart';
import 'screens/LeaderboardScreen.dart';
import 'screens/FiltersScreen.dart';
import 'screens/DetailedFitersScreen.dart';
import './screens/ReadingStatisticsScreen.dart';
import 'screens/UserRewardsScreen.dart';
import './screens/ThemeStoreScreen.dart';
import './screens/SuggestBookScreen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String screenName = settings.name;
    final Object args = settings.arguments;
    switch (screenName) {
      case '/':
      case LogInSignUpScreen.routeName:
        return MaterialPageRoute(builder: (_) => LogInSignUpScreen());
      case LogInScreen.routeName:
        return MaterialPageRoute(builder: (_) => LogInScreen());
      case SignUpScreen.routeName:
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      case HomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case SingleBookScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => SingleBookScreen(bookId: args));
      case CategoryScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => CategoryScreen(
                  categoryName: args,
                ));
      case FavouritesScreen.routeName:
        return MaterialPageRoute(builder: (_) => FavouritesScreen());
      case UserGroupsScreen.routeName:
        return MaterialPageRoute(builder: (_) => UserGroupsScreen());
      case SingleRoomScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => SingleRoomScreen(roomId: args));
      case BookPdfScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => BookPdfScreen(
                  arguments: args,
                ));
      case GroupMembersScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => GroupMembersScreen(
                  arguments: args,
                ));
      case FAQScreen.routeName:
        return MaterialPageRoute(builder: (_) => FAQScreen());
      case UserProfileScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => UserProfileScreen(initiallySelectedSection: args));

      case EditProfileScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => EditProfileScreen(
                  profileOwnerMap: args,
                ));

      case UserProfileScreen.routeName:
        return MaterialPageRoute(builder: (_) => UserProfileScreen());
      case GroupChatScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => GroupChatScreen(
                  arguments: args,
                ));
      case CommentsRatingsScreen.routeName:
        return MaterialPageRoute(builder: (_) => CommentsRatingsScreen());
      case ReadingsStatisticsScreen.routeName:
        return MaterialPageRoute(builder: (_) => ReadingsStatisticsScreen());

      case UserInvitesScreen.routeName:
        return MaterialPageRoute(builder: (_) => UserInvitesScreen());

      case LeaderboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => LeaderboardScreen());

      case FiltersScreen.routeName:
        return MaterialPageRoute(builder: (_) => FiltersScreen());
      case SuggestBookScreen.routeName:
        return MaterialPageRoute(builder: (_) => SuggestBookScreen());

      case DetailedFiltersScreen.routeName:
        return MaterialPageRoute(builder: (_) => DetailedFiltersScreen());
      case UserRewardsScreen.routeName:
        return MaterialPageRoute(builder: (_) => UserRewardsScreen());
      case ThemeStoreScreen.routeName:
        return MaterialPageRoute(builder: (_) => ThemeStoreScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
