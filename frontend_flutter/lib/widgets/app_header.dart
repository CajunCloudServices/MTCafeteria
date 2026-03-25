import 'package:flutter/material.dart';

double appHeaderToolbarHeight(BuildContext context) =>
    MediaQuery.of(context).size.width < 760 ? 108 : 96;

double appHeaderMenuIconSize(BuildContext context) =>
    MediaQuery.of(context).size.width < 760 ? 32 : 28;

Text buildAppHeaderTitle(BuildContext context, String label) {
  final isMobile = MediaQuery.of(context).size.width < 760;
  return Text(
    label,
    style: TextStyle(
      fontSize: isMobile ? 26 : 24,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      color: const Color(0xFF12365E),
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

class AppHeaderMenuButton extends StatelessWidget {
  const AppHeaderMenuButton({
    super.key,
    required this.itemBuilder,
    required this.onSelected,
  });

  final PopupMenuItemBuilder<String> itemBuilder;
  final PopupMenuItemSelected<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 760;
    return PopupMenuButton<String>(
      padding: EdgeInsets.only(left: 8, right: isMobile ? 14 : 10),
      icon: Icon(Icons.menu, size: appHeaderMenuIconSize(context)),
      onSelected: onSelected,
      itemBuilder: itemBuilder,
    );
  }
}
