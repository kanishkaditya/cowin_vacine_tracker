import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cowin_vaccine_tracker/models/pincode.dart';
import 'package:cowin_vaccine_tracker/models/stateDistrict.dart';
import 'package:cowin_vaccine_tracker/repos/pincodeRepo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:cowin_vaccine_tracker/web/server.dart';
part 'pincode_event.dart';
part 'pincode_state.dart';

class PincodeBloc extends Bloc<PincodeEvent, PincodeState> {
  final Server server;
  PincodeBloc({this.server}) : super(PincodeInitial());

  @override
  Stream<PincodeState> mapEventToState(
    PincodeEvent event,
  ) async* {
    if (event is SessionRequestedByDistrict) {
      yield SessionLoading();
      try {
        List<Centers> centers =
            await server.getSessionByDistrict(event.dis_code, event.date);
        yield SessionResultByDistrict(centers);
      } on Exception catch (e) {
        yield SessionErrorOccured(e);
      }
    } else if (event is SessionRequestedByPin) {
      yield SessionLoading();
      try {
        List<Centers> centers =
            await server.getSessionByPincode(event.pin_code, event.date);
        yield SessionResultByPinCode(centers);
      } on Exception catch (e) {
        yield SessionErrorOccured(e);
      }
    } else if (event is StateListRequested) {
      yield SessionLoading();
      try {
        List<States> centers = await server.getStates();
        yield StateListLoaded(centers);
      } on Exception catch (e) {
        yield SessionErrorOccured(e);
      }      
    }
     else if (event is DistrictListRequested) {
      yield SessionLoading();
      try {
        List<Districts> centers = await server.getDistrict(event.state_id);
        yield DistrictListLoaded(centers);
      } on Exception catch (e) {
        yield SessionErrorOccured(e);
      }
    }
  }
}
