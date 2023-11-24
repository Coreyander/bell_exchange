///A utility class that performs operations on the returned Int from DateTime parameters.
///It's methods provide a String variation that correspond with the number received.

class DateTimeUtils {

  String getWeekdayFromDateTime(DateTime dt) {
    String weekday = "";
    switch (dt.weekday) {
      case 1:
        weekday = "Monday";
        break;
      case 2:
        weekday = "Tuesday";
        break;
      case 3:
        weekday = "Wednesday";
        break;
      case 4:
        weekday = "Thursday";
        break;
      case 5:
        weekday = "Friday";
        break;
      case 6:
        weekday = "Saturday";
        break;
      case 7:
        weekday = "Sunday";
        break;
      default:
        weekday = "Unknown";
        break;
    }
    return weekday;
  }


  String getMonthFromDateTime(DateTime dt) {
    String month = "";
    switch(dt.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
      default:
        month = "Unknown";
        break;
    }
    return month;
  }


  String getSuffixFromDateTime(DateTime dt) {
    String suffix = "";
    switch (dt.day) {
      case 1:
      case 21:
      case 31:
        suffix = "st";
        break;
      case 2:
      case 22:
        suffix = "nd";
        break;
      case 3:
      case 23:
        suffix = "rd";
        break;
      default:
        suffix = "th";
        break;
    }
    return suffix;
  }

}