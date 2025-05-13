class ProfileModel {
  bool? success;
  String? message;
  Data? data;

  ProfileModel({this.success, this.message, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
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
  String? email;
  String? userType;
  bool? isActive;
  UserProfile? userProfile;
  Retailer? retailer;

  Data(
      {this.id,
        this.email,
        this.userType,
        this.isActive,
        this.userProfile,
        this.retailer});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    userType = json['userType'];
    isActive = json['isActive'];
    userProfile = json['userProfile'] != null
        ? new UserProfile.fromJson(json['userProfile'])
        : null;
    retailer =
    json['retailer'] != null ? new Retailer.fromJson(json['retailer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['userType'] = this.userType;
    data['isActive'] = this.isActive;
    if (this.userProfile != null) {
      data['userProfile'] = this.userProfile!.toJson();
    }
    if (this.retailer != null) {
      data['retailer'] = this.retailer!.toJson();
    }
    return data;
  }
}

class UserProfile {
  String? fullName;
  String? phone;
  String? image;

  UserProfile({this.fullName, this.phone, this.image});

  UserProfile.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    phone = json['phone'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = this.fullName;
    data['phone'] = this.phone;
    data['image'] = this.image;
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
