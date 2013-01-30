## 狙い
マイクロブログというかtwitterライクなアプリ作成を通じて、SinatraとDBを連携させる方法について学びます

今回作るアプリの機能として

- つぶやいたものをDBに登録する
- つぶやいたものを画面上に表示する

というシンプルなものです

アプリ作成にあたって[自己流でSinatraとRSpecとWebratとCucumber使ってみた。あとDataMapperも](http://d.hatena.ne.jp/mothprog/20090706/1246897103)を参考にしてます。

## 環境準備

これまでのVirtualBox上のUbuntuには、DBを利用するソフトをインストールしてないためまずはそのインストールを行います。

VirtualBox上のUbuntuでは、DBとして手軽なSQLiteを利用しますが、最終的にHeroku上で利用することを念頭に作業をしていきたいので、併せてPostgreSQLもインストールしておくことにします

### SQLiteとPostgreSQLのインストール

SQLiteを利用するために、必要なライブラリをインストールするために以下コマンドを入力します。

```sh
sudo apt-get install libsqlite3-dev
sudo apt-get install ruby1.9.1-dev
```

その後、以下のようにコマンドを入力して、SQLiteとPostgreSQLのインストールを実施します


```sh
sudo apt-get install sqlite3 postgresql
```

作業完了後に、whichコマンドを入力して、SQLiteとPostgreSQLのインストール先のディレクトリが表示されればOKです

```sh
which sqlite3
/usr/bin/sqlite3

which psql
/usr/bin/psql
```

![psqlとpsqlのパスを表示した結果](https://s3-ap-northeast-1.amazonaws.com/nerima-study/20130130/2013-01-30-002.png)

## DB利用準備

SinatraとDB連携する前に、まずはRubyのプログラムからSQLiteのDBに接続できるプログラムを作成します。

### SQLite3のDB作成

ひとまず空っぽのDBを作成するために以下コマンドを入力します。

```sh
sqlite3 blog.db
>sqlite .tables
>sqlite .quit
```

![sqliteで空っぽのDBを作成する際のコマンド](https://s3-ap-northeast-1.amazonaws.com/nerima-study/20130130/2013-01-30-001.png)



### 作業用フォルダの事前準備

今回の作業用のフォルダとファイルを作成します。前回同様、ターミナルで作業していきます。

まず「Documents」フォルダに移動して、「20130130」フォルダとその配下に「db」「models」「views」というフォルダを作成します。

```sh
cd ~/Documents
mkdir 20130130 20130130/db 20130130/models 20130130/views
```

![フォルダを作成した結果](https://s3-ap-northeast-1.amazonaws.com/nerima-study/20130130/2013-01-30-002.png)

フォルダが作成できているか確認するために、以下の様なコマンドを入力します

```sh
ls -al 20130130
```

上記コマンドは「20130130」フォルダの中身を表示するという意味で、「db」「models」「views」というフォルダ名が表示されていればOKです

![フォルダを作成した結果](https://s3-ap-northeast-1.amazonaws.com/nerima-study/20130130/2013-01-30-002.png)

フォルダ作成が完了したら、「Gemfile」「connect.rb」「blog.rb」というファイルを作成します

```sh
cd ~/Documents/20130130
touch db/connect.rb db/connect.rb Gemfile
```

作業完了後、
```sh
ls -al
```

```sh
ls -al db
```
とすることで、20130130直下と、20130130の直下のDBフォルダにそれぞれ「Gemfile」「connect.rb」「blog.rb」というファイルが表示されればOKです

この状態では、中身は空っぽの状態なので、これ以降 Sublime Text2で編集していきます

## 「Gemfile」「connect.rb」「connect.rb」の編集

デスクトップ上のSublime Text2アイコンをダブルクリックして起動します。起動後「File」→「Open Folder」と進みます。
「Documents」に先ほど作成した「20130130」フォルダがあるのでそれを選択して「Open」選択します

### Gemfile の中身

```ruby
source :rubyforge
gem 'sinatra'
gem 'dm-core'
gem 'dm-aggregates'
gem 'dm-migrations'
gem 'dm-sqlite-adapter' 
```

### connect.rbの中身

```ruby
require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'dm-sqlite-adapter'

DataMapper.setup(:default, "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/blog.db")

require File.dirname(__FILE__) + '/../db/blog.rb'
DataMapper.finalize
DataMapper.auto_migrate!
```

### blog.rbの中身


```ruby
class Post
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :body, Text
  property :create_at, DateTime

end
```

## 動作確認する

必要なgemファイルのインストールをした後に、上記で設定したconnect.rbを実行することで、これまで空っぽだったsqlite3に、データを格納するためのテーブルが作成されます

```sh
cd ~/Documents/20130130/db
ruby ./connect.rb
ls -al

sqlite3 blog.db
sqlite> .tables
sqlite> .schema
```


![動作確認の一連の流れのコマンド](https://s3-ap-northeast-1.amazonaws.com/nerima-study/20130130/2013-01-30-005.png)
### DBにテスト投稿する

## Sinatraから利用できるようにする

先ほど作ったDBとは別に
