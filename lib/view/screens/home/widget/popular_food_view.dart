import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/discount_tag.dart';
import 'package:efood_multivendor/view/base/not_available_widget.dart';
import 'package:efood_multivendor/view/base/product_bottom_sheet.dart';
import 'package:efood_multivendor/view/base/rating_bar.dart';
import 'package:efood_multivendor/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class PopularFoodView extends StatelessWidget {
  final ProductController productController;
  PopularFoodView({@required this.productController});

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
          child: TitleWidget(title: 'popular_foods_nearby'.tr, onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute())),
        ),

        SizedBox(
          height: 80,
          child: productController.popularProductList != null ? ListView.builder(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
            itemCount: productController.popularProductList.length > 10 ? 10 : productController.popularProductList.length,
            itemBuilder: (context, index){
              bool _isAvailable = DateConverter.isAvailable(
                productController.popularProductList[index].availableTimeStarts,
                productController.popularProductList[index].availableTimeEnds,
              ) && DateConverter.isAvailable(
                productController.popularProductList[index].restaurantOpeningTime,
                productController.popularProductList[index].restaurantClosingTime,
              );

              return Padding(
                padding: EdgeInsets.fromLTRB(2, 2, Dimensions.PADDING_SIZE_SMALL, 2),
                child: InkWell(
                  onTap: () {
                    ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                      ProductBottomSheet(product: productController.popularProductList[index], isCampaign: false),
                      backgroundColor: Colors.transparent, isScrollControlled: true,
                    ) : Get.dialog(
                      Dialog(child: ProductBottomSheet(product: productController.popularProductList[index])),
                    );
                  },
                  child: Container(
                    height: textScaleFactor<0 ? 80 : 80*textScaleFactor, width: textScaleFactor<0 ? 200 : 200*textScaleFactor,
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                        blurRadius: 5, spreadRadius: 1,
                      )],
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                      Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          child: CustomImage(
                            image: '${Get.find<SplashController>().configModel.baseUrls.productImageUrl}'
                                '/${productController.popularProductList[index].image}',
                            height: textScaleFactor<0 ? 70 : 80*textScaleFactor, width: textScaleFactor<0 ? 70 : 80*textScaleFactor, fit: BoxFit.cover,
                          ),
                        ),
                        DiscountTag(
                          discount: productController.popularProductList[index].discount,
                          discountType: productController.popularProductList[index].discountType,
                        ),
                        _isAvailable ? SizedBox() : NotAvailableWidget(),
                      ]),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              productController.popularProductList[index].name,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),

                            Text(
                              productController.popularProductList[index].restaurantName,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),

                            RatingBar(
                              rating: productController.popularProductList[index].avgRating, size: 12,
                              ratingCount: productController.popularProductList[index].ratingCount,
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    PriceConverter.convertPrice(productController.popularProductList[index].price, asFixed: 0),
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ),
                                Container(
                                  child: new Text ("Add", style: robotoRegular.copyWith( fontSize: Dimensions.fontSizeExtraSmall, color: Colors.black87,) ),
                                  decoration:  BoxDecoration ( color : Theme.of(context).primaryColor , borderRadius: BorderRadius.circular(1),),
                                  padding: new EdgeInsets.all(3),
                                )
                              ],
                            ),
                          ]),
                        ),
                      ),

                    ]),
                  ),
                ),
              );
            },
          ) : PopularFoodShimmer(productController: productController),
        ),
      ],
    );
  }
}

class PopularFoodShimmer extends StatelessWidget {
  final ProductController productController;
  PopularFoodShimmer({@required this.productController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
      itemCount: 10,
      itemBuilder: (context, index){
        return Container(
          height: 80, width: 200,
          margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
            boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 10, spreadRadius: 1)],
          ),
          child: Shimmer(
            duration: Duration(seconds: 1),
            interval: Duration(seconds: 1),
            enabled: productController.popularProductList == null,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 70, width: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Colors.grey[300]
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 15, width: 100, color: Colors.grey[300]),
                    SizedBox(height: 5),

                    Container(height: 10, width: 130, color: Colors.grey[300]),
                    SizedBox(height: 5),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(height: 10, width: 30, color: Colors.grey[300]),
                      RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                    ]),
                  ]),
                ),
              ),

            ]),
          ),
        );
      },
    );
  }
}

