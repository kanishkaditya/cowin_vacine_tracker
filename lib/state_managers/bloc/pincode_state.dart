part of 'pincode_bloc.dart';

@immutable
abstract class PincodeState extends Equatable {
  @override
  List<Object> get props => [];
}

class PincodeInitial extends PincodeState {}

class SessionLoading extends PincodeState {}

class SessionResultByPinCode extends PincodeState {
  final List<Centers> centers;
  SessionResultByPinCode(this.centers);
}

class SessionResultByDistrict extends PincodeState {
  final List<Centers> centers;
  SessionResultByDistrict(this.centers);
}

class SessionErrorOccured extends PincodeState {
  final Exception e;
  SessionErrorOccured(this.e);
}

class StateListLoaded extends PincodeState {
  final List<States> states;
  StateListLoaded(this.states);
}
class DistrictListLoaded extends PincodeState {
  final List<Districts> districts;
  DistrictListLoaded(this.districts);
}
