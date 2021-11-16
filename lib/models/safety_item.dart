class SafetyItem {
  String id = '';
  double latitude = 0;
  double longitude = 0;
  bool pickedUp = false;

  SafetyItem(
    this.id,
    this.latitude,
    this.longitude,
    this.pickedUp,
  );

  SafetyItem.fromDefault() {
    id = '';
    latitude = 0;
    longitude = 0;
    pickedUp = false;
  }
}
