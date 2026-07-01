import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DomoLeadingLogo extends StatelessWidget {
  const DomoLeadingLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      child: SvgPicture.asset('assets/icons/domo_icon.svg'),
    );
  }
}
