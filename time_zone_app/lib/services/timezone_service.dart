import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimeZoneService {
  static void initialize() {
    tz.initializeTimeZones();
  }

  static List<String> getAllTimeZones() {
    return tz.timeZoneDatabase.locations.keys.toList();
  }

  static Map<String, List<String>> getRegionsAndZones() {
    final Map<String, List<String>> regions = {};
    for (var zone in tz.timeZoneDatabase.locations.keys) {
      final parts = zone.split('/');
      if (parts.length > 1) {
        final region = parts[0];
        if (!regions.containsKey(region)) {
          regions[region] = [];
        }
        regions[region]!.add(zone);
      }
    }
    // Sort regions and zones
    final sortedRegions = Map.fromEntries(
      regions.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    for (var entry in sortedRegions.entries) {
      entry.value.sort();
    }
    return sortedRegions;
  }

  static DateTime convertTime(DateTime dateTime, String fromZone, String toZone) {
    final fromLocation = tz.getLocation(fromZone);
    final toLocation = tz.getLocation(toZone);

    final fromDateTime = tz.TZDateTime.from(dateTime, fromLocation);
    final toDateTime = tz.TZDateTime.from(fromDateTime, toLocation);

    return toDateTime;
  }
}
