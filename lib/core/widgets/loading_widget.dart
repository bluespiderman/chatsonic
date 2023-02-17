import 'package:flutter/material.dart';

import '../utils/assets_manager.dart';

import '../utils/values_manager.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
          width: AppSize.s150,
          height: AppSize.s150,
          child: Image.asset(ImageAssets.loading)),
    );
  }
}
