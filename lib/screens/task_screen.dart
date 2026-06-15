import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../widgets/division_chip.dart';
import 'main_screen.dart' show buildMenuButton;

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _selectedDivision = 'Semua';
  List<Task> _tasks = [];
  bool _isLoading = true;
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final tasks = await TaskService().getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  List<Task> _filter(TaskStatus? status) {
    final isAdmin = _auth.isSuperAdmin;
    final userDiv = _auth.currentUser?.division ?? '';
    return _tasks.where((t) {
      final matchUserDiv = isAdmin || t.division == userDiv;
      final matchFilter = _selectedDivision == 'Semua' || t.division == _selectedDivision;
      final matchStatus = status == null || t.status == status;
      return matchUserDiv && matchFilter && matchStatus;
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void _changeStatus(Task task, TaskStatus newStatus) async {
    final success = await TaskService().updateTaskStatus(task.id, newStatus.name);
    if (success && mounted) {
      setState(() { task.status = newStatus; });
      final label = newStatus == TaskStatus.done ? 'Selesai ✅' : newStatus == TaskStatus.inProgress ? 'Dikerjakan 🔄' : 'To Do 📋';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Task dipindah ke $label'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Tugas?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Tugas "${task.title}" akan dihapus permanen.', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textMutedOf(context))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await TaskService().deleteTask(task.id);
              if (ok && mounted) {
                setState(() { _tasks.removeWhere((t) => t.id == task.id); });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('🗑️ Tugas berhasil dihapus'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Gagal menghapus tugas'),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAddTask() async {
    String? div = _auth.isSuperAdmin ? (_selectedDivision == 'Semua' ? null : _selectedDivision) : _auth.currentUser?.division;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    List<AppUser> allUsersCache = [];
    List<AppUser> divisionUsers = [];
    String? selectedAssigneeId;
    String? selectedAssigneeName;
    bool loadingUsers = false;

    // Pre-load all users before opening the sheet
    allUsersCache = await UserService().getUsers();
    if (div != null) {
      divisionUsers = allUsersCache.where((u) => u.division == div).toList();
    }
    if (!mounted) return;

    Future<void> reloadUsersForDivision(String division, void Function(void Function()) setSheetState) async {
      setSheetState(() { loadingUsers = true; selectedAssigneeId = null; selectedAssigneeName = null; divisionUsers = []; });
      // Use cached users, no extra API call needed
      final filtered = allUsersCache.where((u) => u.division == division).toList();
      // Small delay to show loading indicator for visual feedback
      await Future.delayed(const Duration(milliseconds: 200));
      setSheetState(() { divisionUsers = filtered; loadingUsers = false; });
    }

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: BoxDecoration(color: AppColors.surfaceOf(context), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderOf(context), borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Text('Tambah Tugas Baru', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimaryOf(context))),
            const SizedBox(height: 4),
            Text('Buat tugas baru untuk divisi Anda', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMutedOf(context))),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Judul tugas', prefixIcon: Icon(Icons.task_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Deskripsi singkat', prefixIcon: Icon(Icons.description_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: div,
              items: AppTheme.divisions.map((d) => DropdownMenuItem(value: d, child: Row(children: [
                Icon(AppColors.getDivisionIcon(d), size: 18, color: AppColors.getDivisionColor(d)),
                const SizedBox(width: 10), Text(d, style: GoogleFonts.inter(fontSize: 14)),
              ]))).toList(),
              onChanged: (v) {
                setSheetState(() => div = v);
                if (v != null) reloadUsersForDivision(v, setSheetState);
              },
              decoration: const InputDecoration(hintText: 'Pilih divisi', prefixIcon: Icon(Icons.group_rounded)),
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryOf(context)),
            ),
            const SizedBox(height: 12),
            // Assignee dropdown - dynamic based on selected division
            if (loadingUsers)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceAltOf(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderOf(context))),
                child: Row(children: [
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 12),
                  Text('Memuat anggota divisi...', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMutedOf(context))),
                ]),
              )
            else if (div == null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceAltOf(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderOf(context))),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMutedOf(context)),
                  const SizedBox(width: 12),
                  Text('Pilih divisi terlebih dahulu', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMutedOf(context))),
                ]),
              )
            else if (divisionUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceAltOf(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderOf(context))),
                child: Row(children: [
                  Icon(Icons.person_off_rounded, size: 16, color: AppColors.textMutedOf(context)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Tidak ada anggota di divisi ini', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMutedOf(context)))),
                ]),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: selectedAssigneeId,
                hint: Text('Pilih anggota', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMutedOf(context))),
                isExpanded: true,
                items: divisionUsers.map((u) => DropdownMenuItem<String>(value: u.id, child: Row(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Center(child: Text(u.name[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  ),
                  const SizedBox(width: 10),
                  Text(u.name, style: GoogleFonts.inter(fontSize: 14), overflow: TextOverflow.ellipsis),
                ]))).toList(),
                onChanged: (v) => setSheetState(() {
                  selectedAssigneeId = v;
                  selectedAssigneeName = divisionUsers.firstWhere((u) => u.id == v).name;
                }),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person_rounded)),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryOf(context)),
              ),
            const SizedBox(height: 12),
            // Due date picker
            Text('Deadline', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryOf(context))),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setSheetState(() => dueDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: AppColors.surfaceAltOf(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderOf(context))),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textMutedOf(context)),
                  const SizedBox(width: 12),
                  Text(DateFormat('dd MMMM yyyy', 'id_ID').format(dueDate), style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimaryOf(context))),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMutedOf(context)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Text('Prioritas', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryOf(context))),
            const SizedBox(height: 8),
            Row(children: TaskPriority.values.map((p) {
              final selected = priority == p;
              final color = p == TaskPriority.high ? AppColors.danger : p == TaskPriority.medium ? AppColors.warning : AppColors.success;
              final label = p == TaskPriority.high ? 'Tinggi' : p == TaskPriority.medium ? 'Sedang' : 'Rendah';
              return Expanded(child: GestureDetector(
                onTap: () => setSheetState(() => priority = p),
                child: Container(
                  margin: EdgeInsets.only(right: p != TaskPriority.high ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: selected ? color.withValues(alpha: 0.12) : AppColors.surfaceAltOf(context), borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? color : AppColors.borderOf(context))),
                  child: Center(child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? color : AppColors.textMutedOf(context)))),
                ),
              ));
            }).toList()),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || div == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: const Text('Judul dan divisi wajib diisi'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                  return;
                }
                final newTask = Task(
                  id: '', title: titleCtrl.text, description: descCtrl.text,
                  division: div!, assignee: selectedAssigneeName ?? '',
                  dueDate: dueDate, priority: priority, status: TaskStatus.todo,
                );
                final success = await TaskService().createTask(newTask, assigneeId: selectedAssigneeId ?? '');
                if (success) {
                  _fetchTasks();
                }
                if (mounted) {
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('\u2705 Tugas berhasil ditambahkan!'), backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                }
              },
              icon: const Icon(Icons.add_rounded, size: 18), label: Text('Tambah Tugas', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
          ])),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: AppColors.backgroundOf(context), body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        leading: buildMenuButton(context),
        title: Text('Task Manager', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surfaceOf(context), surfaceTintColor: Colors.transparent,
        bottom: TabBar(controller: _tabCtrl, labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelColor: AppColors.textMutedOf(context), labelColor: AppColors.primary, indicatorColor: AppColors.primary, indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: 'Semua (${_filter(null).length})'),
            Tab(text: 'To Do (${_filter(TaskStatus.todo).length})'),
            Tab(text: 'Proses (${_filter(TaskStatus.inProgress).length})'),
            Tab(text: 'Selesai (${_filter(TaskStatus.done).length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTask, backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded), label: Text('Task', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        // Division filter (only for SuperAdmin)
        if (_auth.isSuperAdmin)
          SizedBox(height: 52, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), children: [
            DivisionChip(label: 'Semua', selected: _selectedDivision == 'Semua', onTap: () => setState(() => _selectedDivision = 'Semua')),
            const SizedBox(width: 8),
            ...AppTheme.divisions.map((d) => Padding(padding: const EdgeInsets.only(right: 8), child: DivisionChip(label: d, selected: _selectedDivision == d, onTap: () => setState(() => _selectedDivision = d)))),
          ])),
        Expanded(child: TabBarView(controller: _tabCtrl, children: [
          _buildTaskList(null),
          _buildTaskList(TaskStatus.todo),
          _buildTaskList(TaskStatus.inProgress),
          _buildTaskList(TaskStatus.done),
        ])),
      ]),
    );
  }

  Widget _buildTaskList(TaskStatus? status) {
    final tasks = _filter(status);
    if (tasks.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_rounded, size: 48, color: AppColors.textMutedOf(context).withValues(alpha: 0.4)),
        const SizedBox(height: 8),
        Text('Tidak ada task', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMutedOf(context))),
      ]));
    }
    return ListView.builder(padding: const EdgeInsets.fromLTRB(16, 4, 16, 80), itemCount: tasks.length, itemBuilder: (_, i) => _buildTaskCard(tasks[i]));
  }

  Widget _buildTaskCard(Task task) {
    final divColor = AppColors.getDivisionColor(task.division);
    final priorityColor = task.priority == TaskPriority.high ? AppColors.danger : task.priority == TaskPriority.medium ? AppColors.warning : AppColors.success;
    final isOverdue = task.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverdue ? AppColors.danger.withValues(alpha: 0.3) : AppColors.borderOf(context)),
        boxShadow: [BoxShadow(color: AppColors.cardShadowOf(context), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 36, decoration: BoxDecoration(color: divColor, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryOf(context), decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null)),
            if (task.description.isNotEmpty) Text(task.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMutedOf(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          // Priority badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
            child: Text(task.priorityLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.person_rounded, size: 14, color: AppColors.textMutedOf(context)),
          const SizedBox(width: 4),
          Text(task.assignee, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryOf(context))),
          const SizedBox(width: 12),
          Icon(Icons.calendar_today_rounded, size: 12, color: isOverdue ? AppColors.danger : AppColors.textMutedOf(context)),
          const SizedBox(width: 4),
          Text(DateFormat('dd MMM', 'id_ID').format(task.dueDate), style: GoogleFonts.inter(fontSize: 11, color: isOverdue ? AppColors.danger : AppColors.textSecondaryOf(context), fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w400)),
          if (isOverdue) ...[const SizedBox(width: 4), Text('Overdue!', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.danger))],
          const Spacer(),
          // Status change + delete popup
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'delete') {
                _confirmDelete(task);
              } else {
                final status = TaskStatus.values.firstWhere((s) => s.name == val);
                _changeStatus(task, status);
              }
            },
            itemBuilder: (_) => [
              if (task.status != TaskStatus.todo) PopupMenuItem(value: 'todo', child: Row(children: [Icon(Icons.radio_button_unchecked, size: 16, color: AppColors.textMutedOf(context)), const SizedBox(width: 8), Text('To Do', style: GoogleFonts.inter(fontSize: 13))])),
              if (task.status != TaskStatus.inProgress) PopupMenuItem(value: 'inProgress', child: Row(children: [const Icon(Icons.timelapse_rounded, size: 16, color: AppColors.warning), const SizedBox(width: 8), Text('Dikerjakan', style: GoogleFonts.inter(fontSize: 13))])),
              if (task.status != TaskStatus.done) PopupMenuItem(value: 'done', child: Row(children: [const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success), const SizedBox(width: 8), Text('Selesai', style: GoogleFonts.inter(fontSize: 13))])),
              if (_auth.isSuperAdmin) const PopupMenuDivider(),
              if (_auth.isSuperAdmin) PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 16, color: AppColors.danger), const SizedBox(width: 8), Text('Hapus', style: GoogleFonts.inter(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w600))])),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.surfaceAltOf(context), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.borderOf(context))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(task.status == TaskStatus.done ? Icons.check_circle_rounded : task.status == TaskStatus.inProgress ? Icons.timelapse_rounded : Icons.radio_button_unchecked,
                  size: 14, color: task.status == TaskStatus.done ? AppColors.success : task.status == TaskStatus.inProgress ? AppColors.warning : AppColors.textMutedOf(context)),
                const SizedBox(width: 4),
                Text(task.statusLabel, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondaryOf(context))),
                const SizedBox(width: 2), Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.textMutedOf(context)),
              ]),
            ),
          ),
        ]),
      ])),
    );
  }
}
