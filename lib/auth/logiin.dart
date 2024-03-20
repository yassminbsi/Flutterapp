import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_app/auth/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:  Color.fromARGB(255, 30, 30, 49),
      body: Stack(children: [
        Obx(() => authController.isOtpSent.value
            ? _buildVerifyOtpForm()
            : _buildGetOtpForm())
      ]),
    );
  }

  Widget _buildGetOtpForm() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
           Text(
            "TRACK MY ROUTE",
            style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 216, 216, 216)),
          ),
          Image.asset(
            "images/309.png",
            width: 300,
          ),
                              
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                     
                    ),
                    child: Obx(() => Column(
                          children: [
                          TextFormField(
  keyboardType: TextInputType.number,
  maxLength: 8,
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  onChanged: (val) {
    authController.phoneNo.value = val;
    authController.showPrefix.value = val.length > 0;
  },
  onSaved: (val) => authController.phoneNo.value = val!,
  validator: (val) => (val!.isEmpty || val!.length < 8) ? "Enter valid number" : null,
  decoration: InputDecoration(
    border: OutlineInputBorder(),
                                
                                labelText: ' Enter Your Number',
   
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: TextStyle(
                                  color:Colors.grey,// Set the color of the label text
                                ),
    contentPadding: EdgeInsets.symmetric(vertical: 8), 
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color:Colors.grey,),
      borderRadius: BorderRadius.circular(10), 
    ),
      
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFFCA20)),
      borderRadius: BorderRadius.circular(5), 
    ),
    prefix: authController.showPrefix.value
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '(+216)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : null,
    suffixIcon: _buildSuffixIcon(),
  ),
)
,
                            SizedBox(
                              height: 22,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final form = _formKey.currentState;
                                  if (form!.validate()) {
                                    form.save();
                                    authController.getOtp();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  
                                  backgroundColor:   Color.fromARGB(255, 30, 30, 49),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                      color:Colors.grey,
                                       
                                    ),
                                    
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Text(
                                    'TRACK YOUR BUS',
                                    style: TextStyle(fontSize: 16,color:Colors.grey,),
                                  ),
                                ),
                              ),
                            ),
                           
                            SizedBox(
                              width: double.infinity,
                              child: MaterialButton(
                                onPressed: () {
                                  Get.toNamed("/loginAdmin");
                                },
                                
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'S\'inscrire  ? ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color:Colors.grey,),
                                        ),
                                        TextSpan(
                                          text: 'se connecter',
                                          style: TextStyle(
                                              fontSize: 14, color: Color(0xFFFFCA20)),
                                        ),
                                      ],
                                    ),
                                  ),
          
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyOtpForm() {
    List<TextEditingController> otpFieldsControler = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController()
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  authController.isOtpSent.value = false;
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(
              height: 180,
            ),
            Text(
              'Verification',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Enter your OTP code number",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 28,
            ),
            Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _textFieldOTP(
                          first: true,
                          last: false,
                          controller: otpFieldsControler[0]),
                      _textFieldOTP(
                          first: false,
                          last: false,
                          controller: otpFieldsControler[1]),
                      _textFieldOTP(
                          first: false,
                          last: false,
                          controller: otpFieldsControler[2]),
                      _textFieldOTP(
                          first: false,
                          last: false,
                          controller: otpFieldsControler[3]),
                      _textFieldOTP(
                          first: false,
                          last: false,
                          controller: otpFieldsControler[4]),
                      _textFieldOTP(
                          first: false,
                          last: true,
                          controller: otpFieldsControler[5]),
                    ],
                  ),
                  Text(
                    authController.statusMessage.value,
                    style: TextStyle(
                        color: authController.statusMessageColor.value,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        authController.otp.value = "";
                        otpFieldsControler.forEach((controller) {
                          authController.otp.value += controller.text;
                        });
                        authController.verifyOTP();
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey),
                        // backgroundColor:
                        //     MaterialStateProperty.all<Color>(kPrimaryColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text(
                          'Verify',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "Didn't receive any code?",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 18,
            ),
            Obx(
              () => TextButton(
                onPressed: () => authController.resendOTP.value
                    ? authController.resendOtp()
                    : null,
                child: Text(
                  authController.resendOTP.value
                      ? "Resend New Code"
                      : "Wait ${authController.resendAfter} seconds",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
             Image.asset(
              "images/309.png",
              width: 100,
            ),
          ],
         
        ),
      ),
    );
  }

  Widget _buildSuffixIcon() {
    return AnimatedOpacity(
        opacity: authController.phoneNo?.value.length == 10 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Icon(Icons.check_circle, color: Colors.green, size: 32));
  }

  Widget _textFieldOTP({bool first = true, last, controller}) {
    var height = (Get.width - 82) / 6;
    return Container(
      height: height,
      child: AspectRatio(
        aspectRatio: 1,
        child: TextField(
          autofocus: true,
          controller: controller,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              Get.focusScope?.nextFocus();
            }
            if (value.length == 0 && first == false) {
              Get.focusScope?.previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: height / 2, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.black12),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.purple),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
       
      ),
    );
  }
}
