import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/election.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/election_service.dart';
import '../services/user_service.dart';
import 'main_screen.dart' show mainScaffoldKey;

class ElectionScreen extends StatefulWidget {
  const ElectionScreen({super.key});
  @override
  State<ElectionScreen> createState() => _ElectionScreenState();
}

class _ElectionScreenState extends State<ElectionScreen> with TickerProviderStateMixin {
  final _auth = AuthService();
  final _electionService = ElectionService();
  Election? _election;
  bool _isLoading = true;
  bool _hasVoted = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _loadElection();
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  Future<void> _loadElection() async {
    final election = await _electionService.getElection();
    final userId = _auth.currentUser?.id ?? '';
    final voted = election?.hasVoted(userId) ?? false;
    if (mounted) setState(() { _election = election; _hasVoted = voted; _isLoading = false; });
  }

  // ── Admin: Create Election ──
  void _showCreateElection() async {
    final titleCtrl = TextEditingController();
    final allUsers = await UserService().getUsers();
    final selected = <AppUser>{};

    if (!mounted) return;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.how_to_vote_rounded, color: Color(0xFF7C3AED), size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Buat Pemilihan Baru', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('Pilih kandidat dari daftar anggota', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              ])),
            ]),
            const SizedBox(height: 20),
            TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Judul Pemilihan (cth: Ketua Aslab 2026)', prefixIcon: Icon(Icons.title_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('Pilih Kandidat (${selected.length} dipilih)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
            const SizedBox(height: 8),
            Flexible(child: ListView.builder(
              shrinkWrap: true, itemCount: allUsers.length,
              itemBuilder: (_, i) {
                final u = allUsers[i];
                final isSel = selected.contains(u);
                final color = AppColors.getDivisionColor(u.division);
                return GestureDetector(
                  onTap: () => setSheet(() => isSel ? selected.remove(u) : selected.add(u)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF7C3AED).withValues(alpha: 0.06) : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSel ? const Color(0xFF7C3AED) : AppColors.border, width: isSel ? 2 : 1),
                    ),
                    child: Row(children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]), shape: BoxShape.circle),
                        child: Center(child: Text(u.name[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(u.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text(u.division, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                      ])),
                      AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: isSel
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF7C3AED), size: 24, key: ValueKey(true))
                        : const Icon(Icons.circle_outlined, color: AppColors.border, size: 24, key: ValueKey(false))),
                    ]),
                  ),
                );
              },
            )),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () async {
                if (titleCtrl.text.isEmpty || selected.length < 2) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(selected.length < 2 ? 'Minimal 2 kandidat' : 'Judul wajib diisi'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                  return;
                }
                final candidates = selected.map((u) => Candidate(userId: u.id, name: u.name, division: u.division)).toList();
                await _electionService.createElection(titleCtrl.text.trim(), candidates);
                if (mounted) Navigator.pop(ctx);
                _loadElection();
              },
              icon: const Icon(Icons.rocket_launch_rounded, size: 18),
              label: Text('Mulai Pemilihan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
          ]),
        );
      }),
    );
  }

  // ── User: Vote ──
  void _confirmVote(Candidate candidate) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        const Icon(Icons.how_to_vote_rounded, color: Color(0xFF7C3AED)),
        const SizedBox(width: 8),
        Text('Konfirmasi Pilihan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.getDivisionColor(candidate.division), AppColors.getDivisionColor(candidate.division).withValues(alpha: 0.7)]), shape: BoxShape.circle),
          child: Center(child: Text(candidate.name[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white))),
        ),
        const SizedBox(height: 12),
        Text(candidate.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(candidate.division, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(child: Text('Pilihan tidak dapat diubah setelah dikonfirmasi!', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.warning))),
          ]),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
          onPressed: () async {
            Navigator.pop(ctx);
            final userId = _auth.currentUser?.id ?? '';
            final result = await _electionService.castVote(candidate.userId, userId);
            if (result == null) {
              _loadElection();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('🎉 Suara berhasil diberikan!'), backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            } else {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
            }
          },
          child: Text('Ya, Pilih', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }

  // ── Admin: End Election ──
  void _confirmEndElection() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Akhiri Pemilihan?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text('Setelah diakhiri, tidak ada lagi yang bisa memberikan suara.', style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ElevatedButton(
          onPressed: () async { Navigator.pop(ctx); await _electionService.endElection(); _loadElection(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          child: Text('Akhiri', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }

  void _confirmDeleteElection() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus Pemilihan?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text('Data pemilihan dan seluruh suara akan dihapus permanen.', style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ElevatedButton(
          onPressed: () async { Navigator.pop(ctx); await _electionService.deleteElection(); _loadElection(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          child: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));
    final isAdmin = _auth.isSuperAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        // ── Header ──
        SliverAppBar(
          expandedHeight: 140, floating: false, pinned: true,
          backgroundColor: const Color(0xFF7C3AED),
          leading: IconButton(icon: const Icon(Icons.menu_rounded, color: Colors.white), onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
          actions: isAdmin ? [
            if (_election != null && _election!.isActive)
              IconButton(icon: const Icon(Icons.stop_circle_outlined, color: Colors.white), tooltip: 'Akhiri Pemilihan', onPressed: _confirmEndElection),
            if (_election != null)
              IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.white), tooltip: 'Hapus Pemilihan', onPressed: _confirmDeleteElection),
          ] : null,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.how_to_vote_rounded, color: Colors.white, size: 26)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Pemilihan', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Calon Ketua Aslab', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ])),
                ]),
              ]),
            ),
          ),
        ),

        // ── Body ──
        SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverList(delegate: SliverChildListDelegate([
          if (_election == null) _buildEmptyState(isAdmin)
          else ...[
            _buildElectionHeader(),
            const SizedBox(height: 16),
            if (_hasVoted && _election!.isActive) _buildVotedBanner(),
            if (_election!.isCompleted) _buildResultsSection(),
            if (!_election!.isCompleted && isAdmin) _buildAdminLiveResults(),
            const SizedBox(height: 12),
            Text(_election!.isCompleted ? 'Hasil Akhir' : 'Daftar Kandidat', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...(_election!.candidates.toList()..sort((a, b) => b.votes.compareTo(a.votes))).asMap().entries.map((e) => _buildCandidateCard(e.value, e.key)),
            const SizedBox(height: 60),
          ],
        ]))),
      ]),
      floatingActionButton: isAdmin && _election == null ? FloatingActionButton.extended(
        onPressed: _showCreateElection, backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded), label: Text('Buat Pemilihan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ) : null,
    );
  }

  Widget _buildEmptyState(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        AnimatedBuilder(animation: _pulseCtrl, builder: (_, __) {
          return Transform.scale(scale: 1 + _pulseCtrl.value * 0.05,
            child: Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.how_to_vote_rounded, size: 40, color: Color(0xFF7C3AED))));
        }),
        const SizedBox(height: 20),
        Text('Belum Ada Pemilihan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(isAdmin ? 'Buat sesi pemilihan baru dengan\nmenekan tombol di bawah' : 'Belum ada pemilihan yang dibuka\noleh administrator',
          textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted, height: 1.5)),
      ]),
    );
  }

  Widget _buildElectionHeader() {
    final e = _election!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF7C3AED).withValues(alpha: 0.08), const Color(0xFF4F46E5).withValues(alpha: 0.04)]),
        borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(e.isActive ? Icons.how_to_vote_rounded : Icons.emoji_events_rounded, color: const Color(0xFF7C3AED), size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (e.isActive ? AppColors.success : AppColors.textMuted).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
              child: Text(e.isActive ? '🟢 Aktif' : '🏁 Selesai', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: e.isActive ? AppColors.success : AppColors.textMuted))),
            const SizedBox(width: 8),
            Text('${e.totalVotes} suara • ${e.candidates.length} kandidat', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ])),
      ]),
    );
  }

  Widget _buildVotedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Terima kasih sudah memilih! 🎉', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
          Text('Suara Anda telah tercatat dengan aman', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }

  Widget _buildResultsSection() {
    final winner = _election!.winner;
    if (winner == null || _election!.totalVotes == 0) return const SizedBox();
    final color = AppColors.getDivisionColor(winner.division);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFFBBF24).withValues(alpha: 0.15), const Color(0xFFF59E0B).withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
      ),
      child: Column(children: [
        const Text('🏆', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text('Pemenang', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warning)),
        const SizedBox(height: 4),
        Container(width: 56, height: 56, decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFBBF24), width: 3)),
          child: Center(child: Text(winner.name[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)))),
        const SizedBox(height: 8),
        Text(winner.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text('${winner.division} • ${winner.votes} suara', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildAdminLiveResults() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.info.withValues(alpha: 0.2))),
      child: Row(children: [
        const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.info),
        const SizedBox(width: 8),
        Text('Live: ${_election!.totalVotes} suara masuk', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.info)),
        const Spacer(),
        GestureDetector(onTap: _loadElection, child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.info)),
      ]),
    );
  }

  Widget _buildCandidateCard(Candidate candidate, int rank) {
    final color = AppColors.getDivisionColor(candidate.division);
    final e = _election!;
    final pct = e.totalVotes > 0 ? candidate.votes / e.totalVotes : 0.0;
    final showResults = e.isCompleted || _auth.isSuperAdmin;
    final canVote = e.isActive && !_hasVoted && !_auth.isSuperAdmin;
    final isWinner = e.isCompleted && rank == 0 && e.totalVotes > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isWinner ? const Color(0xFFFBBF24) : AppColors.border, width: isWinner ? 2 : 1),
        boxShadow: [if (isWinner) BoxShadow(color: const Color(0xFFFBBF24).withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]), shape: BoxShape.circle),
            child: Center(child: Text(candidate.name[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(candidate.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
              if (isWinner) ...[ const SizedBox(width: 6), const Text('🏆', style: TextStyle(fontSize: 16)) ],
            ]),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
              child: Text(candidate.division, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
          ])),
          if (canVote)
            ElevatedButton(
              onPressed: () => _confirmVote(candidate),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Pilih', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
        ]),
        if (showResults) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(color)))),
            const SizedBox(width: 12),
            Text('${candidate.votes} suara', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            Text('(${(pct * 100).toStringAsFixed(1)}%)', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
          ]),
        ],
      ])),
    );
  }
}
