import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/category_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/response/category_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/cart_widget.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/product_view.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/restaurant/widget/restaurant_description_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantScreen extends StatelessWidget {
  final Restaurant restaurant;
  // final List CouponList
  RestaurantScreen({@required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    Get.find<RestaurantController>().getRestaurantDetails(restaurant);
    final int zoneId = Get.find<LocationController>().zoneId;
    bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn){
      print('Loading restaurant');
      Get.find<RestaurantController>().getRestaurantCoupon(restaurant.id, zoneId); //zoneid
    }
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<RestaurantController>().getRestaurantProductList(restaurant.id.toString());

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return GetBuilder<CategoryController>(builder: (categoryController) {
          List<CategoryProduct> _categoryProducts = [];
          Restaurant _restaurant;
          if(restController.restaurant != null && restController.restaurant.name != null && categoryController.categoryList != null) {
            _restaurant = restController.restaurant;
          }
          if(categoryController.categoryList != null && restController.restaurantProducts != null) {
            _categoryProducts.add(CategoryProduct(CategoryModel(name: 'all'.tr), restController.restaurantProducts));
            List<int> _categorySelectedIds = [];
            List<int> _categoryIds = [];
            categoryController.categoryList.forEach((category) {
              _categoryIds.add(category.id);
            });
            _categorySelectedIds.add(0);
            restController.restaurantProducts.forEach((restProd) {
              if(!_categorySelectedIds.contains(int.parse(restProd.categoryIds[0].id))) {
                _categorySelectedIds.add(int.parse(restProd.categoryIds[0].id));
                _categoryProducts.add(CategoryProduct(
                  categoryController.categoryList[_categoryIds.indexOf(int.parse(restProd.categoryIds[0].id))],
                  [restProd],
                ));
              }else {
                int _index = _categorySelectedIds.indexOf(int.parse(restProd.categoryIds[0].id));
                _categoryProducts[_index].products.add(restProd);
              }
            });
          }

          return (restController.restaurant != null && restController.restaurant.name != null && categoryController.categoryList != null) ? CustomScrollView(
            slivers: [
              ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                child: Container(
                  color: Color(0xFF171A29),
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                  alignment: Alignment.center,
                  child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                    child: Row(children: [

                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          child: CustomImage(
                            fit: BoxFit.cover, placeholder: Images.restaurant_cover, height: 220,
                            image: '${Get.find<SplashController>().configModel.baseUrls.restaurantCoverPhotoUrl}/${_restaurant.coverPhoto}',
                          ),
                        ),
                      ),
                      SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

                      Expanded(child: RestaurantDescriptionView(restaurant: _restaurant)),

                    ]),
                  ))),
                ),
              ) : SliverAppBar(
                expandedHeight: 190, toolbarHeight: 90,
                pinned: true, floating: false,
                backgroundColor: Theme.of(context).primaryColor,
                leading: IconButton(
                  icon: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                    alignment: Alignment.center,
                    child: Icon(Icons.chevron_left, color:Color.fromARGB(
                        255, 42, 42, 42)),
                  ),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: CustomImage(
                    fit: BoxFit.cover, placeholder: Images.restaurant_cover,
                    image: '${Get.find<SplashController>().configModel.baseUrls.restaurantCoverPhotoUrl}/${_restaurant.coverPhoto}',
                  ),
                ),
                actions: [
                  Container(
                    width: 70,
                    child: IconButton(
                    onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                    icon: Container(
                      //height: 90, width: 190,
                      decoration: BoxDecoration(shape: BoxShape.circle, color:Color.fromARGB(
                          255, 42, 42, 42)),
                      alignment: Alignment.center,
                      child: CartWidget(color: Theme.of(context).cardColor, size: 25, fromRestaurant: true),
                    ),
                ),
                  )],
              ),

              SliverToBoxAdapter(child: Center(child: Container(
                width: Dimensions.WEB_MAX_WIDTH,
                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                color: Theme.of(context).cardColor,
                child: Column(children: [
                  ResponsiveHelper.isDesktop(context) ? SizedBox() : RestaurantDescriptionView(restaurant: _restaurant),

                  restController.restaurantCouponList != null ? restController.restaurantCouponList.length > 0 ? RefreshIndicator(
                    onRefresh: () async {
                      await restController.getRestaurantCoupon(restaurant.id, zoneId);
                    },
                    child:SizedBox(
                      height: textScaleFactor<1 ? 80 : 80*textScaleFactor ,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          getRestDiscountView( context,   _restaurant),
                          for(var index=0;index<restController.restaurantCouponList.length;index++)
                            Row(
                              children: [
                                SizedBox( width: Dimensions.PADDING_SIZE_SMALL,),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),border: Border.all(color: Colors.grey)),
                                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                                  child:  restController.restaurantCouponList[index].couponType == 'free_delivery' ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text(
                                      'FREE DELIVERY',
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color:Colors.black87),
                                    ),
                                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL,),
                                    Text(
                                      restController.restaurantCouponList[index].code !=null
                                          ? restController.restaurantCouponList[index].minPurchase !=null && restController.restaurantCouponList[index].minPurchase !=0.0 ?
                                      'USE ${restController.restaurantCouponList[index].code} | ABOVE ${restController.restaurantCouponList[index].minPurchase.toInt()}' : 'USE ${restController.restaurantCouponList[index].code}' : '' ,
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.grey,fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(),
                                  ]) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text(
                                      //debugPrint('');
                                      restController.restaurantCouponList[index].discountType == 'percent' ? '${restController.restaurantCouponList[index].discount.toInt()}% OFF UPTO ${PriceConverter.convertPrice(restController.restaurantCouponList[index].maxDiscount,asFixed: 0) }'
                                          : 'FLAT ${PriceConverter.convertPrice(restController.restaurantCouponList[index].discount,asFixed: 0)} OFF',
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color:Colors.black87),
                                    ),
                                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL,),
                                    Text(
                                      restController.restaurantCouponList[index].minPurchase !=null
                                          ? 'USE ${restController.restaurantCouponList[index].code} | ABOVE ${restController.restaurantCouponList[index].minPurchase.toInt()}'
                                          : 'USE ${restController.restaurantCouponList[index].code}' ,
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.grey,fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(),
                                  ]),
                                ),
                              ],
                            ) ,
                        ],
                      ),
                    )
                  ) : getRestDiscountView(context,_restaurant) : Row(
                      children : [
                        getRestDiscountView( context,   _restaurant),
                        SizedBox(width: Dimensions.fontSizeLarge,),
                        Center(child: SizedBox())
                      ],
                  ),
                ]),
              ))),

              (categoryController.categoryList.length != 0 && restController.restaurantProducts != null) ? SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(child: Center(child: Container(
                  height: 50, width: Dimensions.WEB_MAX_WIDTH, color: Theme.of(context).cardColor,
                  padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoryProducts.length,
                    padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => restController.setCategoryIndex(index),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: index == 0 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
                            right: index == _categoryProducts.length-1 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
                            top: Dimensions.PADDING_SIZE_SMALL,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(index == 0 ? Dimensions.RADIUS_EXTRA_LARGE : 0),
                              right: Radius.circular(index == _categoryProducts.length-1 ? Dimensions.RADIUS_EXTRA_LARGE : 0),
                            ),
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : 2),
                            Text(
                              _categoryProducts[index].category.name,
                              style: index == restController.categoryIndex
                                  ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                  : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ),
                            index == restController.categoryIndex ? Container(
                              height: 5, width: 5,
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                            ) : SizedBox(height: 5, width: 5),
                          ]),
                        ),
                      );
                    },
                  ),
                ))),
              ) : SliverToBoxAdapter(child: SizedBox()),

              SliverToBoxAdapter(child: Center(child: Container(
                width: Dimensions.WEB_MAX_WIDTH,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: ProductView(
                  isRestaurant: false, restaurants: null,
                  products: _categoryProducts.length > 0 ? _categoryProducts[restController.categoryIndex].products : null,
                  inRestaurantPage: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_SMALL,
                    vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_SMALL : 0,
                  ),
                ),
              ))),
            ],
          ) : Center(child: CircularProgressIndicator());
        });
      }),
    );
  }

  Widget getRestDiscountView(BuildContext context, Restaurant  _restaurant){
    return  _restaurant.discount != null ? Container(
      //width: context.width*0.3,
      margin: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),border: Border.all(color: Colors.grey)),
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          _restaurant.discount.discountType == 'percent' ? '${_restaurant.discount.discount}% OFF UPTO ${PriceConverter.convertPrice(_restaurant.discount.maxDiscount)}'
              : 'FLAT ${PriceConverter.convertPrice(_restaurant.discount.discount,asFixed: 0)} OFF',
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color:Colors.black87),
        ),
        Text(
          _restaurant.discount.minPurchase == null && _restaurant.discount.minPurchase == 0
              ? 'ORDER ABOVE ${PriceConverter.convertPrice(_restaurant.discount.minPurchase,asFixed: 0)}'
              : 'ON ALL ORDERS',
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.grey,fontWeight: FontWeight.bold),
        ),
        SizedBox(),
      ]),
    ):SizedBox();
  }

}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }

}

class CategoryProduct {
  CategoryModel category;
  List<Product> products;
  CategoryProduct(this.category, this.products);
}
