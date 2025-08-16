import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calendar_event.dart';
import '../models/event_participant.dart';

class CalendarService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Get all events for the current user (private + public + invited)
  Future<List<CalendarEvent>> getEvents() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('calendar_events')
          .select()
          .or('creator_id.eq.$userId,visibility.eq.public')
          .order('start_date', ascending: true);

      return response
          .map((json) {
            try {
              return CalendarEvent.fromJson(json);
            } catch (e) {
              print('Error parsing event: $e');
              return null;
            }
          })
          .whereType<CalendarEvent>()
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Failed to fetch events: $e');
    }
  }

  // Get events for a specific date range for current user
  Future<List<CalendarEvent>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('calendar_events')
          .select()
          .gte('start_date', startDate.toIso8601String().split('T')[0])
          .lte('start_date', endDate.toIso8601String().split('T')[0])
          .or('creator_id.eq.$userId,visibility.eq.public')
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events by date range: $e');
    }
  }

  // Get events for today for current user
  Future<List<CalendarEvent>> getTodayEvents() async {
    final today = DateTime.now();
    return getEventsByDateRange(today, today);
  }

  // Get upcoming events for current user
  Future<List<CalendarEvent>> getUpcomingEvents() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final response = await _supabase
          .from('calendar_events')
          .select()
          .gte('start_date', today.toIso8601String().split('T')[0])
          .or('creator_id.eq.$userId,visibility.eq.public')
          .order('start_date', ascending: true)
          .limit(10);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming events: $e');
    }
  }

  // Create a new event (automatically private for the creator)
  Future<CalendarEvent> createEvent(Map<String, dynamic> eventData) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Ensure the event is created by the current user
      final eventWithCreator = {
        ...eventData,
        'creator_id': userId,
        'visibility':
            eventData['visibility'] ?? 'private', // Default to private
      };

      final response = await _supabase
          .from('calendar_events')
          .insert(eventWithCreator)
          .select()
          .single();

      return CalendarEvent.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  // Create an appointment from business application
  Future<CalendarEvent> createAppointmentFromApplication({
    required String applicationId,
    required String title,
    required String description,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String location,
    String? notes,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final appointmentData = {
        'creator_id': userId,
        'application_id': applicationId,
        'title': title,
        'description': description,
        'event_type': 'business_appointment',
        'status': 'scheduled',
        'visibility': 'private', // Appointments are private by default
        'start_date': appointmentDate.toIso8601String().split('T')[0],
        'start_time': appointmentTime,
        'end_date': appointmentDate.toIso8601String().split('T')[0],
        'end_time': _addOneHour(appointmentTime),
        'location': location,
        'is_online': false,
        'reminder_minutes': 30,
        'send_email_reminder': true,
        'send_sms_reminder': false,
        'send_push_reminder': true,
        'color': '#10B981', // Green for appointments
        'notes': notes,
      };

      final response = await _supabase
          .from('calendar_events')
          .insert(appointmentData)
          .select()
          .single();

      return CalendarEvent.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Create a simple appointment (for quick creation)
  Future<CalendarEvent> createSimpleAppointment({
    required String title,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String location,
    String? description,
    String? notes,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final appointmentData = {
        'creator_id': userId,
        'title': title,
        'description': description,
        'event_type': 'business_appointment',
        'status': 'scheduled',
        'visibility': 'private', // Always private for quick appointments
        'start_date': appointmentDate.toIso8601String().split('T')[0],
        'start_time': appointmentTime,
        'end_date': appointmentDate.toIso8601String().split('T')[0],
        'end_time': _addOneHour(appointmentTime),
        'location': location,
        'is_online': false,
        'reminder_minutes': 30,
        'send_email_reminder': true,
        'send_sms_reminder': false,
        'send_push_reminder': true,
        'color': '#10B981', // Green for appointments
        'notes': notes,
      };

      final response = await _supabase
          .from('calendar_events')
          .insert(appointmentData)
          .select()
          .single();

      return CalendarEvent.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Get upcoming appointments for current user
  Future<List<CalendarEvent>> getUpcomingAppointments() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now();
      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('event_type', 'business_appointment')
          .gte('start_date', today.toIso8601String().split('T')[0])
          .eq('creator_id', userId)
          .order('start_date', ascending: true)
          .order('start_time', ascending: true)
          .limit(10);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming appointments: $e');
    }
  }

  // Get appointments for a specific application
  Future<List<CalendarEvent>> getAppointmentsByApplication(
    String applicationId,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('application_id', applicationId)
          .eq('event_type', 'business_appointment')
          .eq('creator_id', userId)
          .order('start_date', ascending: true)
          .order('start_time', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch application appointments: $e');
    }
  }

  // Helper method to add one hour to time string
  String _addOneHour(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];

    hour = (hour + 1) % 24;
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  // Update an existing event (only if user is creator)
  Future<CalendarEvent> updateEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user owns the event
      final existingEvent = await _supabase
          .from('calendar_events')
          .select('creator_id')
          .eq('id', eventId)
          .single();

      if (existingEvent['creator_id'] != userId) {
        throw Exception('You can only update your own events');
      }

      final response = await _supabase
          .from('calendar_events')
          .update(updates)
          .eq('id', eventId)
          .select()
          .single();

      return CalendarEvent.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete an event (only if user is creator)
  Future<void> deleteEvent(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user owns the event
      final existingEvent = await _supabase
          .from('calendar_events')
          .select('creator_id')
          .eq('id', eventId)
          .single();

      if (existingEvent['creator_id'] != userId) {
        throw Exception('You can only delete your own events');
      }

      await _supabase.from('calendar_events').delete().eq('id', eventId);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Get events by business application
  Future<List<CalendarEvent>> getEventsByApplication(
    String applicationId,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('application_id', applicationId)
          .or('creator_id.eq.$userId,visibility.eq.public')
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch application events: $e');
    }
  }

  // Get events by business
  Future<List<CalendarEvent>> getEventsByBusiness(String businessId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('business_id', businessId)
          .or('creator_id.eq.$userId,visibility.eq.public')
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch business events: $e');
    }
  }

  // Get event participants
  Future<List<EventParticipant>> getEventParticipants(String eventId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Check if user can view this event
      final event = await _supabase
          .from('calendar_events')
          .select('creator_id, visibility')
          .eq('id', eventId)
          .single();

      if (event['creator_id'] != userId && event['visibility'] != 'public') {
        throw Exception('Access denied to this event');
      }

      final response = await _supabase
          .from('event_participants')
          .select()
          .eq('event_id', eventId)
          .order('created_at', ascending: true);

      return response.map((json) => EventParticipant.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch event participants: $e');
    }
  }

  // Add participant to event (only if user is creator)
  Future<EventParticipant> addParticipant(
    Map<String, dynamic> participantData,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user owns the event
      final eventId = participantData['event_id'];
      final existingEvent = await _supabase
          .from('calendar_events')
          .select('creator_id')
          .eq('id', eventId)
          .single();

      if (existingEvent['creator_id'] != userId) {
        throw Exception('You can only add participants to your own events');
      }

      final response = await _supabase
          .from('event_participants')
          .insert(participantData)
          .select()
          .single();

      return EventParticipant.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add participant: $e');
    }
  }

  // Remove participant from event (only if user is creator)
  Future<void> removeParticipant(String participantId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user owns the event
      final participant = await _supabase
          .from('event_participants')
          .select('event_id')
          .eq('id', participantId)
          .single();

      final event = await _supabase
          .from('calendar_events')
          .select('creator_id')
          .eq('id', participant['event_id'])
          .single();

      if (event['creator_id'] != userId) {
        throw Exception(
          'You can only remove participants from your own events',
        );
      }

      await _supabase
          .from('event_participants')
          .delete()
          .eq('id', participantId);
    } catch (e) {
      throw Exception('Failed to remove participant: $e');
    }
  }

  // Update participant response
  Future<EventParticipant> updateParticipantResponse(
    String participantId,
    String responseStatus,
    String? responseNotes,
  ) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user owns the event or is the participant
      final participant = await _supabase
          .from('event_participants')
          .select('event_id, user_id')
          .eq('id', participantId)
          .single();

      final event = await _supabase
          .from('calendar_events')
          .select('creator_id')
          .eq('id', participant['event_id'])
          .single();

      if (event['creator_id'] != userId && participant['user_id'] != userId) {
        throw Exception('Access denied to update this participant');
      }

      final response = await _supabase
          .from('event_participants')
          .update({
            'response_status': responseStatus,
            'response_notes': responseNotes,
          })
          .eq('id', participantId)
          .select()
          .single();

      return EventParticipant.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update participant response: $e');
    }
  }

  // Search events by title or description (for current user)
  Future<List<CalendarEvent>> searchEvents(String query) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('calendar_events')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .or('creator_id.eq.$userId,visibility.eq.public')
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  // Get events by type (for current user)
  Future<List<CalendarEvent>> getEventsByType(String eventType) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('event_type', eventType)
          .or('creator_id.eq.$userId,visibility.eq.public')
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events by type: $e');
    }
  }

  // Get events by status (for current user)
  Future<List<CalendarEvent>> getEventsByStatus(String status) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('status', status)
          .or('creator_id.eq.$userId,visibility.eq.public')
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events by status: $e');
    }
  }

  // Update event status (only if user is creator)
  Future<CalendarEvent> updateEventStatus(String eventId, String status) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user owns the event
      final existingEvent = await _supabase
          .from('calendar_events')
          .select('creator_id')
          .eq('id', eventId)
          .single();

      if (existingEvent['creator_id'] != userId) {
        throw Exception('You can only update your own events');
      }

      final response = await _supabase
          .from('calendar_events')
          .update({'status': status})
          .eq('id', eventId)
          .select()
          .single();

      return CalendarEvent.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update event status: $e');
    }
  }

  // Get event statistics for current user
  Future<Map<String, dynamic>> getEventStatistics() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final totalEvents = await _supabase
          .from('calendar_events')
          .select('id')
          .or('creator_id.eq.$userId,visibility.eq.public');

      final todayEvents = await _supabase
          .from('calendar_events')
          .select('id')
          .eq('start_date', DateTime.now().toIso8601String().split('T')[0])
          .or('creator_id.eq.$userId,visibility.eq.public');

      final upcomingEvents = await _supabase
          .from('calendar_events')
          .select('id')
          .gte('start_date', DateTime.now().toIso8601String().split('T')[0])
          .or('creator_id.eq.$userId,visibility.eq.public');

      final completedEvents = await _supabase
          .from('calendar_events')
          .select('id')
          .eq('status', 'completed')
          .or('creator_id.eq.$userId,visibility.eq.public');

      return {
        'total': totalEvents.length,
        'today': todayEvents.length,
        'upcoming': upcomingEvents.length,
        'completed': completedEvents.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch event statistics: $e');
    }
  }
}
