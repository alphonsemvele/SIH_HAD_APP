import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/visits_service.dart';
import '../models/visit.dart';

class VisitsListScreen extends StatefulWidget {
  const VisitsListScreen({super.key});

  @override
  State<VisitsListScreen> createState() => _VisitsListScreenState();
}

class _VisitsListScreenState extends State<VisitsListScreen> {
  final _service = VisitsService();
  List<Visit> _visites = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final v = await _service.getVisites();
      if (!mounted) return;
      setState(() {
        _visites = v;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Mes visites HAD',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.error_outline, color: AppColors.accent, size: 56),
          const SizedBox(height: 16),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Réessayer'),
          ),
        ],
      );
    }
    if (_visites.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          Icon(Icons.event_busy, color: Colors.white.withValues(alpha: 0.3), size: 80),
          const SizedBox(height: 20),
          const Text('Aucune visite prévue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Vos prochaines visites HAD apparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visites.length,
      itemBuilder: (_, i) => _visitCard(_visites[i]),
    );
  }

  Widget _visitCard(Visit v) {
    final isTerminee = v.estTerminee;
    final color = isTerminee ? AppColors.success : AppColors.accent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isTerminee ? Icons.check_circle : Icons.schedule, color: color, size: 20),
              const SizedBox(width: 8),
              Text(v.statutLabel,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (v.date != null)
                Text(v.date!,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          if (v.heure != null) ...[
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.5), size: 16),
                const SizedBox(width: 6),
                Text(
                  v.dureeMinutes != null ? '${v.heure} (${v.dureeMinutes} min)' : v.heure!,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (v.soignantName != null) ...[
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.5), size: 16),
                const SizedBox(width: 6),
                Text(v.soignantName!,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
              ],
            ),
          ],
          if (v.notes != null && v.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(v.notes!,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}
