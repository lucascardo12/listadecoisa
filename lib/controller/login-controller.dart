import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:listadecoisa/model/coisas.dart';
import 'package:listadecoisa/services/banco.dart';
import 'package:listadecoisa/services/global.dart';

class LoginController extends GetxController {
  final gb = Get.find<Global>();
  final banco = Get.find<BancoFire>();
  TextEditingController loginControler = TextEditingController();
  TextEditingController senhaControler = TextEditingController();
  bool isVali = false;
  RxBool lObescure = true.obs;

  @override
  void onInit() {
    loginControler.text = gb.box.get('login', defaultValue: "");
    senhaControler.text = gb.box.get('senha', defaultValue: "");
    super.onInit();
  }

  Future<bool> verificarConexao() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: 'Sem Conexão',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 18.0);
      return false;
    }
  }

  showAlertDialog2({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Redefinir a senha do login abaixo"),
          content: TextField(
            controller: loginControler,
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () => Get.back(),
            ),
          ],
        );
      },
    );
  }

  void logar({required BuildContext context}) {
    banco.login(email: loginControler.text, password: senhaControler.text).then((value) async {
      if (value != null) {
        gb.usuario = value;
        List<dynamic> listCat = await banco.getCoisas(user: gb.usuario!);
        gb.lisCoisa = listCat.map((i) => Coisas.fromSnapshot(i)).toList();

        var userCo = jsonEncode(value);
        gb.box.put('user', userCo);
        gb.box.put("fezLogin", true);
        gb.box.put('login', loginControler.text);
        gb.box.put('senha', senhaControler.text);
        gb.box.put('isAnonimo', false);

        gb.isLoading = false;
        Get.offAllNamed('/home');
      }
    });
  }

  void loginAnonimo({required BuildContext context}) {
    banco.criaUserAnonimo().then((value) async {
      gb.usuario = value;
      gb.isLoading = false;

      if (value != null) {
        List<dynamic> listCat = await banco.getCoisas(user: gb.usuario!);
        gb.lisCoisa = listCat.map((i) => Coisas.fromSnapshot(i)).toList();

        var userCo = jsonEncode(value);
        gb.box.put('user', userCo);
        gb.box.put("fezLogin", true);
        gb.box.put('isAnonimo', true);

        Get.offAllNamed('/home');
      }
    });
  }
}
