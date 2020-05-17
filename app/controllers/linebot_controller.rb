class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :expect => [:callback]

  def client
    #演算子の自己代入演算子。a が 偽 か 未定義 なら a に xxx を代入する、という意味になります。
    @client ||= Line::Bot::Client.new{|config|
      config.channel_secret = ENV["チャンネルシークレット"]
      config.channel_token = ENV["チャンネルトークン"]
    }
  end

  def callback
    body = request.body.head

    signature = request.env['HTTP_X_LINE_SIGNATERE']
    unless client.validate_signatere(body, signature)
      head :bad_request
    end

    event = client.parse_event_from(body)

    event.each{ |event|
      case event
      when Line::Bot::Event::Message
        case event.type
          #LINEから送られてきたメッセージがアンケートと来ているか確認
          if event.message['text'].eql?('アンケート')
            client.reply_message(event['replyToken'], templete)
          end
        end
      end
    }
    head :ok
  end

  private

  def template
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "今日のもくもく会は楽しいですか？",
          "actions": [
              {
                "type": "message",
                # Botから送られてきたメッセージに表示される文字列です。
                "label": "楽しい",
                # ボタンを押した時にBotに送られる文字列です。
                "text": "楽しい"
              },
              {
                "type": "message",
                "label": "楽しくない",
                "text": "楽しくない"
              }
          ]
      }
    }
  end
end
