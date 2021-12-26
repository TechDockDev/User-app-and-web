import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class RestaurantRepo {
  final ApiClient apiClient;
  RestaurantRepo({@required this.apiClient});

  Future<Response> getRestaurantList(String offset, String filterBy) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_URI}/$filterBy?offset=$offset&limit=10');
  }

  Future<Response> getPopularRestaurantList() async {
    return await apiClient.getData('${AppConstants.POPULAR_RESTAURANT_URI}');
  }

  Future<Response> getLatestRestaurantList() async {
    return await apiClient.getData('${AppConstants.LATEST_RESTAURANT_URI}');
  }

  Future<Response> getOfferRestaurantList(int zoneId) async {
    print('offerasdf2');
    return await apiClient.postData('${AppConstants.OFFER_RESTAURANT_URI}',{ "zone_id": zoneId});
  }

  Future<Response> getRestaurantDetails(String restaurantID) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_DETAILS_URI}$restaurantID');
  }

  Future<Response> getRestaurantProductList(String restaurantID) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_PRODUCT_URI}$restaurantID');
  }

  Future<Response> getRestaurantReviewList(String restaurantID) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_REVIEW_URI}?restaurant_id=$restaurantID');
  }

  Future<Response> getRestaurantCouponList(int restaurant_id, int zone_id) async {
    return await apiClient.postData('${AppConstants.RESTAURANT_COUPON_URI}', {"restaurant_id": restaurant_id, "zone_id": zone_id});
  }

}