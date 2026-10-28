import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const EmergencyApp());

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Gargaarsa Yeroo Rakkoo',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red), useMaterial3: true),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lang = 'om';
  final police = TextEditingController(text: '991');
  final hospital = TextEditingController();
  final fire = TextEditingController();
  final recorder = AudioRecorder();
  String? recordingPath;
  bool recording = false;
  String locationText = '';
  bool locating = false;

  final words = {
    'om': {
      'title':'Gargaarsa Yeroo Rakkoo','sos':'GARGAARSA HATATTAMAA','police':'Poolisii','hospital':'Hospitaala','fire':'Ibida','call':'Bilbili',
      'number':'Lakkoofsa bilbilaa','location':'Bakka koo argi','record':'Sagalee waraabi','stop':'Waraabinsa dhaabi',
      'share':'Sagalee qoodi','hint':'Lakkoofsa naannoo keetii galchi','note':'Bilbilli osoo hin jalqabin ati mirkaneessita.'
    },
    'am': {
      'title':'የአደጋ ጊዜ እርዳታ','sos':'አስቸኳይ እርዳታ','police':'ፖሊስ','hospital':'ሆስፒታል','fire':'እሳት አደጋ','call':'ደውል',
      'number':'የስልክ ቁጥር','location':'አካባቢዬን ፈልግ','record':'ድምፅ ቅረጽ','stop':'ቀረጻውን አቁም',
      'share':'ድምፁን አጋራ','hint':'የአካባቢዎን ቁጥር ያስገቡ','note':'ከመደወልዎ በፊት ያረጋግጡ።'
    },
    'en': {
      'title':'Emergency Help','sos':'EMERGENCY SOS','police':'Police','hospital':'Hospital','fire':'Fire service','call':'Call',
      'number':'Phone number','location':'Get my location','record':'Record voice','stop':'Stop recording',
      'share':'Share recording','hint':'Enter your local phone number','note':'You confirm before a call is placed.'
    }
  };
  String t(String k) => words[lang]![k]!;
  @override
  void dispose() { police.dispose(); hospital.dispose(); fire.dispose(); recorder.dispose(); super.dispose(); }

  Future<void> dial(String number) async {
    final n = number.trim();
    if (n.isEmpty) { _msg(t('hint')); return; }
    final uri = Uri(scheme: 'tel', path: n);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _msg('Cannot open phone dialer');
    }
  }
  Future<void> getLocation() async {
    setState(() => locating = true);
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Turn on GPS / location services');
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) throw Exception('Location permission not granted');
      final pos = await Geolocator.getCurrentPosition();
      setState(() => locationText = 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}');
    } catch (e) { _msg(e.toString()); }
    finally { if (mounted) setState(() => locating = false); }
  }
  Future<void> startRecording() async {
    if (!await recorder.hasPermission()) { _msg('Microphone permission is required'); return; }
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/emergency_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() { recording = true; recordingPath = null; });
  }
  Future<void> stopRecording() async {
    final path = await recorder.stop();
    setState(() { recording = false; recordingPath = path; });
  }
  Future<void> shareRecording() async {
    if (recordingPath == null || !File(recordingPath!).existsSync()) { _msg('Record audio first'); return; }
    await Share.shareXFiles([XFile(recordingPath!)], text: 'Emergency voice recording');
  }
  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Widget service(String label, TextEditingController c, IconData icon) => Card(child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: Colors.red), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TextField(controller: c, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: t('number'), hintText: t('hint'), border: const OutlineInputBorder()))),
        const SizedBox(width: 8),
        FilledButton(onPressed: () => dial(c.text), child: Text(t('call')))
      ])
    ])
  ));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(t('title')), actions: [
      DropdownButton<String>(value: lang, underline: const SizedBox(), items: const [
        DropdownMenuItem(value:'om', child: Text('Afaan Oromoo')),
        DropdownMenuItem(value:'am', child: Text('አማርኛ')),
        DropdownMenuItem(value:'en', child: Text('English')),
      ], onChanged: (v) => setState(() => lang = v!))
    ]),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      SizedBox(height: 150, child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
        onPressed: () => dial(police.text),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.sos, size: 56), Text(t('sos'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
        ]),
      )),
      const SizedBox(height: 8),
      Text(t('note'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      service(t('police'), police, Icons.local_police),
      service(t('hospital'), hospital, Icons.local_hospital),
      service(t('fire'), fire, Icons.local_fire_department),
      Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FilledButton.icon(onPressed: locating ? null : getLocation, icon: const Icon(Icons.my_location), label: Text(locating ? '...' : t('location'))),
        if (locationText.isNotEmpty) SelectableText(locationText),
        if (locationText.isNotEmpty) TextButton.icon(onPressed: () => Share.share(locationText), icon: const Icon(Icons.share), label: Text(t('share')))
      ]))),
      Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FilledButton.icon(onPressed: recording ? stopRecording : startRecording, icon: Icon(recording ? Icons.stop : Icons.mic), label: Text(recording ? t('stop') : t('record'))),
        if (recordingPath != null) OutlinedButton.icon(onPressed: shareRecording, icon: const Icon(Icons.share), label: Text(t('share')))
      ]))),
      const SizedBox(height: 18),
      const Text('Safety: add and verify local emergency numbers before use. The SOS button opens the phone dialer; it does not silently call or send data.', style: TextStyle(fontSize: 12, color: Colors.grey))
    ]),
  );
}
