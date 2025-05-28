import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<String> images = [
    'https://www.w3schools.com/w3images/lights.jpg',
    'https://www.w3schools.com/w3images/mountains.jpg',
    'https://www.w3schools.com/w3images/forest.jpg',
  ];
  String name = "";

  void getData()async{
    SharedPreferences preferences =await SharedPreferences.getInstance();
   setState(() {
     name = preferences.getString("username")!;
   });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Hello : "+name),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/icon.jpg'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.camera_alt, size: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("Home"),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text("Cart"),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {

              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 150,
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
            ),
            items: images.map((imageUrl) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ));
  }
}
