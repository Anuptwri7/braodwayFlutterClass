class AddressModel {
  bool? success;
  String? message;
  List<Data>? data;
  Pagination? pagination;

  AddressModel({this.success, this.message, this.data, this.pagination});

  AddressModel.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? mobile;
  String? street;
  String? city;
  String? pincode;
  String? province;
  String? state;
  Retailer? retailer;

  Data(
      {this.id,
        this.name,
        this.mobile,
        this.street,
        this.city,
        this.pincode,
        this.province,
        this.state,
        this.retailer});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    street = json['street'];
    city = json['city'];
    pincode = json['pincode'];
    province = json['province'];
    state = json['state'];
    retailer =
    json['retailer'] != null ? new Retailer.fromJson(json['retailer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['street'] = this.street;
    data['city'] = this.city;
    data['pincode'] = this.pincode;
    data['province'] = this.province;
    data['state'] = this.state;
    if (this.retailer != null) {
      data['retailer'] = this.retailer!.toJson();
    }
    return data;
  }
}

class Retailer {
  int? id;
  String? email;
  String? name;
  String? primaryNumber;
  String? secondaryNumber;

  Retailer(
      {this.id,
        this.email,
        this.name,
        this.primaryNumber,
        this.secondaryNumber});

  Retailer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    primaryNumber = json['primaryNumber'];
    secondaryNumber = json['secondaryNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['name'] = this.name;
    data['primaryNumber'] = this.primaryNumber;
    data['secondaryNumber'] = this.secondaryNumber;
    return data;
  }
}

class Pagination {
  int? count;
  int? currentDataLength;
  int? totalPages;
  int? currentPage;
  String? next;
  Null? previous;

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
