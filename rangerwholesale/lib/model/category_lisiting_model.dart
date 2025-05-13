class CategoryListing {
  bool? success;
  String? message;
  List<Data>? data;
  Pagination? pagination;

  CategoryListing({this.success, this.message, this.data, this.pagination});

  CategoryListing.fromJson(Map<String, dynamic> json) {
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
  Null? deletedAt;
  int? createdBy;
  int? modifiedBy;
  Null? createdAt;
  Null? updatedAt;
  String? name;
  String? shopifyId;
  String? shopifyImageUrl;
  Null? parentCategory;

  Data(
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

  Data.fromJson(Map<String, dynamic> json) {
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
