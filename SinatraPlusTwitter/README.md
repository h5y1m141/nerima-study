# Twitterの自分のtimelineを表示するためにSinatra+twitter(gem)を活用

![タイトルイメージ](https://github.com/downloads/h5y1m141/nerima-study/sinatra-plus-twitter.012.png)

## 狙い
前回はSinatraでtwitterのpublic timelineを表示するアプリを作って、Sinataraの基礎的な仕組みを学んだので今回は自分のtimelineを表示するための方法について理解する

+ twitter gemの活用方法
+ 前回まで使ったテンプレートエンジンのerbに加えて、別のテンプレートエンジンの haml について理解する

## twitter gemの利用方法について理解する
SinatraからTwitter APIを利用しやすいgemとしてtwitterというものがあるのでまずはそちらの使い方について説明します。



### Twitter API利用のためのKeyの確認

TwitterAPIを利用してChrome拡張機能を利用するアプリを作った際に

### 作業用フォルダの事前準備

今回の作業用のフォルダとファイルを作成します。この後ターミナルでの作業が増えてくるのでフォルダの作成とファイル作成までの作業をターミナル上で実行していきます

まず「Documents」フォルダに移動して、　「20121121」フォルダとその配下に「public」と「views」というフォルダを作成します

```sh
cd ~/Documents/
mkdir 20121121 20121121/views 20121121/public
```

フォルダ作成が完了したら、「config.yaml」と「Gemfile」と「console.rb」というファイルを作成します

```sh
touch config.yaml Gemfile console.rb
```

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
config.yamlには以下を記述します

(参考)Twitter APIを利用する際のCONSUMER KEY等の情報をこれまでプログラム本体に埋め込んでいました。設定情報となるものを別のファイルで管理して、それをプログラムから読み取る形式にしておくことで再利用しやすいプログラムになるので今回はそのやり方を取り入れます

```yaml
config:
 consumer_key			: "YOUR CONSUMER KEY"
 consumer_secret		: "YOUR CONSUMER SECRET"
 oauth_token			: "YOUR OAUTH TOKEN"
 oauth_token_secret		: "YOUR OAUTH TOKEN SECRET"

```

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
ターミナル上で

```sh
cd ~/Documents/20121121
ruby ./console.rb

```
