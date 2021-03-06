# frozen_string_literal: true

require './lib/api_helper'
require 'securerandom'

# BigBlueButton Discord Bot Commands
module ApiCommands
  module_function

  def enable_commands(bot)
    # Create new meeting
    bot.command(:create, min_args: 0, max_args: 2,
                         description: 'Creates a new BigBlueButton meeting.',
                         usage: '!create [name] [id]') do |_event, name, id|

      name ||= 'BigBlueButton Meeting'
      id ||= SecureRandom.urlsafe_base64
      link = ApiHelper.create_meeting(name, id)
      short_link = ShortURL.shorten(link, :tinyurl)

      "Here's your new BigBlueButton meeting! \n #{short_link}"
    end

    # Get all meetings
    bot.command(:meetings, min_args: 0, max_args: 0,
                           description: 'Get existing meetings from BigBlueButton',
                           usage: '!meetings') do |_event|

      output = "Here are the meetings I found on BigBlueButton: \n"

      ApiHelper.get_meetings.slice(:meetings).each do |_key, meetings|
        meetings.each do |meeting|
          url = ShortURL.shorten(ApiHelper.get_meeting_url(meeting[:meetingID], meeting[:moderatorPW]), :tinyurl)
          output += meeting[:meetingName] + ' - ' + url + "\n"
        end
      end

      output
    end

    # Get single meeting
    bot.command(:meeting, min_args: 1, max_args: 1,
                          description: 'Get info on an existing meeting.',
                          usage: '!meeting [id]') do |_event, id|

      begin
        hash = ApiHelper.get_meeting_info(id)
      rescue BigBlueButton::BigBlueButtonException
        return "Uh oh! I couldn't find that meeting. Are you sure you entered the correct ID?"
      end

      output = "Here's what I found about the specified meeting: \n"
      output += 'Meeting Name: ' + hash.dig(:meetingName).to_s + "\n"
      output += 'Meeting ID: ' + hash.dig(:meetingID).to_s + "\n"
      output += 'Created: ' + hash.dig(:createDate).to_s + "\n"
      output += 'Voice Bridge: ' + hash.dig(:voiceBridge).to_s + "\n"
      output += 'Dial Number: ' + hash.dig(:dialNumber).to_s + "\n"
      output += 'Recording?: ' + hash.dig(:recording).to_s + "\n"
      output += 'Running?: ' + hash.dig(:running).to_s + "\n"
    end

    # End a meeting
    bot.command(:end, min_args: 1, max_args: 1,
                      description: 'End a meeting.',
                      usage: '!end [id]') do |_event, id|
      begin
        ApiHelper.end_meeting(id)
        output = "I've ended the BigBlueButton meeting for you!"
      rescue BigBlueButton::BigBlueButtonException
        output = "I can't seem to end this meeting. Are you sure it exists?"
      end

      output
    end

    # Base bot command
    bot.command(:bbb, min_args: 0, max_args: 1,
                      description: 'Information about the BigBlueButton bot.',
                      usage: '!bbb') do |_event, help|

      if help.eql?('help')
        output = "Here are the available BigBlueButton commands: \n"
        output += "Parameters marked with a * are optional. \n"
        output += "Create a new BBB meeting: `!create [name*] [id*]` \n"
        output += "Get info on a BBB meeting: `!meeting [meeting_id]` \n"
        output += "Get all active BBB meetings: `!meetings` \n"
        output += "Get 25 recordings from BBB: `!recordings` \n"
        output += "Get info on a BBB recording: `!recording [recording_id]` \n"
        output += "End an active BBB meeting: `!end [meeting_id]` \n"
      else
        output = "Hey there! I'm the BigBlueButton Discord bot. \n"
        begin
          ApiHelper.get_version
          output += "It looks like I'm already configured, so you can go ahead and try out my commands! \n"
          output += "For a list of BigBlueButton commands, enter `!bbb help` \n"
        rescue BigBlueButton::BigBlueButtonException
          output += "Unfourtunately, I wasn't able to connect to the BigBlueButton server. \n"
          output += "Consider checking my configuration, and then try this command again. \n"
        end
      end
    end

    # Get recordings from BBB server
    # Can only display 25 or so, or will go over Discord message char limit
    bot.command(:recordings, min_args: 0, max_args: 0,
                             description: 'Get recordings from the BigBlueButton server.',
                             usage: '!recordings') do |_event|

      response = ApiHelper.get_recordings
      output = "Here are 25 of the recordings I found on your server: \n"
      response[:recordings].take(25).each do |m|
        output += m[:name] + ': ' + ShortURL.shorten(m[:playback][:format][:url], :tinyurl) + "\n"
      end

      output
    end

    # Get info on a BBB recording
    bot.command(:recording, min_args: 1, max_args: 1,
                            description: 'Get a recording from the BigBlueButton server.',
                            usage: '!recording [id]') do |_event, record_id|

      response = ApiHelper.get_recordings(recordID: record_id)
      recording = response[:recordings].first

      output = "Here's what I found about that recording: \n"
      output += "Recording ID: #{recording[:recordID]} \n"
      output += "Meeting ID: #{recording[:meetingID]} \n"
      output += "Name: #{recording[:name]} \n"
      output += "Start Time: #{recording[:startTime]} \n"
      output += "End Time: #{recording[:endTime]} \n"
      output += "Participants: #{recording[:participants]} \n"
      output += "Playback URL: #{ShortURL.shorten(recording[:playback][:format][:url], :tinyurl)} \n"

      output
    end
  end
end
