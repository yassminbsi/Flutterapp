import 'package:flutter/material.dart';
import 'package:flutter_app/admin/view-admin.dart';
import 'package:flutter_app/auth/home_admin.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'package:flutter_app/auth/login_admin.dart';
import 'package:flutter_app/auth/signup_admin.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/role/home.dart';
import 'package:flutter_app/role/login.dart';
import 'package:flutter_app/role/register.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/mapwidget/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:flutter_app/mapwidget/presentation/screens/map_screen.dart';
import 'package:flutter_app/mapwidget/presentation/screens/otp_screen.dart';
import '../auth/Homepage.dart';
import 'business_logic/cubit/maps/maps_cubit.dart';
import 'constnats/strings.dart';
import 'data/repository/maps_repo.dart';
import 'data/webservices/places_webservices.dart';
import 'presentation/screens/login_screen.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;

  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mapScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (BuildContext context) =>
                MapsCubit(MapsRepository(PlacesWebservices())),
            child: MapScreen(),
          ),
        );

      case loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: LoginScreen(),
          ),
        );

      case otpScreen:
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PhoneAuthCubit>.value(
            value: phoneAuthCubit!,
            child: OtpScreen(phoneNumber: phoneNumber),
          ),
        );

        case Login:
        return MaterialPageRoute(
          builder: (_) =>  LoginPage(),
        );

        case Connecter:
        return MaterialPageRoute(
          builder: (_) =>  LoginAdmin(),
        );

        case bus:
        return MaterialPageRoute(
          builder: (_) =>  DashboardScreen(),
        );
    

         case  Inscrire:
        return MaterialPageRoute(
          builder: (_) =>  signupAdmin(),
        );
       
        
        
         case  Initial:
        return MaterialPageRoute(
          builder: (_) =>  Register(),
        );
        

        case  loginuser:
        return MaterialPageRoute(
          builder: (_) =>  LoginUser(),
        );
         case  homeuser:
        return MaterialPageRoute(
          builder: (_) =>  HomeUser(),
        );
    }
  }
}



