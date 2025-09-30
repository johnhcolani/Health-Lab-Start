import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:healthlab_start/service/patient_service.dart';
import 'package:healthlab_start/service/ws_service.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const HealthLabStrterApp());
}

class HealthLabStrterApp extends StatelessWidget {
  const HealthLabStrterApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     debugShowCheckedModeBanner: false,
     title: 'HealthLab Starter',
     theme: ThemeData(
       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
       useMaterial3: true,
     ),
     home: const HomeScreen(),
   );
  }

}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = [const PatientsPage(), const LiveStreamPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthLab Starter'),
      ),
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Live Vitals'),
        ],
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});
  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late Future<List<Map<String, dynamic>>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = PatientService.fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _patientsFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final patients = snap.data ?? [];
        if (patients.isEmpty) return const Center(child: Text('No patients found.'));
        return ListView.separated(
          itemCount: patients.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, idx) {
            final p = patients[idx];
            final name = PatientService.getDisplayName(p);
            final id = p['id'] ?? '—';
            return ListTile(
              title: Text(name),
              subtitle: Text('id: $id'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PatientDetailPage(patient: p)),
              ),
            );
          },
        );
      },
    );
  }
}

class PatientDetailPage extends StatelessWidget {
  final Map<String, dynamic> patient;
  const PatientDetailPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final name = PatientService.getDisplayName(patient);
    final gender = patient['gender'] ?? 'unknown';
    final birth = patient['birthDate'] ?? '—';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InfoRow(label: 'Name', value: name),
            InfoRow(label: 'Gender', value: gender),
            InfoRow(label: 'BirthDate', value: birth),
            const SizedBox(height: 12),
            const Text('Raw FHIR Patient JSON', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: SingleChildScrollView(child: Text(const JsonEncoder.withIndent('  ').convert(patient)))),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(children: [
        SizedBox(width: 110, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value)),
      ]),
    );
  }
}

class LiveStreamPage extends StatefulWidget {
  const LiveStreamPage({super.key});
  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  final WsService _ws = WsService();
  final List<FlSpot> _hrPoints = [];
  final int _maxPoints = 60; // last 60 seconds
  StreamSubscription<Map<String, dynamic>>? _sub;
  double _xIndex = 0;

  @override
  void initState() {
    super.initState();
    _ws.connect();
    _sub = _ws.stream.listen(_onVData, onError: (e) => print('WS error: $e'));
  }

  void _onVData(Map<String, dynamic> json) {
    // expected json: { "hr": 78, "spo2": 98, "ts": 169... }
    final hr = (json['hr'] ?? 0).toDouble();
    setState(() {
      _xIndex += 1;
      _hrPoints.add(FlSpot(_xIndex, hr));
      if (_hrPoints.length > _maxPoints) {
        _hrPoints.removeAt(0);
        // normalize x values so they fit nicely
        for (var i = 0; i < _hrPoints.length; i++) {
          _hrPoints[i] = FlSpot(i.toDouble(), _hrPoints[i].y);
        }
        _xIndex = _hrPoints.length.toDouble();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ws.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latest = _hrPoints.isNotEmpty ? _hrPoints.last.y.toInt() : null;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Live Heart Rate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Latest: ${latest ?? '--'} bpm', style: const TextStyle(fontSize: 16)),
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _hrPoints.isEmpty ? const Center(child: Text('Waiting for data...')) : LineChart(
                LineChartData(
                  minX: 0,
                  maxX: _hrPoints.length > 0 ? _hrPoints.length.toDouble() : 10,
                  minY: 40,
                  maxY: 160,
                  lineBarsData: [
                    LineChartBarData(spots: _hrPoints, isCurved: true, dotData: FlDotData(show: false), belowBarData: BarAreaData(show: true))
                  ],
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<Map<String, dynamic>?>(
          stream: _ws.stream,
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();
            final v = snap.data!;
            final ts = v['ts'] != null ? DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(v['ts'])) : '--';
            return Text('Last update: $ts  •  HR: ${v['hr']} bpm  •  SpO₂: ${v['spo2']}%');
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            if (_ws.connected) {
              _ws.disconnect();
            } else {
              _ws.connect();
            }
            setState(() {});
          },
          icon: Icon(_ws.connected ? Icons.pause : Icons.play_arrow),
          label: Text(_ws.connected ? 'Disconnect' : 'Connect'),
        ),
        const SizedBox(height: 12),
        const Text('Note: run the provided Node.js fake stream server locally or point to an existing WebSocket stream.'),
      ]),
    );
  }
}