import 'package:amazon_app/model/order_request_model.dart';
import 'package:amazon_app/model/product_model.dart';
import 'package:amazon_app/model/user_details_model.dart';
import 'package:amazon_app/providers/user_detalis_provider.dart';
import 'package:amazon_app/screens/sell_screen.dart';
import 'package:amazon_app/utils/color_theme.dart';
import 'package:amazon_app/utils/constant.dart';
import 'package:amazon_app/utils/utils.dart';
import 'package:amazon_app/widgets/account_screen_app_bar.dart';
import 'package:amazon_app/widgets/custom_main_button.dart';
import 'package:amazon_app/widgets/products_showcase_list_view.dart';
import 'package:amazon_app/widgets/simple_product_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = Utils().getScreenSize(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AccountScreenAppBar(),
        body: SingleChildScrollView(
          child: SizedBox(
            height: screenSize.height,
            width: screenSize.width,
            child: Column(
              children: [
                const IntroductionWidgetAccountScreen(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomMainButton(
                      color: Colors.orange,
                      isLoading: false,
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text(
                        "Sign Out",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomMainButton(
                      color: yellowColor,
                      isLoading: false,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SellScreen()));
                      },
                      child: const Text(
                        "Sell",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
                Expanded(
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection("orders")
                          .get(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else {
                          List<Widget> children = [];
                          try {
                            for (int i = 0;
                            i < snapshot.data!.docs.length;
                            i++) {
                              ProductModel model =
                              ProductModel.getModelFromJson(
                                  json: snapshot.data!.docs[i].data());

                              children.add(
                                  SimpleProductWidget(productModel: model));
                            }
                          } catch (e) {
                            print(e.toString());
                          }
                          return ProductShowcaseListView(
                              title: "Your Orders", children: children);
                        }
                      }),
                ),
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Order Requests",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                ),
                Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection("ordersRequests")
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              OrderRequestModel model =
                              OrderRequestModel.getModelFromJson(
                                  json: snapshot.data!.docs[index].data());
                              return ListTile(
                                title: Text(
                                  "Order: ${model.orderName}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                    'Address:${model.buyersAddress}'),
                                trailing: IconButton(
                                  onPressed: () async {
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(FirebaseAuth
                                        .instance.currentUser!.uid)
                                        .collection("orderRequest")
                                        .doc(snapshot.data!.docs[index].id)
                                        .delete();
                                  },
                                  icon: const Icon(Icons.check),
                                ),
                              );
                            },);
                        }

                      },
                    ))
              ],
            ),
          ),
        ));
  }
}

class IntroductionWidgetAccountScreen extends StatelessWidget {
  const IntroductionWidgetAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserDetailsModel userDetailsModel =
        Provider
            .of<UserDetailsProvider>(context)
            .userDetails;
    return Container(
      height: kAppBarHeight / 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: backgroundGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Container(
        height: kAppBarHeight / 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.000000000001)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Hello, ",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 26,
                      ),
                    ),
                    TextSpan(
                      text: '${userDetailsModel.name}',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://imgs.search.brave.com/sZ1oX91IMCFY_LBT2DjHt4BbQnydW-07jGYOx15N6D4/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzL2M1L2Jk/L2NjL2M1YmRjYzIz/ZDNiZjNhNDBhMWYy/NjkyN2Q0NTBkMGRm/LS1raW5ncy1jcm93/bi13YXJyaW9yLXF1/ZWVuLmpwZw"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
