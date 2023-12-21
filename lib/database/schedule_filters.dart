
class ScheduleFiltersBellperson {
  bool overnight = false;
  bool morningShift = true;
  bool eveningShift = false;

  ScheduleFiltersBellperson();

  Map<String, bool> asMap() {
    return {
      'overnight_bp': overnight,
      'dayShift_bp': morningShift,
      'nightShift_bp': eveningShift
    };
  }

  String getText(String key) {
    switch(key) {
      case 'overnight_bp':
        return 'overnight shift';
      case 'morningShift_bp':
        return 'morning shift';
      case 'eveningShift_bp':
        return 'evening shift';
      default:
        return '';
    }
  }
}

class ScheduleFiltersDispatcher {
  bool transferShift = false;
  bool shuttles = false;
  bool greeter = false;

  ScheduleFiltersDispatcher();

  Map<String, bool> asMap() {
    return {
      'transferShift_ds' : transferShift,
      'shuttles_ds' : shuttles,
      'greeter_ds' : greeter
    };
  }

  String getText(String key) {
    switch(key) {
      case 'transferShift_ds':
        return 'transfer shift';
      case 'shuttles_ds':
        return 'shuttle shift';
      case 'greeter_ds':
        return 'greeter shift';
      default:
        return '';
    }
  }
}