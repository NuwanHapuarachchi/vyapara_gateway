import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calendar_event.dart';
import '../models/event_participant.dart';

class CalendarService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all events for the current user
  Future<List<CalendarEvent>> getEvents() async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .select()
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  // Get events for a specific date range
  Future<List<CalendarEvent>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .select()
          .gte('start_date', startDate.toIso8601String().split('T')[0])
          .lte('start_date', endDate.toIso8601String().split('T')[0])
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events by date range: $e');
    }
  }

  // Get events for today
  Future<List<CalendarEvent>> getTodayEvents() async {
    final today = DateTime.now();
    return getEventsByDateRange(today, today);
  }

  // Get upcoming events
  Future<List<CalendarEvent>> getUpcomingEvents() async {
    try {
      final today = DateTime.now();
      final response = await _supabase
          .from('calendar_events')
          .select()
          .gte('start_date', today.toIso8601String().split('T')[0])
          .order('start_date', ascending: true)
          .limit(10);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming events: $e');
    }
  }

  // Create a new event
  Future<CalendarEvent> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .insert(eventData)
          .select()
          .single();

      return CalendarEvent.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  // Update an existing event
  Future<CalendarEvent> updateEvent(
    String eventId,
    Map<String, dynamic> updates,
  ) async {
    try {
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

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _supabase.from('calendar_events').delete().eq('id', eventId);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Get event participants
  Future<List<EventParticipant>> getEventParticipants(String eventId) async {
    try {
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

  // Add participant to event
  Future<EventParticipant> addParticipant(
    Map<String, dynamic> participantData,
  ) async {
    try {
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

  // Remove participant from event
  Future<void> removeParticipant(String participantId) async {
    try {
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

  // Get events by business
  Future<List<CalendarEvent>> getEventsByBusiness(String businessId) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('business_id', businessId)
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch business events: $e');
    }
  }

  // Get events by application
  Future<List<CalendarEvent>> getEventsByApplication(
    String applicationId,
  ) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('application_id', applicationId)
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch application events: $e');
    }
  }

  // Search events by title or description
  Future<List<CalendarEvent>> searchEvents(String query) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  // Get events by type
  Future<List<CalendarEvent>> getEventsByType(String eventType) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('event_type', eventType)
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events by type: $e');
    }
  }

  // Get events by status
  Future<List<CalendarEvent>> getEventsByStatus(String status) async {
    try {
      final response = await _supabase
          .from('calendar_events')
          .select()
          .eq('status', status)
          .order('start_date', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events by status: $e');
    }
  }

  // Update event status
  Future<CalendarEvent> updateEventStatus(String eventId, String status) async {
    try {
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

  // Get event statistics
  Future<Map<String, dynamic>> getEventStatistics() async {
    try {
      final totalEvents = await _supabase.from('calendar_events').select('id');

      final todayEvents = await _supabase
          .from('calendar_events')
          .select('id')
          .eq('start_date', DateTime.now().toIso8601String().split('T')[0]);

      final upcomingEvents = await _supabase
          .from('calendar_events')
          .select('id')
          .gte('start_date', DateTime.now().toIso8601String().split('T')[0]);

      final completedEvents = await _supabase
          .from('calendar_events')
          .select('id')
          .eq('status', 'completed');

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
