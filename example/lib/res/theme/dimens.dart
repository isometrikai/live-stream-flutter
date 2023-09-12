import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dimens {
  const Dimens._();

  /// Get the height with the percent value of the screen height.
  static double percentHeight(double percentValue) => percentValue.sh;

  /// Get the width with the percent value of the screen width.
  static double percentWidth(double percentValue) => percentValue.sw;

  static final double zero = 0.sp;
  static final double one = 1.sp;
  static final double two = 2.sp;
  static final double four = 4.sp;
  static final double five = 5.sp;
  static final double six = 6.sp;

  static final double eight = 8.sp;
  static final double nine = 9.sp;
  static final double ten = 10.sp;
  static final double twelve = 12.sp;

  static final double fifteen = 15.sp;
  static final double sixteen = 16.sp;
  static final double twenty = 20.sp;
  static final double twentyFour = 24.sp;
  static final double twentyFive = 25.sp;

  static final double thirty = 30.sp;
  static final double thirtyTwo = 32.sp;

  static final double forty = 40.sp;
  static final double fifty = 50.sp;
  static final double fiftyFive = 55.sp;
  static final double sixty = 60.sp;
  static final double seventyEight = 78.sp;

  static final double eighty = 80.sp;
  static final double ninty = 90.sp;

  static final double hundred = 100.sp;
  static final double oneHundredTwenty = 120.sp;
  static final double hundredFourty = 140.sp;
  static final double oneHundredFifty = 150.sp;
  static final double oneHundredSeventy = 170.sp;
  static final double twoHundred = 200.sp;
  static final double twoHundredTwenty = 220.sp;
  static final double twoHundredFifty = 250.sp;

  static final Widget box0 = SizedBox(height: zero);

  static final Widget boxHeight2 = SizedBox(height: two);
  static final Widget boxHeight4 = SizedBox(height: four);
  static final Widget boxHeight5 = SizedBox(height: five);
  static final Widget boxHeight8 = SizedBox(height: eight);
  static final Widget boxHeight10 = SizedBox(height: ten);

  static final Widget boxHeight16 = SizedBox(height: sixteen);
  static final Widget boxHeight20 = SizedBox(height: twenty);
  static final Widget boxHeight24 = SizedBox(height: twentyFour);
  static final Widget boxHeight32 = SizedBox(height: thirtyTwo);

  static final Widget boxWidth2 = SizedBox(width: two);
  static final Widget boxWidth4 = SizedBox(width: four);
  static final Widget boxWidth8 = SizedBox(width: eight);
  static final Widget boxWidth10 = SizedBox(width: ten);
  static final Widget boxWidth12 = SizedBox(width: twelve);
  static final Widget boxWidth16 = SizedBox(width: sixteen);
  static final Widget boxWidth20 = SizedBox(width: twenty);
  static final Widget boxWidth24 = SizedBox(width: twentyFour);
  static final Widget boxWidth32 = SizedBox(width: thirtyTwo);

  static const EdgeInsets edgeInsets0 = EdgeInsets.zero;
  static final EdgeInsets edgeInsets4 = EdgeInsets.all(four);
  static final EdgeInsets edgeInsets5 = EdgeInsets.all(five);
  static final EdgeInsets edgeInsets6 = EdgeInsets.all(six);
  static final EdgeInsets edgeInsets8 = EdgeInsets.all(eight);
  static final EdgeInsets edgeInsets10 = EdgeInsets.all(ten);
  static final EdgeInsets edgeInsets12 = EdgeInsets.all(twelve);
  static final EdgeInsets edgeInsets16 = EdgeInsets.all(sixteen);

  static final EdgeInsets edgeInsetsL2 = EdgeInsets.only(left: two);

  static final EdgeInsets edgeInsetsL4 = EdgeInsets.only(left: four);
  static final EdgeInsets edgeInsetsR4 = EdgeInsets.only(right: four);

  static final EdgeInsets edgeInsets2_0 = EdgeInsets.symmetric(horizontal: two);
  static final EdgeInsets edgeInsets4_0 =
      EdgeInsets.symmetric(horizontal: four);
  static final EdgeInsets edgeInsets8_0 =
      EdgeInsets.symmetric(horizontal: eight);
  static EdgeInsets edgeInsets10_0 = EdgeInsets.symmetric(horizontal: ten);

  static final EdgeInsets edgeInsets0_4 = EdgeInsets.symmetric(vertical: four);
  static final EdgeInsets edgeInsets0_8 = EdgeInsets.symmetric(vertical: eight);

  static final EdgeInsets edgeInsets4_8 =
      EdgeInsets.symmetric(horizontal: four, vertical: eight);
  static final EdgeInsets edgeInsets8_4 =
      EdgeInsets.symmetric(horizontal: eight, vertical: four);
}
