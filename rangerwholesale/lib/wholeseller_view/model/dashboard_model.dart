// class DashboardDataModel {
//   bool? success;
//   String? message;
//   DashboardData? data;
//
//   DashboardDataModel({this.success, this.message, this.data});
//
//   DashboardDataModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];
//     data = json['data'] != null ? new DashboardData.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class DashboardData {
//   Orders? orders;
//   Retailers? retailers;
//
//   DashboardData({this.orders, this.retailers});
//
//   DashboardData.fromJson(Map<String, dynamic> json) {
//     orders =
//     json['orders'] != null ? new Orders.fromJson(json['orders']) : null;
//     retailers =
//     json['retailers'] != null ? new Retailers.fromJson(json['retailers']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.orders != null) {
//       data['orders'] = this.orders!.toJson();
//     }
//     if (this.retailers != null) {
//       data['retailers'] = this.retailers!.toJson();
//     }
//     return data;
//   }
// }
//
// class Orders {
//   CurrentYear? currentYear;
//   Today? today;
//   Today? allTime;
//
//   Orders({this.currentYear, this.today, this.allTime});
//
//   Orders.fromJson(Map<String, dynamic> json) {
//     currentYear = json['currentYear'] != null
//         ? new CurrentYear.fromJson(json['currentYear'])
//         : null;
//     today = json['today'] != null ? new Today.fromJson(json['today']) : null;
//     allTime =
//     json['allTime'] != null ? new Today.fromJson(json['allTime']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.currentYear != null) {
//       data['currentYear'] = this.currentYear!.toJson();
//     }
//     if (this.today != null) {
//       data['today'] = this.today!.toJson();
//     }
//     if (this.allTime != null) {
//       data['allTime'] = this.allTime!.toJson();
//     }
//     return data;
//   }
// }
//
// class CurrentYear {
//   int? totalOrders;
//   MonthlyCounts? monthlyCounts;
//
//   CurrentYear({this.totalOrders, this.monthlyCounts});
//
//   CurrentYear.fromJson(Map<String, dynamic> json) {
//     totalOrders = json['totalOrders'];
//     monthlyCounts = json['monthlyCounts'] != null
//         ? new MonthlyCounts.fromJson(json['monthlyCounts'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['totalOrders'] = this.totalOrders;
//     if (this.monthlyCounts != null) {
//       data['monthlyCounts'] = this.monthlyCounts!.toJson();
//     }
//     return data;
//   }
// }
//
// class MonthlyCounts {
//   December? december;
//
//   MonthlyCounts({this.december});
//
//   MonthlyCounts.fromJson(Map<String, dynamic> json) {
//     december = json['December'] != null
//         ? new December.fromJson(json['December'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.december != null) {
//       data['December'] = this.december!.toJson();
//     }
//     return data;
//   }
// }
//
// class December {
//   int? total;
//
//   December({this.total});
//
//   December.fromJson(Map<String, dynamic> json) {
//     total = json['total'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['total'] = this.total;
//     return data;
//   }
// }
//
// class Today {
//   int? totalOrders;
//
//   Today({this.totalOrders});
//
//   Today.fromJson(Map<String, dynamic> json) {
//     totalOrders = json['totalOrders'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['totalOrders'] = this.totalOrders;
//     return data;
//   }
// }
//
// class Retailers {
//   int? totalRetailers;
//   int? approvedRetailers;
//   int? unapprovedRetailers;
//
//   Retailers({this.totalRetailers, this.approvedRetailers, this.unapprovedRetailers});
//
//   Retailers.fromJson(Map<String, dynamic> json) {
//     totalRetailers = json['totalRetailers'];
//     approvedRetailers = json['approvedRetailers'];
//     unapprovedRetailers = json['unapprovedRetailers'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['totalRetailers'] = this.totalRetailers;
//     data['approvedRetailers'] = this.approvedRetailers;
//     data['unapprovedRetailers'] = this.unapprovedRetailers;
//     return data;
//   }
// }
