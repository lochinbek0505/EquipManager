import 'package:flutter/material.dart';

import '../user/firebase_service.dart';

class StatisPage extends StatefulWidget {
  @override
  _StatisPageState createState() => _StatisPageState();
}

class _StatisPageState extends State<StatisPage> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? stats;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // Функция для получения статистики
  Future<void> _fetchStats() async {
    stats = await _firebaseService.getDeviceStats();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Статистика устройств",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body:
          stats == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Статистика устройств',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text("Активные устройства"),
                        trailing: Text(
                          '${stats!['active']}',
                          style: TextStyle(fontSize: 20, color: Colors.green),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text("Ожидающие устройства (Wait)"),
                        trailing: Text(
                          '${stats!['wait']}',
                          style: TextStyle(fontSize: 20, color: Colors.orange),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text("Отклоненные устройства"),
                        trailing: Text(
                          '${stats!['reject']}',
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Можно добавить график для статистики (например, круговая диаграмма)
                    Center(
                      child: Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        child: CustomPaint(
                          painter: PieChartPainter(
                            stats!['active'],
                            stats!['wait'],
                            stats!['reject'],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

// Кастомный рисователь для диаграммы
class PieChartPainter extends CustomPainter {
  final int active;
  final int wait;
  final int reject;

  PieChartPainter(this.active, this.wait, this.reject);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 3;

    double activeAngle = 2 * 3.14 * (active / (active + wait + reject));
    double waitAngle = 2 * 3.14 * (wait / (active + wait + reject));
    double rejectAngle = 2 * 3.14 * (reject / (active + wait + reject));

    // Активные устройства - зеленый
    paint.color = Colors.green;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -3.14 / 2,
      activeAngle,
      true,
      paint,
    );

    // Ожидающие устройства - оранжевый
    paint.color = Colors.orange;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -3.14 / 2 + activeAngle,
      waitAngle,
      true,
      paint,
    );

    // Отклоненные устройства - красный
    paint.color = Colors.red;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -3.14 / 2 + activeAngle + waitAngle,
      rejectAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
