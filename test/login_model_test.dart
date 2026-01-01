import 'package:flutter_test/flutter_test.dart';
import 'package:kasirmadura/data/models/login_request.dart';
import 'package:kasirmadura/data/models/login_response.dart';

void main() {

  test("LoginRequest toJson() works", () {

    final req = LoginRequest(
      username: "kasir",
      password: "123",
    );

    final result = req.toJson();

    expect(result['username'], "kasir");
    expect(result['password'], "123");
  });


  test("LoginResponse fromJson() works", () {

    final json = {
      "token": "abc",
      "role": "KASIR",
      "message": "Login berhasil",
      "tokoId": 7
    };

    final res = LoginResponse.fromJson(json);

    expect(res.token, "abc");
    expect(res.role, "KASIR");
    expect(res.message, "Login berhasil");
    expect(res.tokoId, 7);
  });

}
