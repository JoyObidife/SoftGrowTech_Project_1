import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/timezone_service.dart';
import '../widgets/section_card.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/picker_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, List<String>> _regionsData = TimeZoneService.getRegionsAndZones();
  
  String? _startRegion;
  String? _startZone;
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  String? _destRegion;
  String? _destZone;
  String? _convertedResult;

  @override
  void initState() {
    super.initState();
    if (_regionsData.isNotEmpty) {
      _startRegion = _regionsData.keys.first;
      _startZone = _regionsData[_startRegion]!.first;
      _destRegion = _regionsData.keys.first;
      _destZone = _regionsData[_destRegion]!.first;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _convertTime() {
    if (_startZone == null || _destZone == null) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final result = TimeZoneService.convertTime(
      startDateTime,
      _startZone!,
      _destZone!,
    );

    setState(() {
      _convertedResult = DateFormat('MMMM d, yyyy, h:mm a').format(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Zone Converter'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              title: 'Start Section',
              icon: Icons.flight_takeoff,
              color: Colors.blue.shade50,
              children: [
                CustomDropdown(
                  label: 'Continent/Region',
                  value: _startRegion,
                  items: _regionsData.keys.toList(),
                  onChanged: (val) {
                    setState(() {
                      _startRegion = val;
                      _startZone = _regionsData[val]!.first;
                    });
                  },
                ),
                 SizedBox(height: 16),
                CustomDropdown(
                  label: 'Starting Time Zone',
                  value: _startZone,
                  items: _regionsData[_startRegion] ?? [],
                  onChanged: (val) {
                    setState(() {
                      _startZone = val;
                    });
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PickerTile(
                        label: 'Date',
                        value: DateFormat('yyyy-MM-dd').format(_startDate),
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: PickerTile(
                        label: 'Time',
                        value: _startTime.format(context),
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
           SizedBox(height: 24),
            ElevatedButton(
              onPressed: _convertTime,
              style: ElevatedButton.styleFrom(
                padding:  EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text('Convert Time'),
            ),
             SizedBox(height: 24),
            SectionCard(
              title: 'Destination Section',
              icon: Icons.flight_land,
              color: Colors.green.shade50,
              children: [
                CustomDropdown(
                  label: 'Destination Continent/Region',
                  value: _destRegion,
                  items: _regionsData.keys.toList(),
                  onChanged: (val) {
                    setState(() {
                      _destRegion = val;
                      _destZone = _regionsData[val]!.first;
                    });
                  },
                ),
                 SizedBox(height: 16),
                CustomDropdown(
                  label: 'Destination Time Zone',
                  value: _destZone,
                  items: _regionsData[_destRegion] ?? [],
                  onChanged: (val) {
                    setState(() {
                      _destZone = val;
                    });
                  },
                ),
                if (_convertedResult != null) ...[
                  SizedBox(height: 24),
                  Container(
                    padding:  EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Converted Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _convertedResult!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

}
