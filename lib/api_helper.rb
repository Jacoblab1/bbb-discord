# frozen_string_literal: true

# BBB API Helpers
require 'bigbluebutton_api'
require 'shorturl'

module ApiHelper
  URL = (ENV['BIGBLUEBUTTON_ENDPOINT'] || 'http://test-install.blindsidenetworks.com/bigbluebutton/') + 'api'
  SECRET = ENV['BIGBLUEBUTTON_SECRET'] || '8cd8ef52e8e101574e400365b55e11a6'
  VERSION = 0.9

  module_function

  # Prepare the BBB api bridge
  def prepare
    @api = BigBlueButton::BigBlueButtonApi.new(URL, SECRET, VERSION.to_s, true)
  end

  # Get BBB server api version
  def get_version
    prepare
    @api.get_api_version
  end

  # Get all active meetings on the BBB server
  def get_meetings
    prepare
    @api.get_meetings
  end

  # Get info about an exisiting meeting
  def get_meeting_info(id)
    prepare
    @api.get_meeting_info(id, nil)
  end

  # Get the join URL for an existing meeting
  def get_meeting_url(id, password)
    prepare
    @api.join_meeting_url(id, 'Guest', password)
  end

  # End a meeting on the BBB server
  def end_meeting(id)
    prepare
    mod_pw = get_meeting_info(id).dig(:moderatorPW).to_s
    @api.end_meeting(id, mod_pw)
  end

  # Check if meeting is running on the BBB server
  def meeting_running?(id)
    prepare
    @api.is_meeting_running?(id)
  end

  # Create a meeting on the BBB server
  def create_meeting(name, id)
    # create a meeting on the BBB server
    prepare
    options = {
      attendeePW: 'ap',
      moderatorPW: 'mp',
      welcome: "Welcome to the #{name} meeting!"
    }

    @api.create_meeting(name, id, options)
    @api.join_meeting_url(id, 'Guest', 'mp')
  end

  # Get recordings from BBB server (this could be a lot)
  def get_recordings(options = {})
    prepare
    @api.get_recordings(options)
  end
end
