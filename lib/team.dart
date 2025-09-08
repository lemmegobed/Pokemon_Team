import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'add_team.dart'; 
import 'package:get/get.dart';
import 'team_detail_page.dart'; 

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
      home: const TeamPage(),
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
  List<Map<String, dynamic>> _filteredTeams = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = "";

  @override
  void initState() {
    super.initState();
    _loadTeams();

    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
        _filterTeams();
      });
    });
  }

  void _seedIfEmpty() {
    final stored = _storage.read('teams');
    if (stored == null || (stored is List && stored.isEmpty)) {
      final defaultTeams = [
        // {
        //   "name": "team A",
        //   "members": [
        //     {
        //       "name": "Bulbasaur",
        //       "image":"https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/001.png"
        //     },
        //     {
        //       "name": "Charmander",
        //       "image":"https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/004.png"},
        //     {
        //       "name": "Squirtle",
        //       "image":"https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/007.png"},
        //   ],
        // },
        // {
        //   "name": "team B",
        //   "members": [
        //     {
        //       "name": "Caterpie",
        //       "image":"https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/010.png"},
        //     {
        //       "name": "Metapod",
        //       "image":"https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/011.png"},
        //     {
        //       "name": "Butterfree",
        //       "image":"https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/012.png"},
        //   ],
        // },
      ];
      _storage.write('teams', defaultTeams);
    }
  }

  void _loadTeams() {
    _seedIfEmpty();
    final stored = _storage.read('teams');
    if (stored is List) {
      _teams = stored
          .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e))
          .toList();
      _filterTeams();
      setState(() {});
    }
  }

  void _filterTeams() {
    if (_query.isEmpty) {
      _filteredTeams = List.from(_teams);
    } else {
      _filteredTeams = _teams
          .where((team) =>
              (team["name"] ?? "").toString().toLowerCase().contains(_query))
          .toList();
    }
  }

  void _persist() => _storage.write("teams", _teams);

  void _saveTeam(List<Map<String, String>> members, String teamName) {
    final newTeam = {"name": teamName, "members": members};
    setState(() {
      _teams.add(newTeam);
      _filterTeams();
    });
    _persist();
  }

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
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: fg),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  Future<void> _renameTeam(int index) async {
    final controller = TextEditingController(
        text: _teams[index]["name"]?.toString() ?? "");
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
        _filterTeams();
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
      setState(() {
        _teams.removeAt(index);
        _filterTeams();
      });
      _persist();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final empty = _filteredTeams.isEmpty;

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "ค้นหาทีม...",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, size: 16),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: "ล้างคำค้น",
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: empty
          ? Center(
              child: Text(
                _query.isEmpty
                    ? "ยังไม่มีทีมที่บันทึก\nกดปุ่ม + เพื่อสร้างทีมใหม่"
                    : "ไม่พบทีมที่ค้นหา",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _filteredTeams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final team = _filteredTeams[index];
                final String name =
                    (team["name"] ?? "Unnamed Team").toString();
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
                              bg: const Color.fromARGB(255, 179, 229, 252),
                              fg: const Color.fromARGB(255, 1, 87, 155),
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
                            const SizedBox(width: 6),
    // 🔵 ปุ่มดูรายละเอียดทีม
    _smallRoundIconButton(
      context: context,
      icon: Icons.info_outline, // ใช้ไอคอน info
      onTap: () {
        Get.to(() => TeamDetailPage(team: _teams[index]));
      },
       bg: Theme.of(context).colorScheme.errorContainer,
      fg: Theme.of(context).colorScheme.onErrorContainer,
      tooltip: 'ดูรายละเอียด',
    ),
                          ],
                        ),
                        const SizedBox(height: 5),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
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
          size: 20,
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
        backgroundColor: Colors.blue[400],
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        hoverElevation: 8,
      ),
    );
  }
}
