import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class MeetingViewModel {
  MeetingViewModel(this._repository);
  final MeetingRepository _repository;

  Future<List<MyMeetingModel>?> getMeetingsList({
    required bool isLoading,
  }) async {
    try {
      var res = await _repository.getMeetingsList(
        isLoading: isLoading,
      );
      if (res?.hasError ?? true) {
        return null;
      }
      var data = jsonDecode(res!.data) as Map<String, dynamic>;

      var meetinglistdata = data['meetings'] as List;

      var meetingList = <MyMeetingModel>[];
      for (var i in meetinglistdata) {
        meetingList.add(MyMeetingModel.fromMap(i));
      }

      return meetingList;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<String?> joinMeeting({
    required String deviceId,
    required String meetingId,
  }) async {
    try {
      var res = await _repository.joinMeeting(
        deviceId: deviceId,
        isLoading: true,
        meetingId: meetingId,
      );
      if (res?.hasError ?? true) {
        return null;
      }
      var data = jsonDecode(res!.data);

      var rtcToken = data['rtcToken'];

      return rtcToken;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<CreateMeetingModel?> createMeeting({
    required String deviceId,
    required String meetingDescription,
    required bool audioOnly,
    required List<String> members,
  }) async {
    try {
      var res = await _repository.createMeeting(
        audioOnly: audioOnly,
        deviceId: deviceId,
        isLoading: true,
        meetingDescription: meetingDescription,
        members: members,
      );
      if (res?.hasError ?? true) {
        return null;
      }
      var data = jsonDecode(res!.data);

      var meeting = CreateMeetingModel.fromMap(data);

      return meeting;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<List<UserDetails>?> getMembersList({
    required int skip,
    required int limit,
    required String searchTag,
  }) async {
    try {
      var res = await _repository.getMembersList(
        isLoading: true,
        skip: skip,
        limit: limit,
        searchTag: searchTag,
      );

      if (res?.hasError ?? true) {
        return null;
      }

      var data = jsonDecode(res!.data);

      List listOfUsers = data['users'];
      var userDetailsList = <UserDetails>[];

      for (var i in listOfUsers) {
        userDetailsList.add(UserDetails.fromMap(i));
      }

      return userDetailsList;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<bool> deleteMeeting({
    required String meetingId,
    required bool isLoading,
  }) async {
    var res = await _repository.deleteMeeting(
      meetingId: meetingId,
      isLoading: isLoading,
    );

    if (res?.hasError ?? true) {
      return false;
    }
    return true;
  }
}
