class ScanProductListing {
  bool? success;
  String? message;
  Data? data;

  ScanProductListing({this.success, this.message, this.data});

  ScanProductListing.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  List<Category>? category;
  List<ProductVariants>? productVariants;
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

  Data(
      {this.id,
        this.category,
        this.productVariants,
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

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(new Category.fromJson(v));
      });
    }
    if (json['productVariants'] != null) {
      productVariants = <ProductVariants>[];
      json['productVariants'].forEach((v) {
        productVariants!.add(new ProductVariants.fromJson(v));
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
    if (this.productVariants != null) {
      data['productVariants'] =
          this.productVariants!.map((v) => v.toJson()).toList();
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
  Null? updatedAt;
  String? name;
  String? shopifyImageUrl;
  String? shopifyId;
  Null? shopifyWebhookResponse;
  Null? parentCategory;

  Category(
      {this.id,
        this.deletedAt,
        this.createdBy,
        this.modifiedBy,
        this.createdAt,
        this.updatedAt,
        this.name,
        this.shopifyImageUrl,
        this.shopifyId,
        this.shopifyWebhookResponse,
        this.parentCategory});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deletedAt = json['deletedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    name = json['name'];
    shopifyImageUrl = json['shopifyImageUrl'];
    shopifyId = json['shopifyId'];
    shopifyWebhookResponse = json['shopifyWebhookResponse'];
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
    data['shopifyImageUrl'] = this.shopifyImageUrl;
    data['shopifyId'] = this.shopifyId;
    data['shopifyWebhookResponse'] = this.shopifyWebhookResponse;
    data['parentCategory'] = this.parentCategory;
    return data;
  }
}

class ProductVariants {
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

  ProductVariants(
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

  ProductVariants.fromJson(Map<String, dynamic> json) {
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
