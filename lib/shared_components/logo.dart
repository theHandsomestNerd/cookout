import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key, this.disableLink}) : super(key: key);

  final bool? disableLink;
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 100,child: InkWell(onTap:
        (){
      if(disableLink != true) {
              GoRouter.of(context).go('/home');
            }

            // Navigator.pushNamed(context, '/home',);
    },child:Image.asset('assets/logo-w.png')),);
  }
}
