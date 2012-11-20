![タイトルイメージ](https://github.com/downloads/h5y1m141/nerima-study/sinatra-plus-twitter.012.png)


----------


## 狙い
前回はSinatraでtwitterのpublic timelineを表示するアプリを作りましたが、今回は自分のtimelineを表示するアプリ作成方法について学びます


## twitter gemの利用方法について理解する
SinatraからTwitter APIを利用するのにいくつかの手段があります。直感的に理解しやすいtwitterというgemライブラリを利用するのでまずはその使い方について解説します



### Twitter API利用のためのアプリケーション登録

TwitterAPIを利用してChrome拡張機能を利用するアプリを作った時の手順に従ってアプリケーション登録します。詳細の手順は[こちら](https://github.com/h5y1m141/nerima-study/blob/master/SinatraPlusTwitter/twitter-api-regist.md)を参照してください

### 作業用フォルダの事前準備

今回の作業用のフォルダとファイルを作成します。この後ターミナルでの作業が増えてくるのでフォルダの作成とファイル作成までの作業をターミナル上で実行していきます

まず「Documents」フォルダに移動して、　「20121121」フォルダとその配下に「public」と「views」というフォルダを作成します

```sh
cd ~/Documents/
mkdir 20121121 20121121/views 20121121/public
```

![作業画面１](https://github.com/downloads/h5y1m141/nerima-study/screen-shot-01.png)

フォルダが作成できてるかどうか確認するために以下のようなコマンドを入力します

```sh
ls -al 20121121
```

上記コマンドは「20121121」フォルダの中身を表示するという意味なのですが「public」と「views」というフォルダ名が表示されていればOKです

![確認画面](https://github.com/downloads/h5y1m141/nerima-study/screen-shot-02.png)

フォルダ作成が完了したら、「config.yaml」と「Gemfile」と「console.rb」というファイルを作成します

```sh
cd ~/Documents/20121121
touch config.yaml Gemfile console.rb
```

作業完了した後に

```sh
ls -al
```

と入力して「config.yaml」と「Gemfile」と「console.rb」というファイルが表示されると思います。

![作業画面2](https://github.com/downloads/h5y1m141/nerima-study/screen-shot-03.png)

なおこの状態では「config.yaml」と「Gemfile」と「console.rb」それぞれ中身は空っぽの状態になってますので、このファイルをSublimeText2で編集していきます

### 「config.yaml」と「Gemfile」と「console.rb」の編集

デスクトップ上のSublimeText2アイコンをダブルクリックして起動します。起動後「File」→「OpenFolder」と進みます

「Documents」に先ほど作成した「20121121」フォルダがあるのでそれを選択して「Open」を選択します

Gemfileには以下を記述します

```Gemfile
source "http://rubygems.org"

gem 'sinatra'
gem 'twitter'
gem 'haml'
```
config.yamlには以下を記述します。記述する際に2点注意事項があります

1. 2行目以降のconsumer_key,consumer_secret,oauth_token,oauth_token_secretのそれぞれの先頭行に半角スペースを1ついれます。(タブは禁止です）

2. コロン(:)の後に必ず半角スペースを1ついれます。
※なおconsumer_key,consumer_secret,oauth_token,oauth_token_secretの文字の後の空白はいくつあってもOKです。今回のサンプルでは見やすくするために空白が複数入ってますが、特に空白入れなくてもOKです


```yaml
config:
 consumer_key			: "YOUR CONSUMER KEY"
 consumer_secret		: "YOUR CONSUMER SECRET"
 oauth_token			: "YOUR OAUTH TOKEN"
 oauth_token_secret		: "YOUR OAUTH TOKEN SECRET"

```

(参考情報)Twitter APIを利用する際のCONSUMER KEY等の情報をこれまでプログラム本体に埋め込んでいました。設定情報となるものを別のファイルで管理して、それをプログラムから読み取る形式にしておくことで再利用しやすいプログラムになるので今回はそのやり方を取り入れます


console.rbには以下を記述します

``` ruby
require 'twitter'
require 'yaml'

twitter_conf = YAML.load_file("config.yaml")

# config.yamlの中身が読み取れるか動作確認します
p twitter_conf["config"]["consumer_key"]
p twitter_conf["config"]["consumer_secret"]
p twitter_conf["config"]["oauth_token"]
p twitter_conf["config"]["oauth_token_secret"]

# twitter gemライブラリを利用してTwitter APIを利用するための
# 設定を以下のようにします
Twitter.configure do |config|
  config.consumer_key       = twitter_conf["config"]["consumer_key"]
  config.consumer_secret    = twitter_conf["config"]["consumer_secret"]
  config.oauth_token        = twitter_conf["config"]["oauth_token"]
  config.oauth_token_secret = twitter_conf["config"]["oauth_token_secret"]
end

p Twitter.home_timeline

```


### 動作確認
SublimeText2での入力が完了したらターミナル上で以下のように入力します

```sh
cd ~/Documents/20121121
bundle install
ruby ./console.rb
```

以下のように、ターミナル上にTwitterのAPIを通じて取得できた自分のtimelineの情報が表示されればOKです。

![TwitterのAPIを通じて取得できた自分のtimelineの情報がターミナル上に表示される](https://github.com/downloads/h5y1m141/nerima-study/screen-shot-04.png)


## Sinatraでtwitterのtimelineを表示する

先ほど作ったconsole.rb のプログラムをベースにして、SinatraでTwitterの自分のタイムラインを表示できるようにします

### 事前準備

「20121121」フォルダ配下にapp.rbというファイルを作るために以下コマンドを入力します

```sh
cd ~/Documents/20121121
touch app.rb views/top.erb
```

以下のような画面になればOKです

![touch app.rb top.erb した結果](https://github.com/downloads/h5y1m141/nerima-study/screen-shot-05.png)

SublimeText2上で「20121121」フォルダが展開されていると思いますので、その中にapp.rbが作成されていることを確認して、このファイルに以下を記述します

```ruby
require 'twitter'
require 'sinatra'
require 'yaml'

class MyApp < Sinatra::Base
  before do
    twitter_conf = YAML.load_file("config.yaml")
	Twitter.configure do |config|
      config.consumer_key       = twitter_conf["config"]["consumer_key"]
      config.consumer_secret    = twitter_conf["config"]["consumer_secret"]
      config.oauth_token        = twitter_conf["config"]["oauth_token"]
      config.oauth_token_secret = twitter_conf["config"]["oauth_token_secret"]
	end
  end

  get '/' do
    @home_timeline = Twitter.home_timeline
    erb :top
  end
end

MyApp.run! :host => 'localhost', :port => 4567
```
top.erbには以下を記述します

```ruby
<html>
  <head>
    <title>Twitter(gem)を使ったSinatraアプリ</title>
    <link href="bootstrap.min.css" rel="stylesheet">
  </head>
  <body>	
  <h1>Twitter Timeline(use erb)</h1>
  <ul>
    <%
      @home_timeline.each do |items|
    %>
    <li>
      <%= items["text"] %>
    </li>
    <% end %>
  </ul>
</body>
</html>
```

### 動作確認する

app.rb と top.erb の記述が終わったらターミナル上で以下のように入力してSinatarの動作確認をします

```sh
ruby ./app.rb
```

![Sinatraの動作確認](https://github.com/downloads/h5y1m141/nerima-study/screen-shot-06.png)

Sinatraが起動できたら、ブラウザを起動して

http://locahost:4567/

にアクセスして以下のように自分のタイムラインが表示されればOKです

![ブラウザでの表示](https://github.com/downloads/h5y1m141/nerima-study/screen-shot-07.png)
