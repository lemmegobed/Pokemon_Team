import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'team.dart';  

class AddTeamPage extends StatefulWidget {
  final Function(List<Map<String, String>>, String) saveTeam;
  const AddTeamPage({super.key, required this.saveTeam});

  @override
  State<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage> {
  final TextEditingController _teamNameController =
      TextEditingController(text: "My Pokémon Team");

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = ""; 

  final Set<int> _selected = <int>{};

  final List<Map<String, String>> players = const [
    {'name': 'Bulbasaur',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/001.png'},
    {'name': 'Ivysaur',    'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/002.png'},
    {'name': 'Venusaur',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/003.png'},
    {'name': 'Charmander', 'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/004.png'},
    {'name': 'Charmeleon', 'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/005.png'},
    {'name': 'Charizard',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/006.png'},
    {'name': 'Squirtle',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/007.png'},
    {'name': 'Wartortle',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/008.png'},
    {'name': 'Blastoise',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/009.png'},
    {'name': 'Caterpie',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/010.png'},
    {'name': 'Metapod',    'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/011.png'},
    {'name': 'Butterfree', 'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/012.png'},
    {'name': 'Weedle',     'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/013.png'},
    {'name': 'Kakuna',     'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/014.png'},
    {'name': 'Beedrill',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/015.png'},
    {'name': 'Pidgey',     'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/016.png'},
    {'name': 'Pidgeotto',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/017.png'},
    {'name': 'Pidgeot',    'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/018.png'},
    {'name': 'Rattata',    'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/019.png'},
    {'name': 'Raticate',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/020.png'},
    {'name': 'Spearow',    'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/021.png'},
    {'name': 'Fearow',     'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/022.png'},
    {'name': 'Ekans',      'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/023.png'},
    {'name': 'Arbok',      'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/024.png'},
    {'name': 'Pikachu',    'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/025.png'},
    {'name': 'Raichu',     'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/026.png'},
    {'name': 'Sandshrew',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/027.png'},
    {'name': 'Sandslash',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/028.png'},
    {'name': 'Nidoran♀',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/029.png'},
    {'name': 'Nidorina',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/030.png'},
    {'name': 'Nidoqueen',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/031.png'},
    {'name': 'Nidoran♂',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/032.png'},
    {'name': 'Nidorino',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/033.png'},
    {'name': 'Nidoking',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/034.png'},
    {'name': 'Clefairy',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/035.png'},
    {'name': 'Clefable',   'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/036.png'},
    {'name': 'Vulpix',     'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/037.png'},
    {'name': 'Ninetales',  'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/038.png'},
    {'name': 'Jigglypuff', 'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/039.png'},
    {'name': 'Wigglytuff', 'image': 'https://raw.githubusercontent.com/HybridShivam/Pokemon/master/assets/images/040.png'},
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        if (_selected.length < 3) {
          _selected.add(index);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ต้องมีสมาชิก 3 ตัวเท่านั้น')),
          );
        }
      }
    });
  }

  void _resetTeam() {
    if (_selected.isEmpty) return;
    setState(() => _selected.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('รีเซ็ตทีมแล้ว')),
    );
  }

  void _confirmAndSave() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการสร้างทีม"),
        content: TextField(
          controller: _teamNameController,
          decoration: const InputDecoration(
            labelText: "Team Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final teamName = _teamNameController.text.trim();
              if (teamName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('กรุณากรอกชื่อทีมก่อนบันทึก'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return; 
              }
              final chosen = _selected.map((i) => players[i]).toList();
              widget.saveTeam(chosen, teamName);
              Navigator.of(context).pop(); 
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save),
            label: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<int> visibleIndices = List<int>.generate(players.length, (i) => i)
        .where((i) => _query.isEmpty
            ? true
            : players[i]['name']!.toLowerCase().contains(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.blue,
  elevation: 4,
  title: const Text(
    "สร้างทีม Pokémon",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  centerTitle: true,

  // 👉 เพิ่มปุ่มด้านขวาสุด
  actions: [
    IconButton(
      tooltip: 'ไปหน้าทีม',
      icon: const Icon(Icons.groups, color: Colors.white),
      onPressed: () {
        // ใช้ GetX นำทางไปหน้า team.dart
        Get.to(() => const TeamPage());
      },
    ),
  ],
),


      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // โปเกมอนที่เลือกแล้ว
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ทีม : ${_selected.length}/3",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selected.map((i) {
                            final p = players[i];
                            return ClipOval(
                              child: Image.network(
                                p['image']!,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ช่องค้นหา 
            TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: "ค้นหา...",
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, size: 14),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: "ล้างคำค้น",
                        icon: const Icon(Icons.clear, size: 14),
                        onPressed: () => _searchCtrl.clear(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(width: 1.5, color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ป้ายเลือกโปเกมอน
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.catching_pokemon,
                      color: Colors.blue, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "เลือกโปเกมอน :",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // รายชื่อหลังกรอง
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final cross = c.maxWidth > 400 ? 4 : c.maxWidth > 200 ? 2 : 2;

                  if (visibleIndices.isEmpty) {
                    return Center(
                      child: Text(
                        "ไม่พบโปเกมอน",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final canSelectMore = _selected.length < 3;

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: visibleIndices.length,
                    itemBuilder: (_, visIdx) {
                      final index = visibleIndices[visIdx]; 
                      final name = players[index]['name']!;
                      final img = players[index]['image']!;
                      final isSelected = _selected.contains(index);
                      final isDisabled = !isSelected && !canSelectMore;

                      return GestureDetector(
                        onTap: isDisabled ? null : () => _toggle(index),
                        child: Card(
                          color: Colors.white,
                          elevation: isSelected ? 8 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color:
                                  isSelected ? Colors.blue : Colors.transparent,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Ink.image(
                                      image: NetworkImage(img),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: AnimatedScale(
                                  scale: isSelected ? 1 : 0,
                                  duration: const Duration(milliseconds: 150),
                                  child: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.check,
                                        size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                              if (isDisabled)
                                Positioned.fill(
                                  child: Container(
                                      color: Colors.black.withOpacity(0.35)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ปุ่มล่าง: Reset Team (ซ้าย) + ยืนยัน (ขวา)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Reset Team
            FloatingActionButton.extended(
              heroTag: 'resetFab',
              onPressed: _selected.isNotEmpty ? _resetTeam : null,
              backgroundColor:
                  _selected.isNotEmpty ? Colors.redAccent : Colors.grey[300],
              icon: Icon(
                Icons.refresh,
                size: 16,
                color: _selected.isNotEmpty ? Colors.white : Colors.grey[600],
              ),
              label: Text(
                "Reset Team",
                style: TextStyle(
                  color: _selected.isNotEmpty ? Colors.white : Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
            const Spacer(),
            // ยืนยัน
            FloatingActionButton.extended(
              heroTag: 'confirmFab',
              onPressed: _selected.isNotEmpty ? _confirmAndSave : null,
              icon: const Icon(Icons.check, color: Colors.white, size: 14),
              label: const Text(
                "ยืนยัน",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 14),
              ),
              backgroundColor:
                  _selected.isNotEmpty ? Colors.blue : Colors.grey[400],
              elevation: _selected.isNotEmpty ? 6 : 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              extendedPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              hoverElevation: 8,
            ),
          ],
        ),
      ),
    );
  }
}
