class MedicineCollectionBoxInfo {
  String? machineID;
  double? capsule_volume;
  double? powder_volume;
  double? liquid_volume;
  double? ointment_volume;

  MedicineCollectionBoxInfo({
    this.machineID,
    this.capsule_volume,
    this.powder_volume,
    this.liquid_volume,
    this.ointment_volume,
  });

  MedicineCollectionBoxInfo.fromJson(Map<String, dynamic> json) {
    machineID = json['machineID'];
    capsule_volume = json['capsule_volume'];
    powder_volume = json['powder_volume'];
    liquid_volume = json['liquid_volume'];
    ointment_volume = json['ointment_volume'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['machineID'] = this.machineID;
    data['capsule_volume'] = this.capsule_volume;
    data['powder_volume'] = this.powder_volume;
    data['liquid_volume'] = this.liquid_volume;
    data['ointment'] = this.ointment_volume;
    return data;
  }

  fromJson(e) {}
}
