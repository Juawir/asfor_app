import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import 'main_screen.dart' show mainScaffoldKey;

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _service = EventService();
  List<AppEvent> _events = [];
  bool _loading = true;
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _loading = true);
    final result = await _service.getEvents(
      month: _focusedMonth.month,
      year: _focusedMonth.year,
    );
    if (mounted) setState(() { _events = result; _loading = false; });
  }

  void _prevMonth() {
    setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));
    _fetchEvents();
  }

  void _nextMonth() {
    setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));
    _fetchEvents();
  }

  List<AppEvent> _eventsOnDay(DateTime day) {
    return _events.where((e) =>
      e.eventDate.year == day.year &&
      e.eventDate.month == day.month &&
      e.eventDate.day == day.day
    ).toList();
  }

  void _showEventForm([AppEvent? existing]) {
    final user = AuthService().currentUser;
    final isAdmin = user?.role == 'admin';

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    DateTime pickedDate = existing?.eventDate ?? DateTime.now();
    TimeOfDay? pickedTime = existing?.eventTime != null
        ? TimeOfDay(
            hour: int.parse(existing!.eventTime!.split(':')[0]),
            minute: int.parse(existing.eventTime!.split(':')[1]),
          )
        : null;
    String division = existing?.division ?? (isAdmin ? 'Semua' : (user?.division ?? 'Semua'));
    bool saving = false;

    final divisions = isAdmin
        ? ['Semua', 'Hubungan Masyarakat', 'IT Support', 'Pemrograman', 'Training', 'Bidang Usaha']
        : ['Semua', user?.division ?? 'Semua'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              Text(existing == null ? 'Tambah Kegiatan' : 'Edit Kegiatan',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 20),

              // Title
              _sheetLabel('Judul Kegiatan'),
              TextField(controller: titleCtrl, enabled: !saving,
                decoration: const InputDecoration(hintText: 'Nama kegiatan / acara', prefixIcon: Icon(Icons.event_rounded)),
                style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(height: 14),

              // Date picker
              _sheetLabel('Tanggal Kegiatan'),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: pickedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setSheet(() => pickedDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text('${pickedDate.day}/${pickedDate.month}/${pickedDate.year}',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
                  ]),
                ),
              ),
              const SizedBox(height: 14),

              // Time picker
              _sheetLabel('Waktu (Opsional)'),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(context: ctx, initialTime: pickedTime ?? TimeOfDay.now());
                  if (t != null) setSheet(() => pickedTime = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(pickedTime != null ? pickedTime!.format(ctx) : 'Pilih waktu (opsional)',
                      style: GoogleFonts.inter(fontSize: 14, color: pickedTime != null ? AppColors.textPrimary : AppColors.textMuted)),
                    const Spacer(),
                    if (pickedTime != null)
                      GestureDetector(onTap: () => setSheet(() => pickedTime = null),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted)),
                  ]),
                ),
              ),
              const SizedBox(height: 14),

              // Division
              _sheetLabel('Divisi'),
              DropdownButtonFormField<String>(
                value: division,
                items: divisions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(fontSize: 14)))).toList(),
                onChanged: saving ? null : (v) => setSheet(() => division = v!),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.group_rounded)),
              ),
              const SizedBox(height: 14),

              // Location
              _sheetLabel('Lokasi (Opsional)'),
              TextField(controller: locationCtrl, enabled: !saving,
                decoration: const InputDecoration(hintText: 'Ruangan / Gedung / URL Meet', prefixIcon: Icon(Icons.location_on_rounded)),
                style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(height: 14),

              // Description
              _sheetLabel('Keterangan'),
              TextField(controller: descCtrl, enabled: !saving, maxLines: 3,
                decoration: const InputDecoration(hintText: 'Deskripsi kegiatan...', alignLabelWithHint: true),
                style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(height: 24),

              // Button
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                onPressed: saving ? null : () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul kegiatan wajib diisi')));
                    return;
                  }
                  setSheet(() => saving = true);

                  final newEvent = AppEvent(
                    id: existing?.id ?? '',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    eventDate: pickedDate,
                    eventTime: pickedTime != null
                        ? '${pickedTime!.hour.toString().padLeft(2, '0')}:${pickedTime!.minute.toString().padLeft(2, '0')}'
                        : null,
                    location: locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
                    division: division,
                    createdBy: user?.id.toString() ?? '',
                  );

                  bool ok;
                  if (existing == null) {
                    final created = await _service.createEvent(newEvent);
                    ok = created != null;
                  } else {
                    ok = await _service.updateEvent(existing.id, newEvent);
                  }

                  if (mounted) {
                    Navigator.pop(ctx);
                    if (ok) {
                      _fetchEvents();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(existing == null ? 'Kegiatan berhasil ditambahkan!' : 'Kegiatan berhasil diperbarui!'),
                        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan kegiatan'), backgroundColor: AppColors.danger));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(saving ? 'Menyimpan...' : (existing == null ? 'Tambah Kegiatan' : 'Simpan Perubahan'),
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
              )),
            ],
          )),
        );
      }),
    );
  }

  void _deleteEvent(AppEvent event) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus Kegiatan?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Text('Kegiatan "${event.title}" akan dihapus permanen.', style: GoogleFonts.inter(fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await _service.deleteEvent(event.id);
            if (ok) {
              _fetchEvents();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kegiatan dihapus'), backgroundColor: AppColors.success));
            }
          },
          child: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isAdmin = user?.role == 'admin';
    final monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Build calendar grid
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    int startWeekday = firstDay.weekday; // 1=Mon, 7=Sun

    // Upcoming events (sorted)
    final now = DateTime.now();
    final upcomingEvents = _events.where((e) => !e.isPast || e.isToday).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    final pastEvents = _events.where((e) => e.isPast && !e.isToday).toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        title: Text('Dashboard Kegiatan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEventForm,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEvents,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- Calendar Header ---
                  Container(
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                    child: Column(children: [
                      // Month Nav
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Row(children: [
                          IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary)),
                          Expanded(child: Center(child: Text(
                            '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ))),
                          IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary)),
                        ]),
                      ),
                      // Day Headers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: dayNames.map((d) => SizedBox(width: 40,
                            child: Center(child: Text(d, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)))
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Calendar Grid
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 2, childAspectRatio: 1),
                          itemCount: (startWeekday - 1) + daysInMonth,
                          itemBuilder: (ctx, i) {
                            if (i < startWeekday - 1) return const SizedBox();
                            final day = i - (startWeekday - 1) + 1;
                            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                            final eventsOnDay = _eventsOnDay(date);
                            final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                            final hasEvents = eventsOnDay.isNotEmpty;

                            return GestureDetector(
                              onTap: hasEvents ? () {
                                _showDayEventsSheet(date, eventsOnDay, isAdmin, user?.id.toString() ?? '');
                              } : null,
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: isToday ? AppColors.primary : (hasEvents ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('$day', style: GoogleFonts.inter(
                                      fontSize: 13, fontWeight: isToday || hasEvents ? FontWeight.w700 : FontWeight.w400,
                                      color: isToday ? Colors.white : (hasEvents ? AppColors.primary : AppColors.textPrimary),
                                    )),
                                    if (hasEvents) Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(color: isToday ? Colors.white70 : AppColors.primary, shape: BoxShape.circle)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // --- Upcoming Events ---
                  if (upcomingEvents.isNotEmpty) ...[
                    Text('Kegiatan Mendatang', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    ...upcomingEvents.map((e) => _eventCard(e, isAdmin, user?.id.toString() ?? '')),
                    const SizedBox(height: 16),
                  ],

                  // --- Past Events ---
                  if (pastEvents.isNotEmpty) ...[
                    Text('Kegiatan Selesai', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 10),
                    ...pastEvents.map((e) => _eventCard(e, isAdmin, user?.id.toString() ?? '', isPast: true)),
                  ],

                  if (_events.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(children: [
                        Icon(Icons.event_busy_rounded, size: 60, color: AppColors.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('Tidak ada kegiatan bulan ini', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
                        const SizedBox(height: 6),
                        Text('Tap tombol + untuk menambahkan kegiatan', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                      ]),
                    )),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  void _showDayEventsSheet(DateTime date, List<AppEvent> events, bool isAdmin, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Text('Kegiatan ${date.day}/${date.month}/${date.year}',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...events.map((e) => _eventCard(e, isAdmin, userId, inSheet: true)),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(AppEvent event, bool isAdmin, String userId, {bool isPast = false, bool inSheet = false}) {
    final canEdit = isAdmin || event.createdBy == userId;
    final divColor = _divColor(event.division);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 44, padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isPast ? AppColors.surfaceAlt : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${event.eventDate.day}', style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: isPast ? AppColors.textMuted : AppColors.primary,
              )),
              Text(_shortMonth(event.eventDate.month), style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: isPast ? AppColors.textMuted : AppColors.primary,
              )),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: divColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
                  child: Text(event.division, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: divColor)),
                ),
                if (event.isToday) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(50)),
                    child: Text('HARI INI', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ),
                ],
              ]),
              const SizedBox(height: 6),
              Text(event.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isPast ? AppColors.textMuted : AppColors.textPrimary)),
              if (event.eventTime != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(event.eventTime!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                ]),
              ],
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(child: Text(event.location!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
                ]),
              ],
              if (event.creatorName != null) ...[
                const SizedBox(height: 4),
                Text('oleh ${event.creatorName}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
              ],
            ]),
          ),
          if (canEdit)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (!inSheet) {}
                if (val == 'edit') _showEventForm(event);
                if (val == 'delete') _deleteEvent(event);
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text('Edit', style: GoogleFonts.inter(fontSize: 13))])),
                PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_rounded, size: 16, color: AppColors.danger), const SizedBox(width: 8), Text('Hapus', style: GoogleFonts.inter(fontSize: 13, color: AppColors.danger))])),
              ],
            ),
        ],
      ),
    );
  }

  Color _divColor(String div) {
    switch (div) {
      case 'IT Support': return const Color(0xFF6366F1);
      case 'Pemrograman': return const Color(0xFF0EA5E9);
      case 'Hubungan Masyarakat': return const Color(0xFFEC4899);
      case 'Training': return const Color(0xFFF59E0B);
      case 'Bidang Usaha': return const Color(0xFF10B981);
      default: return AppColors.primary;
    }
  }

  String _shortMonth(int m) => ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'][m - 1];

  Widget _sheetLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
  );
}
