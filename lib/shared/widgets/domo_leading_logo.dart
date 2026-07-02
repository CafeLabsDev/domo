import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DomoPageTitle extends StatelessWidget {
  const DomoPageTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final double logoHeight = 15;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: logoHeight,
          width: logoHeight * 2,
          child: FittedBox(
            fit: BoxFit.fill,
            child: SvgPicture.asset('assets/icons/domo_icon.svg'),
          ),
        ),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}
