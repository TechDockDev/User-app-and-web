import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/coupon_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/no_data_screen.dart';
import 'package:efood_multivendor/view/screens/restaurant/widget/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewScreen extends StatelessWidget {
  final String restaurantID;
  ReviewScreen({@required this.restaurantID});

  @override
  Widget build(BuildContext context) {
    Get.find<RestaurantController>().getRestaurantReviewList(restaurantID);

    return Scaffold(
      appBar: CustomAppBar(title: 'restaurant_reviews'.tr),
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return restController.restaurantReviewList != null ? restController.restaurantReviewList.length > 0 ? RefreshIndicator(
          onRefresh: () async {
            await restController.getRestaurantReviewList(restaurantID);
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: ListView.builder(
              itemCount: restController.restaurantReviewList.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              itemBuilder: (context, index) {
                return ReviewWidget(
                  review: restController.restaurantReviewList[index],
                  hasDivider: index != restController.restaurantReviewList.length-1,
                );
              },
            )))),
        ) : Center(child: NoDataScreen(text: 'no_review_found'.tr)) : Center(child: CircularProgressIndicator());
      }),
    );
  }
}
