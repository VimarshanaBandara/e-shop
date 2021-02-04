import 'package:clipboard/clipboard.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/payment_encryption/card_main.dart';
import 'package:e_shop/payment_encryption/input_formatters.dart';
import 'package:e_shop/payment_encryption/payment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;


import 'my_encryption.dart';
class EncryptHome extends StatefulWidget {
  @override
  _EncryptHomeState createState() => _EncryptHomeState();
}

class _EncryptHomeState extends State<EncryptHome> {
  var _paymentCard = PaymentCard();

  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    tec.addListener(_getCardTypeFrmNumber);

  }

  TextEditingController tec = TextEditingController();
  TextEditingController pasteController = TextEditingController();
  String paste = '';
  var encryptedText, plainText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.pink , Colors.lightGreenAccent],
                  begin: const FractionalOffset(0.0,0.0),
                  end: const FractionalOffset(1.0,0.0),
                  stops: [0.0,1.0],
                  tileMode: TileMode.clamp
              )
          ),
        ),
        centerTitle: true,
        title: Text("Card Security",style: TextStyle(color: Colors.white,fontSize: 45.0,fontFamily: "Signatra"),),
      ),
      body: SingleChildScrollView(
        child:  Center(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: tec,
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                    new LengthLimitingTextInputFormatter(19),
                    new CardNumberInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Input Card Number Again',
                    filled: true,
                    icon: CardUtils.getCardIcon(_paymentCard.type,),

                  ),
                  onSaved: (String value) {
                    print('onSaved = $value');
                    print('Num controller has = ${tec.text}');
                    _paymentCard.number = CardUtils.getCleanedNumber(value);
                  },
                  validator: CardUtils.validateCardNum,
                ),
              ),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          plainText = tec.text;
                          setState(() {
                            encryptedText =
                                MyEncryptionDecryption.encryptFernet(plainText);
                          });
                          tec.clear();
                        },
                        child: Text("Encrypt"),
                      ),
                      SizedBox(width: 15,),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            encryptedText =
                                MyEncryptionDecryption.decryptFernet(encryptedText);
                            print("Type: " + encryptedText.runtimeType.toString());
                          });
                        },
                        child: Text("Decrypt"),
                      )
                    ],
                  ),

                  SizedBox(height: 15.0),
                  Text(
                    "ENCRYPTED CARD NUMBER",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    color: Colors.white10,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(encryptedText == null
                            ? ""
                            : encryptedText is encrypt.Encrypted
                            ? encryptedText.base64
                            : encryptedText),

                        SizedBox(height: 15.0,),
                        RaisedButton(
                          onPressed: () async{
                            await FlutterClipboard.copy(encryptedText.base64);
                            },
                          child: Row(
                            children: [
                              Icon(Icons.content_copy),
                              SizedBox(width: 10.0,),
                              Text('Copy the encrypted card number')
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.0,),
              RaisedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyCardApp()));
                },
                child: Text('Pay'),
                color: Colors.blue,
              )
            ],
          ),
        ),
      )
    );
  }
  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(tec.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }
}
