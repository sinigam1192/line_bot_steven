class LinebotController < ApplicationController
  require 'line/bot'
  require 'open-uri'

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
    #rich_menu = {
	     #<rich menu content>
     #}
    #client.create_rich_menu(rich_menu)
  end



  def get_image(host_url)
    range = (100..500).to_a
    return image = "#{host_url}/#{range.sample}/#{range.sample}"
    puts image
  end

  def get_iamge(host_url)
    range = (100..500).to_a
    return image = "#{host_url}/#{range.sample}/#{range.sample}"
    puts image
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
        when Line::Bot::Event::Message
        case event.type
          when Line::Bot::Event::MessageType::Text
          # LINEから送られてきたメッセージが「アンケート」と一致するかチェック
          text = event.message['text']

          if text.eql?('セガール')
            # private内のtemplateメソッドを呼び出します。
            @image = get_image("https://www.stevensegallery.com/g")
            client.reply_message(event['replyToken'], template)

          elsif text.eql?('マーレイ')
            @image = get_image("https://www.fillmurray.com")
            #@image = get_image("https://www.stevensegallery.com/g")
            client.reply_message(event['replyToken'], template)

          elsif text.eql?('ニコラス')
            @image = get_image("https://www.placecage.com")
            #@image = get_image("https://www.stevensegallery.com/g")
            client.reply_message(event['replyToken'], template)
          else
            client.reply_message(event['replyToken'], template1)
          end
        end
      end
    }
    head :ok
  end

  private

  def template
    {
    type: 'image',
    originalContentUrl: "#{@image}",
    previewImageUrl: "#{@image}"
    }
  end

  def template1
    {
    type: 'text',
    text: '俺か？ 俺はただのコックだ'
    }
  end
end
