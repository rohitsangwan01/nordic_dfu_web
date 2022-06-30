// ignore_for_file: prefer_typing_uninitialized_variables

///create [RequestBuilderFilter] object to pass for Filtering Devices
/// name prefix is a string , to find devices started with this prefix
/// serviceList is a List of services
class RequestBuilderFilter {
  List? servicesList;
  String? namePrefix;
  RequestBuilderFilter({this.servicesList, this.namePrefix});
}
