import 'package:carecompass/features/doctor/screens/doctor_details.dart';
import 'package:carecompass/models/doctor.dart';
import 'package:carecompass/providers/doctor_provider.dart';
import 'package:carecompass/providers/user_provider.dart';
import 'package:flutter/material.dart';

import 'package:carecompass/constants/global_variables.dart';
import 'package:provider/provider.dart';

class DoctorListScreen extends StatefulWidget {
  static const String routeName = "/category_doctor_screen";
  final String category;
  const DoctorListScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  Widget build(BuildContext context) {
    // provider
    final doctorProvider = Provider.of<DoctorSearchProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    print("On category screen " + widget.category);
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
                        // onFieldSubmitted: navigateToSearchScreen,
                        onChanged: (value) => doctorProvider.searchItems(value),
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
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1),
                            ),
                            hintText: 'Search doctors',
                            hintStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
      body:
          // Constant.doctors== null?
          // const Center(
          //   child: CircularProgressIndicator() ,
          // )
          // :
          FutureBuilder<List<Doctor>>(
        future: doctorProvider.getAllDoctors(
            widget.category, userProvider.user.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If there's an error while fetching data
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If no data is available
            return const Center(child: Text('No doctors found.'));
          } else {
            // Data has been successfully fetched
            final doctorList = snapshot.data!;
            return Consumer<DoctorSearchProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  itemCount: doctorList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DoctorDetailsScreen(
                          id: doctorList[index].userId,
                          name: doctorList[index].name,
                          picture: doctorList[index].image_url,
                          degree: doctorList[index].degree,
                          speciality: doctorList[index].speciality,
                          designation: doctorList[index].designation,
                          workplace: doctorList[index].workplace,
                        ),
                      )),
                      child: Card(
                        child: ListTile(
                          leading: Image.network(doctorList[index].image_url),
                          title: Text(doctorList[index].name),
                          subtitle: Text(
                            '${doctorList[index].degree}\n${doctorList[index].workplace}',
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
