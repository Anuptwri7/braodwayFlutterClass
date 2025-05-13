import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rangerwholesale/tabPages/product_page.dart';
import '../const/styleConst.dart';
import '../provider/subcategory_provider.dart';

class SubCategories extends StatefulWidget {
  final int? id;

  const SubCategories({Key? key, required this.id}) : super(key: key);

  @override
  State<SubCategories> createState() => _SubCategoriesState();
}

class _SubCategoriesState extends State<SubCategories> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SubcategoryProvider>(context, listen: false)
            .fetchSubcategories(widget.id!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subcategoryProvider = Provider.of<SubcategoryProvider>(context);
    final subcategories = subcategoryProvider.subcategories ?? [];

    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
                bottomRight: Radius.circular(40.0),
                bottomLeft: Radius.circular(40.0),
              ),
              color: AppColors.mainAppColor,
            ),
            height: 200.0,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 35.0,
                  left: 15.0,
                  right: 15.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 25),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Sub Categories",
                            style: TextStyle(
                              fontFamily: "poppins",
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.search_outlined,
                                color: Colors.white, size: 25),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications,
                                color: Colors.white, size: 25),
                            onPressed: () {
                              // Implement notification logic here
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 20.0,
                  right: 20.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 10,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Image.asset("assets/icons/setting.png"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Sub Categories",
                    style: TextStyle(
                      fontFamily: "poppins",
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                Text("See All",
                    style: TextStyle(
                      fontFamily: "poppins",
                      color: AppColors.mainAppColor,
                      fontSize: 16,
                    )),
              ],
            ),
          ),
          Expanded(
            child: subcategoryProvider.isLoading
                ? Center(child: LoadingAnimationWidget.threeArchedCircle(
                color: AppColors.mainAppColor,
                size: 40,
              ),)
                : subcategoryProvider.errorMessage != null
                ? Center(child: Text(subcategoryProvider.errorMessage!))
                : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = subcategories[index];
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         ProductPage(id: subcategory.id),
                    //   ),
                    // );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: subcategory.image != null
                              ? Image.network(
                            subcategory.image!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              subcategory.name ?? "No name",
                              style: const TextStyle(
                                fontFamily: "poppins",
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
