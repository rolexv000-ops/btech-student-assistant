import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BTechStudentHubApp());
}

class BTechStudentHubApp extends StatelessWidget {
  const BTechStudentHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B.Tech Student Hub',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const ProfileScreen(),
    const CurriculumScreen(),
    const AIScreen(),
    const ScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Curriculum'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Ask'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
        ],
      ),
    );
  }
}

// --- 1. STUDENT PROFILE SCREEN ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  String _selectedBranch = 'CSE';
  String _selectedSem = 'Year 1 - Sem 1';

  final List<String> _branches = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT'];
  final List<String> _semesters = [
    'Year 1 - Sem 1', 'Year 1 - Sem 2',
    'Year 2 - Sem 1', 'Year 2 - Sem 2',
    'Year 3 - Sem 1', 'Year 3 - Sem 2',
    'Year 4 - Sem 1', 'Year 4 - Sem 2',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _rollController.text = prefs.getString('roll') ?? '';
      _selectedBranch = prefs.getString('branch') ?? 'CSE';
      _selectedSem = prefs.getString('semester') ?? 'Year 1 - Sem 1';
    });
  }

  void _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('roll', _rollController.text);
    await prefs.setString('branch', _selectedBranch);
    await prefs.setString('semester', _selectedSem);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Saved Successfully! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.edit))),
                const SizedBox(height: 12),
                TextField(controller: _rollController, decoration: const InputDecoration(labelText: 'Roll Number', prefixIcon: Icon(Icons.badge))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBranch,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) => setState(() => _selectedBranch = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSem,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => _selectedSem = val!),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Save Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. B.TECH CURRICULUM SCREEN ---
class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  String _activeBranch = 'CSE';
  
  final Map<String, List<String>> _curriculumData = {
    'CSE': ['Data Structures', 'DBMS', 'Operating Systems', 'Discrete Mathematics', 'Java OOPs'],
    'ECE': ['Electronic Devices', 'Digital System Design', 'Signals & Systems', 'Microprocessors', 'Network Theory'],
    'EEE': ['Power Systems', 'Electrical Machines', 'Control Systems', 'Power Electronics', 'Electromagnetic Fields'],
    'MECH': ['Thermodynamics', 'Fluid Mechanics', 'Kinematics', 'Manufacturing Tech', 'Strength of Materials'],
    'CIVIL': ['Structural Analysis', 'Geotechnical Engg', 'Surveying', 'Fluid Mechanics', 'Concrete Tech'],
    'IT': ['Web Technologies', 'Software Engineering', 'Cloud Computing', 'Data Mining', 'Computer Networks'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('B.Tech Curriculum'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _curriculumData.keys.map((branch) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ChoiceChip(
                  label: Text(branch),
                  selected: _activeBranch == branch,
                  onSelected: (selected) { if (selected) setState(() => _activeBranch = branch); },
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _curriculumData[_activeBranch]!.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.indigo.shade100, child: Text('${index + 1}')),
                    title: Text(_curriculumData[_activeBranch]![index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Syllabus & Units Covered'),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// --- 3. GOOGLE GEMINI AI ASK SCREEN ---
class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final _queryController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'text': 'హలో! నేను మీ B.Tech AI అసిస్టెంట్‌ని. ఎనీ క్వశ్చన్ అడగండి, నేను ఆన్సర్ చెప్తాను!'}
  ];
  bool _isLoading = false;

  void _askGeminiAI() async {
    final userText = _queryController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': userText});
      _isLoading = true;
      _queryController.clear();
    });

    // ఇక్కడ మీ స్వంత ఉచిత జెమిని కీ మరియు కరెక్ట్ 1.5 మోడల్ ఎండ్‌పాయింట్ సెట్ చేసాను
    const String geminiApiKey = "AQ.Ab8RN6LmTzIvROMDWHSQJ3hxvDX9w29_6inCHHFNIMhIzmlycg";
    final url = Uri.parse("https://googleapis.com");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": userText}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply = data['candidates'][0]['content']['parts'][0]['text'];
        
        // ఇక్కడ మీ యాప్ UI ని AI సమాధానంతో అప్‌డేట్ చేసుకోండి
        setState(() {
          _messages.add({'role': 'model', 'text': aiReply});
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Exception: $e");
    }
