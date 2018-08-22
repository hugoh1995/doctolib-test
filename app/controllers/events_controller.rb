class EventsController < ApplicationController
  def index
    render json: Event.availabilities(DateTime.parse("2014-08-10"))
  end
end
