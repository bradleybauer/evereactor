import 'package:flutter/material.dart';

class SearchBarFlyoutContent extends StatelessWidget {
  static const Size CONTENTSIZE = Size(340, 200);

  const SearchBarFlyoutContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: CONTENTSIZE.width,
        height: CONTENTSIZE.height,
        color: const Color.fromARGB(255, 198, 221, 240),
        child: const Center(
            child: Text(
          'search results',
          style: TextStyle(fontFamily: 'NotoSans', fontSize: 32),
        )),
      ),
    );
  }
}
