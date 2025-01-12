import 'package:mobileapp/model/approval.dart';
import 'package:mobileapp/model/duty.dart';

class GetDutyDetail {
  final Duty duty;
  final Approval approval;
  final Map<String, String> transport;

  GetDutyDetail({
    required this.duty,
    required this.approval,
    required this.transport,
  });

  factory GetDutyDetail.fromJson(Map<String, dynamic> json) {
    var dutyJson = json['duty'];
    var approvalJson = json['position'];
    var transportJson = json['transport'];

    return GetDutyDetail(
      duty: Duty.fromJson(dutyJson),
      approval: Approval.fromJson(approvalJson),
      transport: transportJson.cast<String, String>(),
    );
  }
}
