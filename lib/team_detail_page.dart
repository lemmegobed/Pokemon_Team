import 'dart:math';
import 'package:flutter/material.dart';

class TeamDetailPage extends StatelessWidget {
  final Map<String, dynamic> team;
  const TeamDetailPage({super.key, required this.team});

  // ดึงสมาชิกแบบปลอดภัย รองรับได้ทั้ง team['members'] / team['pokemons']
  List<Map<String, dynamic>> _extractMembers(Map<String, dynamic> t) {
    final raw = t['members'] ?? t['pokemons'] ?? [];
    if (raw is List) {
      return raw.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{};
      }).where((m) => m.isNotEmpty).toList();
    }
    return <Map<String, dynamic>>[];
  }

  // สุ่มคะแนนทีม (1 - 100)
  int _generateScore() {
    final rnd = Random();
    return 50 + rnd.nextInt(51); // 50 - 100
  }

  @override
  Widget build(BuildContext context) {
    final String name = (team['name'] ?? 'Unnamed Team').toString();
    final members = _extractMembers(team);
    final score = _generateScore();

    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียดทีม: $name')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.stars, color: Colors.orange, size: 36),
                title: Text('Team Score', style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(
                  '$score / 100',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: members.isEmpty
                  ? const Center(child: Text('ยังไม่มีสมาชิกในทีมนี้'))
                  : ListView.separated(
                      itemCount: members.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final m = members[i];
                        final monName = (m['name'] ?? '').toString();
                        // รองรับทั้ง 'image' และ 'imageUrl'
                        final img = (m['image'] ?? m['imageUrl'] ?? '').toString();
                        final typesVal = m['types'];
                        final types = (typesVal is List)
                            ? typesVal.join(', ')
                            : typesVal?.toString() ?? '-';

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: ClipOval(
                              child: (img.isNotEmpty)
                                  ? Image.network(img, width: 48, height: 48, fit: BoxFit.cover)
                                  : const SizedBox(width: 48, height: 48),
                            ),
                            title: Text(monName.isEmpty ? '(no name)' : monName),
                            subtitle: Text('Types: $types'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
