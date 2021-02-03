import 'package:credit_card/credit_card_form.dart';
import 'package:credit_card/credit_card_model.dart';
import 'package:credit_card/credit_card_widget.dart';
import 'package:e_shop/Orders/placeOrderPayment.dart';
import 'package:flutter/material.dart';

class CardHomePage extends StatefulWidget {
  @override
  _CardHomePageState createState() => _CardHomePageState();
}

class _CardHomePageState extends State<CardHomePage> {

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName ='';
  String cvvCode = '';
  bool isCvvFocused =false;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child:Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.yellow, Colors.pinkAccent],
                    begin: const FractionalOffset(0.0,0.0),
                    end: const FractionalOffset(1.0,0.0),
                    stops: [0.0,1.0],
                    tileMode: TileMode.clamp
                )
            ),
            child: Column(
              children: [
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  height: 200.0,
                  width:MediaQuery.of(context).size.width,
                  animationDuration: Duration(milliseconds: 1000),
                ),
                RaisedButton(
                  child: Text('Proceed to Pay',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18.0),),
                  onPressed: () {
                    Route route = MaterialPageRoute(builder: (_) => PaymentPage());
                    Navigator.pushReplacement(context, route);
                    final snackBar = SnackBar(content: Text('Your Payment is Success'));
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: Colors.amber,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: CreditCardForm(
                      onCreditCardModelChange: onModelChange ,
                      textColor: Colors.white,
                      cursorColor: Colors.white,
                      themeColor: Colors.white,

                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );

  }
  void onModelChange(CreditCardModel model)
  {
    setState(() {
      cardNumber = model.cardNumber;
      expiryDate = model.expiryDate;
      cardHolderName = model.cardHolderName;
      cvvCode = model.cvvCode;
      isCvvFocused = model.isCvvFocused;
    });
  }


}


