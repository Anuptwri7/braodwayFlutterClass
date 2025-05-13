class StringConst {
  static String appNameFirst = "Ranger";
  static String appNameSecond = "Wholesale";
  // static String protocol = "http://";
  static String protocol = "https://";
  // static String baseUrl = "192.168.1.64:31240";
  static String baseUrl = "ranger-wholesale-api.sooritechnology.com.np";
  static String login = "/auth/public/login/";
  static String signup = "/auth/user/register/";
  static String registerRetailer = "/api/v1/retailer/";
  static String updateRetailer = "/api/v1/retailer/retailer-update-all/";
  static String getRetailer = "/api/v1/retailer/";
  static String fetchProduct = "/api/v1/product/list/sub-category/";
  static String fetchProductScan = "/api/v1/product/public/";
  static String fetchCategory = "/api/v1/product/public/category/";
  static String addToCart = "/api/v1/cart/public/";
  static String getCartItems = "/api/v1/cart/public/";
  static String placeOrder = "/api/v1/order/public/create/";
  static String getOrders = "/api/v1/order/public/list/";
  static String address = "/api/v1/address/public/";
  static String patchAddress = "/api/v1/address/public/";
  static String fetchSubcategory = "/api/v1/product/public/sub-category-by-category/";
  static String userDetail = "/auth/public/user-detail/";
  static String changePassword = "/auth/public/change-password/";
  static String otpChangePassword = "/auth/public/active-account-change-password/";
  static String forgetPassword = "/auth/public/forgot-password/";
  static String otpRequest = "/auth/public/otp-request/";
  static String scanItem = "/api/v1/product/public/variant-scan/";
  static String deactivateAccount = "/api/v1/retailer/deactivate-retailer/";

  //api for admin or whole seller
  static String fetchProductsAdmin = "/api/v1/product/";
  static String dashboard = "/api/v1/dashboard/";
  static String fetchOrdersAdmin = "/api/v1/order/";
  static String fetchRetailers = "/api/v1/retailer/";
  static String fetchRetailerForFilter = "/auth/list-user/";
  static String patchRetailers = "/auth/user/";
  static String deleteRetailer = "/auth/delete/retailer/";
  static String refreshToken = "/auth/public/refresh-token/";
}