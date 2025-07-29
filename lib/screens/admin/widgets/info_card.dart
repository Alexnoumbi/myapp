import 'package:flutter/material.dart';
import '../../../constants/style.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color topColor;
  final bool isActive;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.topColor,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            color: AppStyles.mainLightColor.withOpacity(.1),
            blurRadius: 12
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: topColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: topColor,
                ),
              ),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: topColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppStyles.indicatorLabelStyle,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyles.indicatorValueStyle.copyWith(
              color: isActive ? AppStyles.mainColor : AppStyles.mainDarkColor,
            ),
          ),
        ],
      ),
    );
  }
}
