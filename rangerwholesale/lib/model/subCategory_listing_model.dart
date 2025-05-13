class SubCategoryListing {
  bool? success;
  String? message;
  List<SubcategoryData>? data;
  Pagination? pagination;

  SubCategoryListing({this.success, this.message, this.data, this.pagination});

  SubCategoryListing.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SubcategoryData>[];
      json['data'].forEach((v) {
        data!.add(new SubcategoryData.fromJson(v));
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

class SubcategoryData {
  int? id;
  Category? category;
  Null? deletedAt;
  int? createdBy;
  int? modifiedBy;
  String? createdAt;
  String? updatedAt;
  String? name;
  Null? image;
  Null? parent;

  SubcategoryData(
      {this.id,
        this.category,
        this.deletedAt,
        this.createdBy,
        this.modifiedBy,
        this.createdAt,
        this.updatedAt,
        this.name,
        this.image,
        this.parent});

  SubcategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    deletedAt = json['deletedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    name = json['name'];
    image = json['image'];
    parent = json['parent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['deletedAt'] = this.deletedAt;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['name'] = this.name;
    data['image'] = this.image;
    data['parent'] = this.parent;
    return data;
  }
}

class Category {
  int? id;
  Null? deletedAt;
  int? createdBy;
  int? modifiedBy;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? image;

  Category(
      {this.id,
        this.deletedAt,
        this.createdBy,
        this.modifiedBy,
        this.createdAt,
        this.updatedAt,
        this.name,
        this.image});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deletedAt = json['deletedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    name = json['name'];
    image = json['image'];
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
    data['image'] = this.image;
    return data;
  }
}

class Pagination {
  int? count;
  int? totalPages;
  int? currentPage;
  Null? next;
  Null? previous;

  Pagination(
      {this.count,
        this.totalPages,
        this.currentPage,
        this.next,
        this.previous});

  Pagination.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
    next = json['next'];
    previous = json['previous'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['totalPages'] = this.totalPages;
    data['currentPage'] = this.currentPage;
    data['next'] = this.next;
    data['previous'] = this.previous;
    return data;
  }
}