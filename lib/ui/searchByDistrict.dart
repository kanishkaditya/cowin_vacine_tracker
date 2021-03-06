import 'package:cowin_vaccine_tracker/models/stateDistrict.dart';
import 'package:cowin_vaccine_tracker/state_managers/bloc/pincode_bloc.dart';
import 'package:cowin_vaccine_tracker/ui/widgets/errorWidget.dart';
import 'package:cowin_vaccine_tracker/ui/widgets/listcount.dart';
import 'package:cowin_vaccine_tracker/ui/widgets/loading.dart';
import 'package:cowin_vaccine_tracker/ui/widgets/temp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';

Districts _selectedDistrict;

class ByDistrictPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final PincodeBloc pincodeBloc = PincodeBloc(server: watch(serverprovider));
    pincodeBloc.add(StateListRequested());
    return BlocProvider(
      create: (context) => pincodeBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Search By District"),
        ),
        body: BlocBuilder<PincodeBloc, PincodeState>(
          builder: (context, state) {
            if (state is SessionLoading) {
              return LoadingScreen();
            } else if (state is StateListLoaded) {
              return UpperContent(
                states: state.states,
              );
            } else if (state is SessionResultByDistrict) {
              return Column(
                children: [
                  MyScreenDistrict(
                      disCode: _selectedDistrict.districtId.toString()),
                  Expanded(child: _lowerContent()),
                ],
              );
            }
            return ErrorMessage();
          },
        ),
      ),
    );
  }

  Widget _lowerContent() {
    return BlocBuilder<PincodeBloc, PincodeState>(
      builder: (context, state) {
        if (state is SessionResultByDistrict) {
          return state.centers.length == 0
              ? Center(
                  child: Text("No Slots Found"),
                )
              : Scrollbar(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final DateFormat formatter = DateFormat('dd-MM-yyyy');
                      final String formatted =
                          formatter.format(state.selectedTime);

                      if (formatted.compareTo(
                              state.centers[index].sessions[0].date) ==
                          0) {
                        return ListCoutn(
                          centers: state.centers[index],
                        );
                      }
                      return null;
                    },
                    itemCount: state.centers.length,
                  ),
                );
        } else if (state is SessionLoading) {
          return LoadingScreen();
        } else {
          return ErrorMessage();
        }
      },
    );
  }
}

class UpperContent extends StatefulWidget {
  final List<States> states;

  const UpperContent({Key key, this.states}) : super(key: key);
  @override
  _UpperContentState createState() => _UpperContentState();
}

class _UpperContentState extends State<UpperContent> {
  States _slectedValue;

  List<Districts> districts = [];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select State",
                    style: GoogleFonts.ubuntu(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Color(0xFFdeedf0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<States>(
                      focusColor: Colors.white,
                      value: _slectedValue,
                      //elevation: 5,
                      style: TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.black,
                      items:
                          widget.states.map<DropdownMenuItem<States>>((value) {
                        return DropdownMenuItem<States>(
                          value: value,
                          child: Text(
                            value.stateName,
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        );
                      }).toList(),
                      hint: Text(
                        "Please choose a State",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                      onChanged: (States value) async {
                        districts.clear();
                        _selectedDistrict = null;
                        districts = await ProviderContainer()
                            .read(serverprovider)
                            .getDistrict(value.stateId);

                        setState(() {
                          _slectedValue = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select District",
                    style: GoogleFonts.ubuntu(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Color(0xFFdeedf0),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: DropdownButtonHideUnderline(
                      child: new Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.white,
                        ),
                        child: DropdownButton<Districts>(
                          focusColor: Colors.white,
                          value: _selectedDistrict,
                          //elevation: 5,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          iconEnabledColor: Colors.black,
                          items: districts
                              .map<DropdownMenuItem<Districts>>((value) {
                            return DropdownMenuItem<Districts>(
                              value: value,
                              child: Text(
                                value.districtName,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            );
                          }).toList(),
                          hint: Text(
                            "Please choose a District",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                          onChanged: (Districts value) {
                            setState(() {
                              _selectedDistrict = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            MaterialButton(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.amber,
              onPressed: () {
                BlocProvider.of<PincodeBloc>(context).add(
                    SessionRequestedByDistrict(
                        _selectedDistrict.districtId.toString(),
                        DateTime.now()));
              },
              child: Text("Get"),
            ),
            LottieBuilder.asset("images/handwash.json"),
          ],
        ),
      ),
    );
  }
}
