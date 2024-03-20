import 'package:get/get.dart';


class HomeController extends GetxController {
  static HomeController instance = Get.find();
  
  RxBool isBannerLoading = false.obs;
  RxBool isPopularCategoryLoading = false.obs;
  RxBool isPopularProductLoading = false.obs;

  @override
  void onInit() {
    getAdBanners();
    getPopularCategories();
    getPopularProducts();
    super.onInit();
  }

  void getAdBanners() async{
    try{
      isBannerLoading(true);
     
    } finally {
      isBannerLoading(false);
    }
  }

  void getPopularCategories() async{
    try{
      isPopularCategoryLoading(true);
      
    } finally {
     
    }
  }

  void getPopularProducts() async{
    try{
      isPopularProductLoading(true);
      
    } finally {
      
    }
  }
  
}