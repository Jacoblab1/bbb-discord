require 'dotenv'
Dotenv.load
require 'discordrb'

require './lib/bot'

TOKEN = ENV['DISCORD_TOKEN']
PREFIX = ENV.fetch('DISCORD_PREFIX', '!')

# Configure Discord bot
bot = BigBlueButtonBot.new(token: TOKEN, prefix: PREFIX)

puts "BigBlueButtonBot invite URL: #{bot.invite_url}."

# Run the bot
bot.run
