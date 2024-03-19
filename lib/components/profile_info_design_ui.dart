import 'package:flutter/material.dart';

import '../constants.dart';

class InfoDesignUI extends StatefulWidget {
  String? textInfo;
  IconData? icon;

  InfoDesignUI({super.key, this.textInfo, this.icon});

  @override
  State<InfoDesignUI> createState() => _InfoDesignUIState();
}

class _InfoDesignUIState extends State<InfoDesignUI> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(vertical: AppSpaceValues.space2, horizontal: AppSpaceValues.space3),
      child: ListTile(
        leading: Icon(
          widget.icon,
          color: AppColors.gray9,
        ),
        title: Text(
          widget.textInfo!,
          softWrap: true,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            height: AppLineHeights.l,
            color: AppColors.gray9,
            fontSize: AppFontSizes.m,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
