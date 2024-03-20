import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
        BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 10)
      ]),
      padding: EdgeInsets.all(10),
      child: Row(children: [
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    offset: const Offset(0, 0),
                    blurRadius: 8)
              ]),
          child: TextField(
            autofocus: false,
            onSubmitted: (val) {},
            onChanged: (val) {},
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
              hintText: "Search...",
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        )),
        const SizedBox(width: 10),
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.grey.withOpacity(0.6), blurRadius: 8)
              ]),
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.filter_alt_outlined,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 10),
        badges.Badge(
          badgeContent: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 5),
      ]),
    );
  }
}
