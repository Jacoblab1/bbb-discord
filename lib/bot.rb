# frozen_string_literal: true

require './lib/api_commands'
require './lib/api_helper'

class BigBlueButtonBot < Discordrb::Commands::CommandBot
  def initialize(token: nil, prefix: '!')
    super

    # Turn on api commands
    ApiCommands.enable_commands(self)
  end
end
