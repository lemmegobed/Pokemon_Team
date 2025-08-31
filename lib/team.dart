import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'add_team.dart'; // นำเข้าหน้า add_team.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const TeamApp());
}

class TeamApp extends StatelessWidget {
  const TeamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Team Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TeamPage(), // หน้าเริ่มต้น
    );
  }
}

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final GetStorage _storage = GetStorage();
  List<Map<String, dynamic>> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  // ---------- SEED: team ตัวอย่าง 2 ทีม ----------
  List<Map<String, dynamic>> get _defaultTeams => [
        {
          "name": "team a",
          "members": [
            {
              "name": "Bulbasaur",
              "image":
                  "https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/001.png"
            },
            {
              "name": "Charmander",
              "image":
                  "https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/004.png"
            },
            {
              "name": "Squirtle",
              "image":
                  "https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/007.png"
            },
          ],
        },
        {
          "name": "team b",
          "members": [
            {
              "name": "Caterpie",
              "image":
                  "https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/010.png"
            },
            {
              "name": "Metapod",
              "image":
                  "https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/011.png"
            },
            {
              "name": "Butterfree",
              "image":
                  "https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/012.png"
            },
          ],
        },
      ];

  void _seedIfEmpty() {
    final stored = _storage.read('teams');
    if (stored == null || (stored is List && stored.isEmpty)) {
      _storage.write('teams', _defaultTeams);
    }
  }
  // ------------------------------------------------

  void _loadTeams() {
    _seedIfEmpty();
    final stored = _storage.read('teams');
    if (stored is List) {
      _teams =
          stored.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {});
    }
  }

  void _persist() => _storage.write("teams", _teams);

  // เพิ่มทีมใหม่
  void _saveTeam(List<Map<String, String>> members, String teamName) {
    final newTeam = {"name": teamName, "members": members};
    setState(() => _teams.add(newTeam));
    _persist();
  }

  // ปุ่มกลมเล็กพร้อมพื้นหลัง
  Widget _smallRoundIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color fg,
    String? tooltip,
  }) {
    final btn = Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6), // ยิ่งน้อยยิ่งเล็ก
          child: Icon(icon, size: 16, color: fg),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  // ======= ฟังก์ชันแก้ไข/ลบ =======
  Future<void> _renameTeam(int index) async {
    final controller = TextEditingController(text: _teams[index]["name"]?.toString() ?? "");
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เปลี่ยนชื่อทีม"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Team Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (ok == true) {
      final newName = controller.text.trim();
      if (newName.isNotEmpty) {
        setState(() => _teams[index]["name"] = newName);
        _persist();
      }
    }
  }

  Future<void> _deleteTeam(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ลบทีมนี้หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => _teams.removeAt(index));
      _persist();
    }
  }
  // =================================

  @override
  Widget build(BuildContext context) {
    final empty = _teams.isEmpty;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        title: const Text(
          "Pokémon Teams",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: empty
          ? Center(
              child: Text(
                "ยังไม่มีทีมที่บันทึก\nกดปุ่ม + เพื่อสร้างทีมใหม่",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _teams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final team = _teams[index];
                final String name = (team["name"] ?? "Unnamed Team").toString();
                final List membersRaw = (team["members"] ?? []) as List;
                final List<Map<String, dynamic>> members =
                    membersRaw.map((m) => Map<String, dynamic>.from(m)).toList();

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _smallRoundIconButton(
                              context: context,
                              icon: Icons.edit_outlined,
                              onTap: () => _renameTeam(index),
                              bg: const Color.fromARGB(255, 179, 229, 252), // ฟ้าอ่อน
                              fg: const Color.fromARGB(255, 1, 87, 155),    // ฟ้าเข้มสำหรับไอคอน
                              tooltip: 'แก้ไขชื่อทีม',
                            ),
                            const SizedBox(width: 6),
                            _smallRoundIconButton(
                              context: context,
                              icon: Icons.delete_outline,
                              onTap: () => _deleteTeam(index),
                              bg: Theme.of(context).colorScheme.errorContainer,
                              fg: Theme.of(context).colorScheme.onErrorContainer,
                              tooltip: 'ลบทีม',
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // รูป + ชื่อตัวละคร
                        Wrap(
                          spacing: 10,
                          runSpacing: 12,
                          children: members.map((m) {
                            final String monName = (m['name'] ?? '').toString();
                            final String img = (m['image'] ?? '').toString();
                            return SizedBox(
                              width: 72,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      img,
                                      width: 48,  
                                      height: 48, 
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    monName,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 10,               
                                          color: Colors.blueGrey[700], 
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTeamPage(saveTeam: _saveTeam),
      ),
    );
    _loadTeams();
  },
  icon: const Icon(
    Icons.add,
    size: 20, // ลดขนาดไอคอน
    color: Colors.white,
  ),
  label: const Text(
    "เพิ่มทีม",
    style: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
  backgroundColor: Colors.blue[400], // สีฟ้าอ่อน
  elevation: 6,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14), // โค้งมน
  ),
  extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  hoverElevation: 8,
),

    );
  }
}
