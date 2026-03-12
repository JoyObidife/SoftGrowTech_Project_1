import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/timezone_service.dart';

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
        title: const Text('Time Zone Converter'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              title: 'Start Section',
              icon: Icons.flight_takeoff,
              color: Colors.blue.shade50,
              children: [
                _buildDropdown(
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
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Starting Time Zone',
                  value: _startZone,
                  items: _regionsData[_startRegion] ?? [],
                  onChanged: (val) {
                    setState(() {
                      _startZone = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerTile(
                        label: 'Date',
                        value: DateFormat('yyyy-MM-dd').format(_startDate),
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPickerTile(
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _convertTime,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Convert Time'),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: 'Destination Section',
              icon: Icons.flight_land,
              color: Colors.green.shade50,
              children: [
                _buildDropdown(
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
                const SizedBox(height: 16),
                _buildDropdown(
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
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Converted Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _convertedResult!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
