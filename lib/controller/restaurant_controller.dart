import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/response/coupon_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/data/model/response/review_model.dart';
import 'package:efood_multivendor/data/repository/restaurant_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class RestaurantController extends GetxController implements GetxService {
  final RestaurantRepo restaurantRepo;
  RestaurantController({@required this.restaurantRepo});

  List<Restaurant> _restaurantList;
  List<Restaurant> _popularRestaurantList;
  List<Restaurant> _latestRestaurantList;
  List<Restaurant> _offerRestaurantList;
  Restaurant _restaurant;
  List<Product> _restaurantProducts;
  int _categoryIndex = 0;
  bool _isLoading = false;
  int _pageSize;
  List<String> _offsetList = [];
  int _offset = 1;
  String _restaurantType = 'all';
  List<ReviewModel> _restaurantReviewList;
  List<CouponModel> _restaurantCouponList;

  List<Restaurant> get restaurantList => _restaurantList;
  List<Restaurant> get popularRestaurantList => _popularRestaurantList;
  List<Restaurant> get latestRestaurantList => _latestRestaurantList;
  List<Restaurant> get offerRestaurantList => _offerRestaurantList;
  Restaurant get restaurant => _restaurant;
  List<Product> get restaurantProducts => _restaurantProducts;
  int get categoryIndex => _categoryIndex;
  bool get isLoading => _isLoading;
  int get popularPageSize => _pageSize;
  int get offset => _offset;
  String get restaurantType => _restaurantType;
  List<ReviewModel> get restaurantReviewList => _restaurantReviewList;
  List<CouponModel> get restaurantCouponList => _restaurantCouponList;


  void setOffset(int offset) {
    _offset = offset;
  }

  Future<void> getRestaurantList(String offset, bool reload) async {
    if(offset == '1' || reload) {
      _offsetList = [];
      _offset = 1;
      if(reload) {
        _restaurantList = null;
      }
      update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      Response response = await restaurantRepo.getRestaurantList(offset, _restaurantType);
      if (response.statusCode == 200) {
        if (offset == '1') {
          _restaurantList = [];
        }
        _restaurantList.addAll(RestaurantModel.fromJson(response.body).restaurants);
        _pageSize = RestaurantModel.fromJson(response.body).totalSize;
        _isLoading = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  void setRestaurantType(String type) {
    _restaurantType = type;
    getRestaurantList('1', true);
  }

  Future<void> getRestaurantCoupon(int restaurantId , int zoneId)async {
    Response response = await restaurantRepo.getRestaurantCouponList(restaurantId,zoneId);

    if (response.statusCode == 200) {
      _restaurantCouponList = [];
      response.body["couponArray"].forEach((category) {
              _restaurantCouponList.add(CouponModel.fromJson(category));
      });

      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getPopularRestaurantList(bool reload) async {
    if(_popularRestaurantList == null || reload) {
      Response response = await restaurantRepo.getPopularRestaurantList();
      if (response.statusCode == 200) {
        _popularRestaurantList = [];
        response.body.forEach((restaurant) => _popularRestaurantList.add(Restaurant.fromJson(restaurant)));
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getLatestRestaurantList(bool reload) async {
    if(_latestRestaurantList == null || reload) {
      Response response = await restaurantRepo.getLatestRestaurantList();
      if (response.statusCode == 200) {
        _latestRestaurantList = [];
        response.body.forEach((restaurant) => _latestRestaurantList.add(Restaurant.fromJson(restaurant)));
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<void> getOfferRestaurantList(bool reload) async {
    print('offerasdf1');
    if (_offerRestaurantList == null || reload) {
      Response response = await restaurantRepo.getOfferRestaurantList(1);
      if (response.statusCode == 200) {
        _offerRestaurantList = [];
        print('offerasdf ' + response.body.toString());
        response.body.forEach((restaurant) {
          print('offerasdf' + restaurant['restaurant'].toString());
          _offerRestaurantList.add(Restaurant.fromJson(restaurant['restaurant']));

        });
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  Future<Restaurant> getRestaurantDetails(Restaurant restaurant) async {
    _categoryIndex = 0;
    if(restaurant.name != null) {
      _restaurant = restaurant;
    }else {
      _isLoading = true;
      _restaurant = null;
      Response response = await restaurantRepo.getRestaurantDetails(restaurant.id.toString());
      if (response.statusCode == 200) {
        _restaurant = Restaurant.fromJson(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
      Get.find<OrderController>().setOrderType(
        _restaurant != null ? _restaurant.delivery ? 'delivery' : 'take_away' : 'delivery', notify: false,
      );

      _isLoading = false;
      update();
    }
    return _restaurant;
  }

  Future<void> getRestaurantProductList(String restaurantID) async {
    _restaurantProducts = null;
    Response response = await restaurantRepo.getRestaurantProductList(restaurantID);
    if (response.statusCode == 200) {
      _restaurantProducts = [];
      _restaurantProducts.addAll(ProductModel.fromJson(response.body).products);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setCategoryIndex(int index) {
    _categoryIndex = index;
    update();
  }

  Future<void> getRestaurantReviewList(String restaurantID) async {
    _restaurantReviewList = null;
    Response response = await restaurantRepo.getRestaurantReviewList(restaurantID);
    if (response.statusCode == 200) {
      _restaurantReviewList = [];
      response.body.forEach((review) => _restaurantReviewList.add(ReviewModel.fromJson(review)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  bool isRestaurantClosed(bool today, bool active, String offDay) {
    offDay = offDay.trim();
    DateTime _date = DateTime.now();
    if(!today) {
      _date = _date.add(Duration(days: 1));
    }
    for(int index=0; index<offDay.length; index++) {
      if(_date.weekday == int.parse(offDay[index])) {
        return true;
      }
    }
    return !active;
  }

}