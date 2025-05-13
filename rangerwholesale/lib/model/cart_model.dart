class CartModel {
  bool? success;
  String? message;
  List<Data>? data;
  Pagination? pagination;

  CartModel({this.success, this.message, this.data, this.pagination});

  CartModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  ProductVariant? productVariant;
  int? quantity;
  double? totalPrice;

  Data({this.id, this.productVariant, this.quantity, this.totalPrice});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productVariant = json['productVariant'] != null
        ? new ProductVariant.fromJson(json['productVariant'])
        : null;
    quantity = json['quantity'];
    totalPrice = json['totalPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.productVariant != null) {
      data['productVariant'] = this.productVariant!.toJson();
    }
    data['quantity'] = this.quantity;
    data['totalPrice'] = this.totalPrice;
    return data;
  }
}

class ProductVariant {
  int? id;
  Product? product;
  Null? deletedAt;
  int? createdBy;
  int? modifiedBy;
  String? createdAt;
  String? updatedAt;
  String? variantShopifyId;
  String? title;
  String? price;
  bool? isTaxable;
  int? inventoryQuantity;

  ProductVariant(
      {this.id,
        this.product,
        this.deletedAt,
        this.createdBy,
        this.modifiedBy,
        this.createdAt,
        this.updatedAt,
        this.variantShopifyId,
        this.title,
        this.price,
        this.isTaxable,
        this.inventoryQuantity});

  ProductVariant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
    deletedAt = json['deletedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    variantShopifyId = json['variantShopifyId'];
    title = json['title'];
    price = json['price'];
    isTaxable = json['isTaxable'];
    inventoryQuantity = json['inventoryQuantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    data['deletedAt'] = this.deletedAt;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['variantShopifyId'] = this.variantShopifyId;
    data['title'] = this.title;
    data['price'] = this.price;
    data['isTaxable'] = this.isTaxable;
    data['inventoryQuantity'] = this.inventoryQuantity;
    return data;
  }
}

class Product {
  int? id;
  List<Category>? category;
  Null? deletedAt;
  int? createdBy;
  int? modifiedBy;
  String? createdAt;
  String? updatedAt;
  String? name;
  Null? bodyHtml;
  Null? image;
  String? code;
  bool? isFeatured;
  String? shopifyId;
  String? shopifyImageUrl;
  Null? shopifyWebhookResponse;

  Product(
      {this.id,
        this.category,
        this.deletedAt,
        this.createdBy,
        this.modifiedBy,
        this.createdAt,
        this.updatedAt,
        this.name,
        this.bodyHtml,
        this.image,
        this.code,
        this.isFeatured,
        this.shopifyId,
        this.shopifyImageUrl,
        this.shopifyWebhookResponse});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(new Category.fromJson(v));
      });
    }
    deletedAt = json['deletedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    name = json['name'];
    bodyHtml = json['bodyHtml'];
    image = json['image'];
    code = json['code'];
    isFeatured = json['isFeatured'];
    shopifyId = json['shopifyId'];
    shopifyImageUrl = json['shopifyImageUrl'];
    shopifyWebhookResponse = json['shopifyWebhookResponse'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    data['deletedAt'] = this.deletedAt;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['name'] = this.name;
    data['bodyHtml'] = this.bodyHtml;
    data['image'] = this.image;
    data['code'] = this.code;
    data['isFeatured'] = this.isFeatured;
    data['shopifyId'] = this.shopifyId;
    data['shopifyImageUrl'] = this.shopifyImageUrl;
    data['shopifyWebhookResponse'] = this.shopifyWebhookResponse;
    return data;
  }
}

class Category {
  int? id;
  Null? deletedAt;
  int? createdBy;
  int? modifiedBy;
  Null? createdAt;
  String? updatedAt;
  String? name;
  String? shopifyId;
  String? shopifyImageUrl;
  Null? parentCategory;

  Category(
      {this.id,
        this.deletedAt,
        this.createdBy,
        this.modifiedBy,
        this.createdAt,
        this.updatedAt,
        this.name,
        this.shopifyId,
        this.shopifyImageUrl,
        this.parentCategory});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deletedAt = json['deletedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    name = json['name'];
    shopifyId = json['shopifyId'];
    shopifyImageUrl = json['shopifyImageUrl'];
    parentCategory = json['parentCategory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['deletedAt'] = this.deletedAt;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['name'] = this.name;
    data['shopifyId'] = this.shopifyId;
    data['shopifyImageUrl'] = this.shopifyImageUrl;
    data['parentCategory'] = this.parentCategory;
    return data;
  }
}

class Pagination {
  int? count;
  int? currentDataLength;
  int? totalPages;
  int? currentPage;
  String? next;
  String? previous;

  Pagination(
      {this.count,
        this.currentDataLength,
        this.totalPages,
        this.currentPage,
        this.next,
        this.previous});

  Pagination.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    currentDataLength = json['currentDataLength'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
    next = json['next'];
    previous = json['previous'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['currentDataLength'] = this.currentDataLength;
    data['totalPages'] = this.totalPages;
    data['currentPage'] = this.currentPage;
    data['next'] = this.next;
    data['previous'] = this.previous;
    return data;
  }
}
