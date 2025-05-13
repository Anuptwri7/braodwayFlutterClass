// class OrderListingModel {
//   bool? success;
//   String? message;
//   List<Data>? data;
//   Pagination? pagination;
//
//   OrderListingModel({this.success, this.message, this.data, this.pagination});
//
//   OrderListingModel.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//     pagination = json['pagination'] != null
//         ? new Pagination.fromJson(json['pagination'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     if (this.pagination != null) {
//       data['pagination'] = this.pagination!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   int? id;
//   List<CartItem>? cartItem;
//   int? quantity;
//   String? price;
//   ShippingAddress? shippingAddress;
//   String? uniqueCode;
//   String? modeOfDelivery;
//   String? status;
//   Retailer? retailer;
//   UserDetails? userDetails;
//
//   Data(
//       {this.id,
//         this.cartItem,
//         this.quantity,
//         this.price,
//         this.shippingAddress,
//         this.uniqueCode,
//         this.modeOfDelivery,
//         this.status,
//         this.retailer,
//         this.userDetails});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     if (json['cartItem'] != null) {
//       cartItem = <CartItem>[];
//       json['cartItem'].forEach((v) {
//         cartItem!.add(new CartItem.fromJson(v));
//       });
//     }
//     quantity = json['quantity'];
//     price = json['price'];
//     shippingAddress = json['shippingAddress'] != null
//         ? new ShippingAddress.fromJson(json['shippingAddress'])
//         : null;
//     uniqueCode = json['uniqueCode'];
//     modeOfDelivery = json['modeOfDelivery'];
//     status = json['status'];
//     retailer =
//     json['retailer'] != null ? new Retailer.fromJson(json['retailer']) : null;
//     userDetails = json['userDetails'] != null
//         ? new UserDetails.fromJson(json['userDetails'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     if (this.cartItem != null) {
//       data['cartItem'] = this.cartItem!.map((v) => v.toJson()).toList();
//     }
//     data['quantity'] = this.quantity;
//     data['price'] = this.price;
//     if (this.shippingAddress != null) {
//       data['shippingAddress'] = this.shippingAddress!.toJson();
//     }
//     data['uniqueCode'] = this.uniqueCode;
//     data['modeOfDelivery'] = this.modeOfDelivery;
//     data['status'] = this.status;
//     if (this.retailer != null) {
//       data['retailer'] = this.retailer!.toJson();
//     }
//     if (this.userDetails != null) {
//       data['userDetails'] = this.userDetails!.toJson();
//     }
//     return data;
//   }
// }
//
// class CartItem {
//   int? id;
//   ProductVariant? productVariant;
//   int? quantity;
//   double? totalPrice;
//
//   CartItem({this.id, this.productVariant, this.quantity, this.totalPrice});
//
//   CartItem.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     productVariant = json['productVariant'] != null
//         ? new ProductVariant.fromJson(json['productVariant'])
//         : null;
//     quantity = json['quantity'];
//     totalPrice = json['totalPrice'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     if (this.productVariant != null) {
//       data['productVariant'] = this.productVariant!.toJson();
//     }
//     data['quantity'] = this.quantity;
//     data['totalPrice'] = this.totalPrice;
//     return data;
//   }
// }
//
// class ProductVariant {
//   int? id;
//   Product? product;
//   Null? deletedAt;
//   int? createdBy;
//   int? modifiedBy;
//   String? createdAt;
//   String? updatedAt;
//   String? variantShopifyId;
//   String? title;
//   String? price;
//   bool? isTaxable;
//   int? inventoryQuantity;
//
//   ProductVariant(
//       {this.id,
//         this.product,
//         this.deletedAt,
//         this.createdBy,
//         this.modifiedBy,
//         this.createdAt,
//         this.updatedAt,
//         this.variantShopifyId,
//         this.title,
//         this.price,
//         this.isTaxable,
//         this.inventoryQuantity});
//
//   ProductVariant.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     product =
//     json['product'] != null ? new Product.fromJson(json['product']) : null;
//     deletedAt = json['deletedAt'];
//     createdBy = json['createdBy'];
//     modifiedBy = json['modifiedBy'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     variantShopifyId = json['variantShopifyId'];
//     title = json['title'];
//     price = json['price'];
//     isTaxable = json['isTaxable'];
//     inventoryQuantity = json['inventoryQuantity'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     if (this.product != null) {
//       data['product'] = this.product!.toJson();
//     }
//     data['deletedAt'] = this.deletedAt;
//     data['createdBy'] = this.createdBy;
//     data['modifiedBy'] = this.modifiedBy;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['variantShopifyId'] = this.variantShopifyId;
//     data['title'] = this.title;
//     data['price'] = this.price;
//     data['isTaxable'] = this.isTaxable;
//     data['inventoryQuantity'] = this.inventoryQuantity;
//     return data;
//   }
// }
//
// class Product {
//   int? id;
//   List<Category>? category;
//   Null? deletedAt;
//   int? createdBy;
//   int? modifiedBy;
//   String? createdAt;
//   String? updatedAt;
//   String? name;
//   Null? bodyHtml;
//   Null? image;
//   String? code;
//   bool? isFeatured;
//   String? shopifyId;
//   String? shopifyImageUrl;
//   Null? shopifyWebhookResponse;
//
//   Product(
//       {this.id,
//         this.category,
//         this.deletedAt,
//         this.createdBy,
//         this.modifiedBy,
//         this.createdAt,
//         this.updatedAt,
//         this.name,
//         this.bodyHtml,
//         this.image,
//         this.code,
//         this.isFeatured,
//         this.shopifyId,
//         this.shopifyImageUrl,
//         this.shopifyWebhookResponse});
//
//   Product.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     if (json['category'] != null) {
//       category = <Category>[];
//       json['category'].forEach((v) {
//         category!.add(new Category.fromJson(v));
//       });
//     }
//     deletedAt = json['deletedAt'];
//     createdBy = json['createdBy'];
//     modifiedBy = json['modifiedBy'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     name = json['name'];
//     bodyHtml = json['bodyHtml'];
//     image = json['image'];
//     code = json['code'];
//     isFeatured = json['isFeatured'];
//     shopifyId = json['shopifyId'];
//     shopifyImageUrl = json['shopifyImageUrl'];
//     shopifyWebhookResponse = json['shopifyWebhookResponse'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     if (this.category != null) {
//       data['category'] = this.category!.map((v) => v.toJson()).toList();
//     }
//     data['deletedAt'] = this.deletedAt;
//     data['createdBy'] = this.createdBy;
//     data['modifiedBy'] = this.modifiedBy;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['name'] = this.name;
//     data['bodyHtml'] = this.bodyHtml;
//     data['image'] = this.image;
//     data['code'] = this.code;
//     data['isFeatured'] = this.isFeatured;
//     data['shopifyId'] = this.shopifyId;
//     data['shopifyImageUrl'] = this.shopifyImageUrl;
//     data['shopifyWebhookResponse'] = this.shopifyWebhookResponse;
//     return data;
//   }
// }
//
// class Category {
//   int? id;
//   Null? deletedAt;
//   int? createdBy;
//   int? modifiedBy;
//   Null? createdAt;
//   Null? updatedAt;
//   String? name;
//   String? shopifyImageUrl;
//   String? shopifyId;
//   Null? shopifyWebhookResponse;
//   Null? parentCategory;
//
//   Category(
//       {this.id,
//         this.deletedAt,
//         this.createdBy,
//         this.modifiedBy,
//         this.createdAt,
//         this.updatedAt,
//         this.name,
//         this.shopifyImageUrl,
//         this.shopifyId,
//         this.shopifyWebhookResponse,
//         this.parentCategory});
//
//   Category.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     deletedAt = json['deletedAt'];
//     createdBy = json['createdBy'];
//     modifiedBy = json['modifiedBy'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     name = json['name'];
//     shopifyImageUrl = json['shopifyImageUrl'];
//     shopifyId = json['shopifyId'];
//     shopifyWebhookResponse = json['shopifyWebhookResponse'];
//     parentCategory = json['parentCategory'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['deletedAt'] = this.deletedAt;
//     data['createdBy'] = this.createdBy;
//     data['modifiedBy'] = this.modifiedBy;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['name'] = this.name;
//     data['shopifyImageUrl'] = this.shopifyImageUrl;
//     data['shopifyId'] = this.shopifyId;
//     data['shopifyWebhookResponse'] = this.shopifyWebhookResponse;
//     data['parentCategory'] = this.parentCategory;
//     return data;
//   }
// }
//
// class ShippingAddress {
//   int? id;
//   String? name;
//   String? mobile;
//   String? street;
//   String? city;
//   String? pincode;
//   String? state;
//   Retailer? retailer;
//
//   ShippingAddress(
//       {this.id,
//         this.name,
//         this.mobile,
//         this.street,
//         this.city,
//         this.pincode,
//         this.state,
//         this.retailer});
//
//   ShippingAddress.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     mobile = json['mobile'];
//     street = json['street'];
//     city = json['city'];
//     pincode = json['pincode'];
//     state = json['state'];
//     retailer =
//     json['retailer'] != null ? new Retailer.fromJson(json['retailer']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['mobile'] = this.mobile;
//     data['street'] = this.street;
//     data['city'] = this.city;
//     data['pincode'] = this.pincode;
//     data['state'] = this.state;
//     if (this.retailer != null) {
//       data['retailer'] = this.retailer!.toJson();
//     }
//     return data;
//   }
// }
//
// class Retailer {
//   int? id;
//   String? email;
//   String? name;
//   String? primaryNumber;
//   Null? secondaryNumber;
//
//   Retailer(
//       {this.id,
//         this.email,
//         this.name,
//         this.primaryNumber,
//         this.secondaryNumber});
//
//   Retailer.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     email = json['email'];
//     name = json['name'];
//     primaryNumber = json['primaryNumber'];
//     secondaryNumber = json['secondaryNumber'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['email'] = this.email;
//     data['name'] = this.name;
//     data['primaryNumber'] = this.primaryNumber;
//     data['secondaryNumber'] = this.secondaryNumber;
//     return data;
//   }
// }
//
// class UserDetails {
//   int? id;
//   String? email;
//   String? fullName;
//   String? phone;
//
//   UserDetails({this.id, this.email, this.fullName, this.phone});
//
//   UserDetails.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     email = json['email'];
//     fullName = json['fullName'];
//     phone = json['phone'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['email'] = this.email;
//     data['fullName'] = this.fullName;
//     data['phone'] = this.phone;
//     return data;
//   }
// }
//
// class Pagination {
//   int? count;
//   int? currentDataLength;
//   int? totalPages;
//   int? currentPage;
//   Null? next;
//   Null? previous;
//
//   Pagination(
//       {this.count,
//         this.currentDataLength,
//         this.totalPages,
//         this.currentPage,
//         this.next,
//         this.previous});
//
//   Pagination.fromJson(Map<String, dynamic> json) {
//     count = json['count'];
//     currentDataLength = json['currentDataLength'];
//     totalPages = json['totalPages'];
//     currentPage = json['currentPage'];
//     next = json['next'];
//     previous = json['previous'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['count'] = this.count;
//     data['currentDataLength'] = this.currentDataLength;
//     data['totalPages'] = this.totalPages;
//     data['currentPage'] = this.currentPage;
//     data['next'] = this.next;
//     data['previous'] = this.previous;
//     return data;
//   }
// }
