module Volunteer
  module Calendaring
    private

    def event_signup(event_id)
      @attendee = Volunteer::Attendee.new(session[:email], session[:name])
      result = google_calendar.add_attendee_to_event(@attendee, event_id)
      if result.success?
        redirect_to volunteer_shifts_url, success: "You have signed up for the shift."
      else
        redirect_to new_volunteer_shift_url(event_id: event_id), error: result.errors
      end
    end

    def google_calendar
      GoogleCalendar.new
    end
  end
end