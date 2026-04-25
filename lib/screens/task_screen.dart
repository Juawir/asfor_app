import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../widgets/division_chip.dart';
import 'main_screen.dart' show mainScaffoldKey;

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _selectedDivision = 'Semua';
  late List<Task> _tasks;
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tasks = List.from(dummyTasks);
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

  void _changeStatus(Task task, TaskStatus newStatus) {
    setState(() { task.status = newStatus; });
    final label = newStatus == TaskStatus.done ? 'Selesai ✅' : newStatus == TaskStatus.inProgress ? 'Dikerjakan 🔄' : 'To Do 📋';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Task dipindah ke $label'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showAddTask() {
    String? div = _auth.isSuperAdmin ? (_selectedDivision == 'Semua' ? null : _selectedDivision) : _auth.currentUser?.division;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final assigneeCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            Text('Tambah Task Baru', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Judul task', prefixIcon: Icon(Icons.task_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Deskripsi singkat', prefixIcon: Icon(Icons.description_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(controller: assigneeCtrl, decoration: const InputDecoration(hintText: 'Assignee', prefixIcon: Icon(Icons.person_rounded)), style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: div,
              items: AppTheme.divisions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(fontSize: 14)))).toList(),
              onChanged: (v) => setSheetState(() => div = v),
              decoration: const InputDecoration(hintText: 'Pilih divisi', prefixIcon: Icon(Icons.group_rounded)),
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text('Prioritas', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
                  decoration: BoxDecoration(color: selected ? color.withValues(alpha: 0.12) : AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? color : AppColors.border)),
                  child: Center(child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? color : AppColors.textMuted))),
                ),
              ));
            }).toList()),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              onPressed: () {
                if (titleCtrl.text.isEmpty || div == null) return;
                setState(() { _tasks.add(Task(id: 'T${_tasks.length + 1}', title: titleCtrl.text, description: descCtrl.text, division: div!, assignee: assigneeCtrl.text.isEmpty ? 'Belum ditugaskan' : assigneeCtrl.text, dueDate: dueDate, priority: priority, status: TaskStatus.todo)); });
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.add_rounded, size: 18), label: Text('Tambah Task', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
          ])),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => mainScaffoldKey.currentState?.openDrawer()),
        title: Text('Task Manager', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent,
        bottom: TabBar(controller: _tabCtrl, labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelColor: AppColors.textMuted, labelColor: AppColors.primary, indicatorColor: AppColors.primary, indicatorSize: TabBarIndicatorSize.label,
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
        Icon(Icons.inbox_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
        const SizedBox(height: 8),
        Text('Tidak ada task', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)),
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
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: isOverdue ? AppColors.danger.withValues(alpha: 0.3) : AppColors.border)),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 4, height: 36, decoration: BoxDecoration(color: divColor, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null)),
            if (task.description.isNotEmpty) Text(task.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
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
          Icon(Icons.person_rounded, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(task.assignee, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Icon(Icons.calendar_today_rounded, size: 12, color: isOverdue ? AppColors.danger : AppColors.textMuted),
          const SizedBox(width: 4),
          Text(DateFormat('dd MMM', 'id_ID').format(task.dueDate), style: GoogleFonts.inter(fontSize: 11, color: isOverdue ? AppColors.danger : AppColors.textSecondary, fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w400)),
          if (isOverdue) ...[const SizedBox(width: 4), Text('Overdue!', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.danger))],
          const Spacer(),
          // Status change popup
          PopupMenuButton<TaskStatus>(
            onSelected: (s) => _changeStatus(task, s),
            itemBuilder: (_) => [
              if (task.status != TaskStatus.todo) PopupMenuItem(value: TaskStatus.todo, child: Row(children: [const Icon(Icons.radio_button_unchecked, size: 16, color: AppColors.textMuted), const SizedBox(width: 8), Text('To Do', style: GoogleFonts.inter(fontSize: 13))])),
              if (task.status != TaskStatus.inProgress) PopupMenuItem(value: TaskStatus.inProgress, child: Row(children: [const Icon(Icons.timelapse_rounded, size: 16, color: AppColors.warning), const SizedBox(width: 8), Text('Dikerjakan', style: GoogleFonts.inter(fontSize: 13))])),
              if (task.status != TaskStatus.done) PopupMenuItem(value: TaskStatus.done, child: Row(children: [const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success), const SizedBox(width: 8), Text('Selesai', style: GoogleFonts.inter(fontSize: 13))])),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(task.status == TaskStatus.done ? Icons.check_circle_rounded : task.status == TaskStatus.inProgress ? Icons.timelapse_rounded : Icons.radio_button_unchecked,
                  size: 14, color: task.status == TaskStatus.done ? AppColors.success : task.status == TaskStatus.inProgress ? AppColors.warning : AppColors.textMuted),
                const SizedBox(width: 4),
                Text(task.statusLabel, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(width: 2), const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.textMuted),
              ]),
            ),
          ),
        ]),
      ])),
    );
  }
}
