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



### SQLite3のDB作成

ひとまず空っぽのDBを作成するために以下コマンドを入力します。

```sh
sqlite3 blog.db
>sqlite .tables
>sqlite .quit
```

![sqliteで空っぽのDBを作成する際のコマンド](https://s3-ap-northeast-1.amazonaws.com/nerima-study/20130130/2013-01-30-001.png)
### 接続を確認する

connect.rbというファイルに以下を記述する

```ruby
require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'dm-sqlite-adapter'

DataMapper.setup(:default, "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/blog.db")

require File.dirname(__FILE__) + '/../models/blog.rb'
DataMapper.finalize
DataMapper.auto_migrate!

```

blog.rbというファイルに以下を記述する

```ruby
class Post
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :body, Text
  property :create_at, DateTime

end
```

### DBにテスト投稿する

## Sinatraから利用できるようにする

先ほど作ったDBとは別に
