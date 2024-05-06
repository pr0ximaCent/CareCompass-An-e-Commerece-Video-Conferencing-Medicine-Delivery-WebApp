import 'package:carecompass/features/doctor/screens/doctor_list.dart';
import 'package:flutter/material.dart';
import 'package:carecompass/features/doctor/local_constants/category.dart';
import 'package:carecompass/constants/global_variables.dart';

class DoctorCategoryScreen extends StatefulWidget {
  const DoctorCategoryScreen({Key? key}) : super(key: key);

  @override
  State<DoctorCategoryScreen> createState() => _DoctorCategoryScreenState();
}

class _DoctorCategoryScreenState extends State<DoctorCategoryScreen> {
  List<Map<String, String>> displayedCategories = [...doctorCategories];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: GlobalVariables.appBarGradient),
          ),
          title: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 15),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    elevation: 1,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            displayedCategories = [...doctorCategories];
                          } else {
                            displayedCategories = doctorCategories
                                .where((item) => item['title']!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          }
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 23,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide:
                              const BorderSide(color: Colors.black38, width: 1),
                        ),
                        hintText: 'Search Doctor Category',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            SizedBox(
              height: MediaQuery.of(context).size.height * 1,
              width: MediaQuery.of(context).size.width * 1,
              child: GridView.builder(
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Three items per row
                  childAspectRatio: 1, // Adjust the aspect ratio as needed
                ),
                itemBuilder: (BuildContext context, int index) {
                  // print(displayedCategories[index]);
                  return InkWell(
                    onTap: () {
                      // Handle category item tap
                      Navigator.pushNamed(context, DoctorListScreen.routeName,
                          arguments: displayedCategories[index]['title']!);
                    },
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Image.asset(
                              displayedCategories[index]['imageIcon']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(displayedCategories[index]['title']!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: displayedCategories.length,
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
