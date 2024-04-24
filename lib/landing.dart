import 'package:flutter/material.dart';
import 'widgets/navbar.dart';
import 'utils/responsiveLayout.dart';
import 'widgets/search.dart';

class Landing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MyEndDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFA5D6A7),
              Color(0xFF388E3C),
            ]
          )
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              NavBar(),
              Body(),
            ],
          ),
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      key: UniqueKey(), // Provide a unique key
      largeScreen: LargeChild(),
      mediumScreen: MediumChild(),
      smallScreen: SmallChild(),
    );
  }
}

abstract class ScreenChild extends StatelessWidget {
  @override
  Widget build(BuildContext context);
}

class LargeChild extends ScreenChild {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor:.6,
            child: Image.asset("assets/images/cartoon.png", scale:.85),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor:.6,
            child: Padding(
              padding: EdgeInsets.only(left: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "We Create creative Mind!",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat-Regular",
                      color: Color(0xFF111111),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "and Disciplined genarations ",
                      style: TextStyle(
                        fontSize: 60,
                        color: Color(0xFF1B5E20),
                      ),
                      children: [
                        TextSpan(
                          text: "🐱",
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 20),
                    child: Text("LET'S LEARN TOGETHER"),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Search(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MediumChild extends ScreenChild {
  @override
  Widget build(BuildContext context) {
   // Placeholder widget for medium-sized screens
    return Container();
  }
}

class SmallChild extends ScreenChild {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "We Create creative Mind!",
              style: TextStyle(
                fontSize: 35,
               fontWeight: FontWeight.bold,
                fontFamily: "Montserrat-Regular",
                color: Color(0xFF111111),
              ),
            ),
            RichText(
              text: TextSpan(
                text: "and Disciplined Genarations ",
                style: TextStyle(
                  fontSize: 25,
                  color: Color(0xFF455A64),
                ),
                children: [
                  TextSpan(
                    text: "👨‍🎓",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 20),
              child: Text("LET'S LEARN TOGETHER"),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Image.asset("assets/images/cartoon.png", scale: 1),
            ),
            SizedBox(
              height: 32,
            ),
            Search(),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class MyEndDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/bgdrawer.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                SizedBox(height: 16),
                Text(
                  'Daniel kebede',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'dkklearningservice.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Materials'),
            leading: const Icon(Icons.book),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/material');
            },
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
           ListTile(
            title: const Text('Courses'),
            leading: const Icon(Icons.login),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/course');
            },
          ),
          ListTile(
            title: const Text('Login'),
            leading: const Icon(Icons.login),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
