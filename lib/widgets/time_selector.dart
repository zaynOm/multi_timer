import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimeSelector extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const TimeSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(8.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: context.sp(16))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: onDecrease,
                iconSize: context.r(20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.all(context.r(4)),
              ),
              Container(
                width: context.w(40),
                alignment: Alignment.center,
                child: Text(value.toString(), style: TextStyle(fontSize: context.sp(16))),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onIncrease,
                iconSize: context.r(20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.all(context.r(4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
