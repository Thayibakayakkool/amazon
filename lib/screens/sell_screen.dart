import 'dart:typed_data';

import 'package:amazon_app/providers/user_detalis_provider.dart';
import 'package:amazon_app/resources/cloundfirestore_method.dart';
import 'package:amazon_app/utils/color_theme.dart';
import 'package:amazon_app/utils/utils.dart';
import 'package:amazon_app/widgets/custom_main_button.dart';
import 'package:amazon_app/widgets/loading_widget.dart';
import 'package:amazon_app/widgets/text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  bool isLoading = false;
  int selected = 1;
  Uint8List? image;
  TextEditingController nameController = TextEditingController();
  TextEditingController costController = TextEditingController();
  List<int> keysForDiscount = [0, 70, 60, 50];

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    costController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = Utils().getScreenSize(context);
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: !isLoading
          ? SingleChildScrollView(
              child: SizedBox(
                height: screenSize.height,
                width: screenSize.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Stack(
                          children: [
                            image == null
                                ? Image.network(
                                    "https://imgs.search.brave.com/kasDk2pqUCMn5hnrt-nmsKrEevkm8VmREjhc2Kvgzyo/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzAzLzQ2LzgzLzk2/LzM2MF9GXzM0Njgz/OTY4M182bkFQemJo/cFNrSXBiOHBtQXd1/ZmtDN2M1ZUQ3d1l3/cy5qcGc",
                                    height: screenSize.height / 10,
                                  )
                                : Image.memory(
                                    image!,
                                    height: screenSize.height / 10,
                                  ),
                            IconButton(
                                onPressed: () async {
                                  Uint8List? temp = await Utils().pickImage();
                                  if (temp != null) {
                                    setState(() {
                                      image = temp;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.file_upload))
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 35),
                          height: screenSize.height * 0.7,
                          width: screenSize.width * 0.7,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldWidget(
                                  title: "Name",
                                  controller: nameController,
                                  obscureText: false,
                                  hintText: "Enter the name of the item"),
                              TextFieldWidget(
                                  title: "Cost",
                                  controller: costController,
                                  obscureText: false,
                                  hintText: "Enter the cost of the item"),
                              const Text(
                                "Discount",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              ListTile(
                                title: const Text("None"),
                                leading: Radio(
                                  value: 1,
                                  groupValue: selected,
                                  onChanged: (int? i) {
                                    setState(() {
                                      selected = i!;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text("70%"),
                                leading: Radio(
                                  value: 2,
                                  groupValue: selected,
                                  onChanged: (int? i) {
                                    setState(() {
                                      selected = i!;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text("60%"),
                                leading: Radio(
                                  value: 3,
                                  groupValue: selected,
                                  onChanged: (int? i) {
                                    setState(() {
                                      selected = i!;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text("50%"),
                                leading: Radio(
                                  value: 4,
                                  groupValue: selected,
                                  onChanged: (int? i) {
                                    setState(() {
                                      selected = i!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomMainButton(
                            child: const Text(
                              "Sell",
                              style: TextStyle(color: Colors.black),
                            ),
                            color: yellowColor,
                            isLoading: isLoading,
                            onPressed: () async {
                              String output = await CloundFirestoreMethod()
                                  .uploadProductToDatabase(
                                      image: image,
                                      productName: nameController.text,
                                      rawCost: costController.text,
                                      discount: keysForDiscount[selected - 1],
                                      sellerName:
                                          Provider.of<UserDetailsProvider>(
                                                  context,
                                                  listen: false)
                                              .userDetails
                                              .name,
                                      sellerUid: FirebaseAuth
                                          .instance.currentUser!.uid);
                              if (output == "success") {
                                Utils().showSnackBar(
                                    context: context,
                                    content: "Posted Product");
                              } else {
                                Utils().showSnackBar(
                                    context: context, content: output);
                              }
                            }),
                        CustomMainButton(
                            child: const Text(
                              "Back",
                              style: TextStyle(color: Colors.black),
                            ),
                            color: Colors.grey[300]!,
                            isLoading: isLoading,
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const LoadingWidget(),
    ));
  }
}
