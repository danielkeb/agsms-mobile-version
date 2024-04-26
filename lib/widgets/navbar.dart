import 'package:flutter/material.dart';
import '../utils/responsiveLayout.dart';

class NavBar extends StatelessWidget {
  // Navigation Bar Items
  final navLinks = ["Materials", "About", "Login"];

  List<Widget> navItem() {
    return navLinks.map((text) {
      return Padding(
        padding: EdgeInsets.only(left: 18),
        child: Text(text, style: TextStyle(fontFamily: "Montserrat-Bold")),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 45, vertical: 38),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFA5D6A7),
                        Color(0xFF388E3C),
                      ],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "🏫",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Text("Welcome to ABG", style: TextStyle(fontSize: 20))
              ],
            ),
          ),
          // Responsive Layout
          if (!ResponsiveLayout.isSmallScreen(context))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ...navItem(),
                InkWell(
                  onTap: () {
                    // Handle login tap
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFC86DD7),
                          Color(0xFF00A895),
                        ],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6078ea).withOpacity(.3),
                          offset: Offset(0, 8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 1,
                          fontFamily: "Montserrat-Bold",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
        ],
      ),
    );
  }
}
