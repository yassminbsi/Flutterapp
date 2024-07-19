import 'package:flutter/material.dart';
import 'package:flutter_app/mapwidget/constnats/my_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key}) : super(key: key);

  /*PhoneAuthCubit phoneAuthCubit = PhoneAuthCubit();*/

  Widget buildDrawerHeader(context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsetsDirectional.fromSTEB(70, 10, 70, 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.blue[100],
          ),
         
        ),
        Text(
          '',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        
       
            
      ],
    );
  }

  Widget buildDrawerListItem(
      {required IconData leadingIcon,
      required String title,
      Widget? trailing,
      Function()? onTap,
      Color? color}) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: color ?? MyColors.blue,
      ),
      title: Text(title),
      trailing: trailing ??= Icon(
        Icons.arrow_right,
        color: MyColors.blue,
      ),
      onTap: onTap,
    );
  }

  Widget buildDrawerListItemsDivider() {
    return Divider(
      height: 0,
      thickness: 1,
      indent: 18,
      endIndent: 24,
    );
  }

  void _launchURL(String url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  Widget buildIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Icon(
        icon,
        color: MyColors.blue,
        size: 35,
      ),
    );
  }

  Widget buildSocialMediaIcons() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16),
      child: Row(
        children: [
          buildIcon(
            FontAwesomeIcons.facebook,
            'https://www.facebook.com/groups/omarahmedx14',
          ),
          const SizedBox(
            width: 15,
          ),
          buildIcon(
            FontAwesomeIcons.youtube,
            'https://www.youtube.com/c/OmarAhmedx14/videos',
          ),
          const SizedBox(
            width: 20,
          ),
          buildIcon(
            FontAwesomeIcons.telegram,
            'https://t.me/OmarX14',
          ),
        ],
      ),
    );
  }

  Widget buildLogoutBlocProvider(context) {
    return Container(
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 280,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[100]),
              child: buildDrawerHeader(context),
            ),
          ),
         // buildDrawerListItem(leadingIcon: Icons.person, title: 'My Profile'),
          buildDrawerListItem(
            leadingIcon: Icons.star_border,
            title: 'Favoris',
            onTap: () {
              Navigator.of(context).pushNamed("/HomeFavoris");
            },
          ),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(
            leadingIcon: Icons.history,
            title: 'Places History',
            onTap: () {},
          ),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(leadingIcon: Icons.settings, title: 'Settings'),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(leadingIcon: Icons.help, title: 'Help'),
          buildDrawerListItemsDivider(),
          buildLogoutBlocProvider(context),
          const SizedBox(
            height: 180,
          ),
          Center(
            child: ListTile(
              leading: Text(
                'Follow us',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          buildSocialMediaIcons(),
        ],
      ),
    );
  }
}


