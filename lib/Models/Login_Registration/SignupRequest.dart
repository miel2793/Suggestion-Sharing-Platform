class SingupRequest {
  String? name;
  String? userId;
  String? email;
  String? password;
  String? dept;
  String? intake;
  String? section;

  SingupRequest(
      {this.name,
        this.userId,
        this.email,
        this.password,
        this.dept,
        this.intake,
        this.section});

  SingupRequest.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    userId = json['user_id'];
    email = json['email'];
    password = json['password'];
    dept = json['dept'];
    intake = json['intake'];
    section = json['section'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['user_id'] = this.userId;
    data['email'] = this.email;
    data['password'] = this.password;
    data['dept'] = this.dept;
    data['intake'] = this.intake;
    data['section'] = this.section;
    return data;
  }
}
