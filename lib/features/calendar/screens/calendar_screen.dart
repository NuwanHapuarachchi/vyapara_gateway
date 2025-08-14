import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/neumorphic_widgets.dart';
import '../models/event_model.dart';
import '../widgets/event_form_dialog.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  Map<String, List<Event>> _eventsByDate = {};
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<String> _weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = SupabaseService.getAllEvents();
    });
    _eventsFuture.then((eventsData) {
      _processEvents(eventsData);
    });
  }

  void _processEvents(List<Map<String, dynamic>> eventsData) {
    final events = eventsData.map((data) => Event.fromJson(data)).toList();
    final eventsByDate = <String, List<Event>>{};

    for (final event in events) {
      final dateKey = _dateKey(event.startAt);
      if (eventsByDate[dateKey] == null) {
        eventsByDate[dateKey] = [];
      }
      eventsByDate[dateKey]!.add(event);
    }

    setState(() {
      _eventsByDate = eventsByDate;
    });
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          'Calendar',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadEvents,
            tooltip: 'Refresh Events',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _slideAnimation.value)),
            child: Opacity(
              opacity: _slideAnimation.value.clamp(0.0, 1.0),
              child: Column(
                children: [
                  // Calendar Header
                  _buildCalendarHeader(),

                  // Calendar Grid
                  _buildCalendarGrid(),

                  // Events Section
                  Expanded(child: _buildEventsSection()),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Month Button
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(
                  _focusedDate.year,
                  _focusedDate.month - 1,
                );
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 1),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Month and Year
          Column(
            children: [
              Text(
                _months[_focusedDate.month - 1],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_focusedDate.year}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Next Month Button
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(
                  _focusedDate.year,
                  _focusedDate.month + 1,
                );
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 1),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        children: [
          // Week Days Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays
                .map(
                  (day) => Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar Days Grid
          ..._buildCalendarWeeks(),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    List<Widget> weeks = [];
    DateTime firstDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month,
      1,
    );

    int startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    DateTime startDate = firstDayOfMonth.subtract(Duration(days: startWeekday));

    for (int week = 0; week < 6; week++) {
      List<Widget> weekDays = [];

      for (int day = 0; day < 7; day++) {
        DateTime date = startDate.add(Duration(days: week * 7 + day));
        bool isCurrentMonth = date.month == _focusedDate.month;
        bool isToday =
            date.day == DateTime.now().day &&
            date.month == DateTime.now().month &&
            date.year == DateTime.now().year;
        bool isSelected =
            date.day == _selectedDate.day &&
            date.month == _selectedDate.month &&
            date.year == _selectedDate.year;

        final dateKey = _dateKey(date);
        final hasEvents = _eventsByDate[dateKey]?.isNotEmpty == true;

        weekDays.add(
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            onLongPress: () => _showEventDialog(selectedDate: date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 35,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : isToday
                    ? AppColors.accent.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.accent, width: 1)
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      '${date.day}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? AppColors.accent
                            : isCurrentMonth
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ),
                  if (hasEvents && !isSelected)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }

      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays,
          ),
        ),
      );

      // Stop if we've passed the last day of the month and completed the week
      DateTime lastDateInWeek = startDate.add(Duration(days: week * 7 + 6));
      if (lastDateInWeek.month != _focusedDate.month && week > 3) break;
    }

    return weeks;
  }

  Widget _buildEventsSection() {
    final selectedDateKey = _dateKey(_selectedDate);
    final eventsForSelectedDate = _eventsByDate[selectedDateKey] ?? [];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_selectedDate.day} ${_months[_selectedDate.month - 1]}, ${_selectedDate.year}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showEventDialog(selectedDate: _selectedDate),
                icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
                tooltip: 'Add Event',
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: eventsForSelectedDate.isEmpty
                ? _buildEmptyEventsState()
                : ListView.separated(
                    itemCount: eventsForSelectedDate.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = eventsForSelectedDate[index];
                      return _buildEventCard(event, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: Icon(
              Icons.event_available,
              size: 60,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No events for this day',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create a new event',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          NeumorphicButton(
            text: 'Add Event',
            onPressed: () => _showEventDialog(selectedDate: _selectedDate),
            isGreen: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () => _showEventDialog(event: event),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: event.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        event.type.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: event.priority.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  event.priority.displayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: event.priority.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.timeRange,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (event.location != null) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location!,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (event.description != null &&
                              event.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              event.description!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: AppColors.cardDark,
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showEventDialog(event: event);
                            break;
                          case 'delete':
                            _deleteEvent(event);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Edit',
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 16,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEventDialog({Event? event, DateTime? selectedDate}) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        event: event,
        selectedDate: selectedDate ?? _selectedDate,
        onSave: (eventData) async {
          if (event != null) {
            // Update existing event
            final updatedEvent = await SupabaseService.updateEvent(
              event.id,
              eventData,
            );
            if (updatedEvent != null) {
              _showSnackBar('Event updated successfully', isError: false);
              _loadEvents();
            } else {
              _showSnackBar('Failed to update event', isError: true);
            }
          } else {
            // Create new event
            final newEvent = await SupabaseService.createEvent(eventData);
            if (newEvent != null) {
              _showSnackBar('Event created successfully', isError: false);
              _loadEvents();
            } else {
              _showSnackBar('Failed to create event', isError: true);
            }
          }
        },
      ),
    );
  }

  void _deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'Delete Event',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await SupabaseService.deleteEvent(event.id);
              if (success) {
                _showSnackBar('Event deleted successfully', isError: false);
                _loadEvents();
              } else {
                _showSnackBar('Failed to delete event', isError: true);
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: isError ? AppColors.error : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
