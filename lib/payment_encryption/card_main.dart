import 'dart:io';
import 'package:e_shop/Orders/placeOrderPayment.dart';
import 'package:e_shop/payment_encryption/encryption%20main.dart';
import 'package:e_shop/payment_encryption/input_formatters.dart';
import 'package:e_shop/payment_encryption/my_strings.dart';
import 'package:e_shop/payment_encryption/payment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class MyCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      home: new MyHomePage(title: Strings.appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidate = false;

  var _card = new PaymentCard();

  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
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
          title: Text("Card Details",style: TextStyle(color: Colors.white,fontSize: 45.0,fontFamily: "Signatra"),),
        ),
        body: new Container(
          decoration: BoxDecoration(
            image: DecorationImage(

              fit: BoxFit.cover,
              colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.1),
                  BlendMode.dstATop),
              image: AssetImage('images/bg.jpg'),

            ),
              gradient: LinearGradient(
                  colors: [ Colors.white70,Colors.white ],
                 // begin: const FractionalOffset(0.0,0.0),
                 // end: const FractionalOffset(1.0,0.0),
                 // stops: [0.0,1.0],
                  tileMode: TileMode.clamp
              )
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: new Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: new ListView(
                children: <Widget>[
                  new SizedBox(
                    height: 20.0,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: const Icon(
                        Icons.person,
                        size: 40.0,
                      ),
                      hintText: 'What name is written on card?',

                      labelText: 'Card Name',
                    ),
                    onSaved: (String value) {
                      _card.name = value;
                    },
                    keyboardType: TextInputType.text,
                    validator: (String value) =>
                    value.isEmpty ? Strings.fieldReq : null,
                  ),
                  new SizedBox(
                    height: 20.0,
                  ),
                  new TextFormField(
                    keyboardType: TextInputType.number,
                   /* inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(19),
                      new CardNumberInputFormatter(),

                    ],*/
                    //controller: numberController,
                    decoration: new InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon:Icon(Icons.credit_card,size: 40.0,),
                      hintText: 'Paste Here Your Encrypted Card Number ',
                      labelText: 'Encrypted Card Number',
                    ),
                    /*onSaved: (String value) {
                      print('onSaved = $value');
                      print('Num controller has = ${numberController.text}');
                      _paymentCard.number = CardUtils.getCleanedNumber(value);
                    },*/
                  //  validator: CardUtils.validateCardNum,
                  ),
                  new SizedBox(
                    height: 20.0,
                  ),
                  new TextFormField(
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: new InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: new Image.asset(
                        'assets/images/card_cvv.png',
                        width: 40.0,
                        color: Colors.grey[600],
                      ),
                      hintText: 'Number behind the card',
                      labelText: 'CVV',
                    ),
                    validator: CardUtils.validateCVV,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _paymentCard.cvv = int.parse(value);
                    },
                  ),
                  new SizedBox(
                    height: 20.0,
                  ),
                  new TextFormField(
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(4),
                      new CardMonthInputFormatter()
                    ],
                    decoration: new InputDecoration(
                      border: const UnderlineInputBorder(),
                      filled: true,
                      icon: new Image.asset(
                        'assets/images/calender.png',
                        width: 40.0,
                        color: Colors.grey[600],
                      ),
                      hintText: 'MM/YY',
                      labelText: 'Expiry Date',
                    ),
                    validator: CardUtils.validateDate,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      List<int> expiryDate = CardUtils.getExpiryDate(value);
                      _paymentCard.month = expiryDate[0];
                      _paymentCard.year = expiryDate[1];
                    },
                  ),
                  new SizedBox(
                    height: 40.0,
                  ),

                  new Container(
                    alignment: Alignment.center,
                    child: _getPayButton(),
                  )
                ],
              )),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true; // Start validating on every change.
      });
      _showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway
      _showInSnackBar('Payment card is valid');
    //  Navigator.push(context, MaterialPageRoute(builder: (contetx)=>PaymentPage()));
    }
  }

  Widget _getPayButton() {
    if (Platform.isIOS) {
      return new CupertinoButton(
        onPressed: _validateInputs,
        color: CupertinoColors.activeBlue,
        child: const Text(
          Strings.pay,
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    } else {
      return new RaisedButton(
        onPressed: _validateInputs,
        color: Colors.deepOrangeAccent,
        splashColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(100.0)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
        textColor: Colors.white,
        child: new Text(
          Strings.pay.toUpperCase(),
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: new Duration(seconds: 3),
    ));
  }
}
