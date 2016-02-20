require 'date'

module Tech404logs
  class Application < Sinatra::Base
    HOME_CHANNEL = ENV.fetch('HOME_CHANNEL').freeze

    get '/' do
      @channel = Channel.first(name: HOME_CHANNEL)
      @messages = @channel.messages.on_date(date).ascending
      content_type :html
      erb :messages
    end

    get '/:channel_name/?:date?' do
      @channel = Channel.first(name: params[:channel_name])
      @messages = @channel.messages.on_date(date).ascending
      content_type :html
      erb :messages
    end

    helpers do
      def date
        if params[:date]
          Date.strptime(params[:date], '%Y-%m-%d')
        else
          Date.today
        end
      end

      def channels
        Channel.indexing
      end

      def channel_path(channel_or_name, date = nil)
        name = case channel_or_name
               when Channel
                 channel_or_name.name
               when String
                 channel_or_name
               end
        if date
          "/#{name}/#{date.strftime('%Y-%m-%d')}"
        else
          "/#{name}"
        end
      end

      def format_message(text)
        text = UserMentionFilter.apply(text)
        text = ChannelMentionFilter.apply(text)
        text = MessageFormatFilter.apply(text)
        text = LinkFormatFilter.apply(text)
        text
      end

      def user_name(user)
        name = user.real_name.to_s
        name = user.name if name.empty?
        name
      end
    end
  end
end