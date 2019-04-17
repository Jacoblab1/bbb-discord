require './lib/api_helper'
module ApiCommands
  module_function

  def enable_commands(bot)

    # Create new meeting
    bot.command(:create, min_args: 0, max_args: 1,
                description: 'Creates a new BigBlueButton meeting.',
                usage: '!create [name]') do |_event, name|

      name = name ? name : 'BigBlueButton Meeting'
      link = ApiHelper.create_meeting(name)
      short_link = ShortURL.shorten(link, :tinyurl)

      "Here's your new BigBlueButton meeting! \n #{short_link}"
    end

    # Get all meetings
    bot.command(:meetings, min_args: 0, max_args: 0,
                description: 'Get existing meetings from BigBlueButton',
                usage: '!meetings') do |_event|

      output = "Here are the meetings I found on BigBlueButton: \n"

      ApiHelper.get_meetings.slice(:meetings).each do |key, meetings|
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
    bot.command(:bbb, min_args: 0, max_args: 0,
                description: 'Information about the BigBlueButton bot.',
                usage: '!bbb') do |_event|
      output = "Hey there! I'm the BigBlueButton Discord bot. \n"
      output += "It looks like I'm already configured, so you can go ahead and try out my commands! \n"
      output += "For example, to create a new meeting enter '!create [name]'. Try it out! \n"
    end
  end
end
