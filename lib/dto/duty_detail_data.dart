// lib/dto/duty_detail_data.dart

import 'package:mobileapp/model/user.dart';
import 'package:mobileapp/dto/get_duty_detail.dart';

class DutyDetailData {
  final User user;
  final GetDutyDetail dutyDetail;

  DutyDetailData({
    required this.user,
    required this.dutyDetail,
  });
}
