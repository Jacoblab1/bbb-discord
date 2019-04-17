# frozen_string_literal: true

require 'bigbluebutton_api'
require 'securerandom'

module ApiHelper
  def prepare
    url = (ENV['BIGBLUEBUTTON_ENDPOINT'] || 'http://test-install.blindsidenetworks.com/bigbluebutton/') + 'api'
    secret = ENV['BIGBLUEBUTTON_SECRET'] || '8cd8ef52e8e101574e400365b55e11a6'
    version = 0.81

    @api = BigBlueButton::BigBlueButtonApi.new(url, secret, version.to_s, true)
  end

  # gets meetings from BBB server
  def get_meetings
    prepare
    @api.get_meetings
  end

  def get_meeting_url(id, password)
    prepare
    @api.join_meeting_url(id, 'Guest', password)
  end

  # checks if meeting with specified id is running
  def meeting_running?(id)
    prepare
    @api.is_meeting_running?(id)
  end

  def create_meeting(name)
    # create a meeting on the BBB server
    prepare
    id = SecureRandom.urlsafe_base64
    options = {
      attendeePW: 'ap',
      moderatorPW: 'mp',
      welcome: "Welcome to the #{name} meeting!"
    }

    @api.create_meeting(name, id, options)

    if meeting_running?(id)
      return 'Sorry, a meeting with this id is already running.'
    else
      return 'Click here to join your new meeting.' + get_meeting_url(id, 'mp')
    end
  end
end
