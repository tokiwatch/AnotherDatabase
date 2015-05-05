# AnotherDatabaseプラグイン

## はじめに

このプラグインは、MySQLの他のデータベースのデータをMTタグを通じて取得し、MTテンプレートの中で利用できるようにします。

## インストール

### 事前準備

cpanもしくは、cpanmでDBIx::Class、DBIx::Class::Schema::Loaderをインストールしてください。

```
$ cpanm DBIx::Class
$ cpanm DBIx::Class::Schema::Loader
```

本パッケージに含まれる「**plugins**」ディレクトリ内のディレクトリ「AnotherDatabase」を、Movable
Typeインストールディレクトリの「**plugins**」ディレクトリの下にコピーしてください。\
作業後、Movable Typeのシステム・メニューのプラグイン管理画面を表示し、プラグインの一覧に「AnotherDatabase」が表示されていることを確認してください。

## 使い方

### 初期設定
mt-config.cgiに下記の項目を追記します。

```
ADBObjectDriver dbi:mysql
ADBDatabase     database name
ADBDBUser       database username
ADBDBPassword   database password
ADBDBHost       hostname

```

### MTタグ

#### AnotherDatabase (ブロックタグ)

データベースへのアクセスを初期化します。オプションを定義することで、複数のデータベースを利用することが可能です。

##### モディファイヤ

- objectdriver_key (default: adbobjectdriver)
    - mt-config.cgiに記述した変数名を指定します。
- database_key (default: adbdatabase)
    - mt-config.cgiに記述した変数名を指定します。
- dbhost_key (default: adbdbuser)
    - mt-config.cgiに記述した変数名を指定します。
- dbuser_key (default: adbdbpassword)
    - mt-config.cgiに記述した変数名を指定します。
- dbpassword_key (default: adbdbhost)
    - mt-config.cgiに記述した変数名を指定します。
- dbencode (default: adbdbencode)
    - mt-config.cgiに記述した変数名を指定します。

#### AnotherDatabaseTable (ブロックタグ)

AnotherDatabaseタグのブロック内でのみ利用できます。データベースのテーブルの各行を呼び出します。

##### モディファイヤ

- column
    - フィルタの対象とするcolumnを指定します。
- method
    - フィルタのメソッドを定義します。一般的なsql文のwhere句で利用される比較演算子が利用できます。
    - 演算子の例
        - =
        - !=
        - \>
        - \<
        - \>=
        - \<=
        - like
        - between
- values
    - methodで使用する値を定義します。
    - 数値、文字列、配列が利用できます。(配列の場合は、","(カンマ)で区切ります。)
    - like演算子の場合は、sql文で使用される文字列の定義の方法が利用できます。
        - 例えば、文中に語句がある場合は、"%語句%"というような形になります。
    - between演算子の場合は、必ず2要素からなる配列を設定します。
- sort_by
    - ソートに使用するcolumn名を指定します。
- sort_order = "{ascend | descend}"
    - sort_byで指定したcolumnの値で、昇順か降順を指定します。デフォルトでは、descendです。
- page
    - 表示するページを指定します。
- rows
    - 1ページ当たりの行数を指定します。

#### AnotherDatabaseColumn (ファンクションタグ)

AnotherDatabaseTableタグのブロック内でのみ利用できます。AnotherDatabaseTableで呼び出されたデータベースの各行の各カラムを出力します。

##### モディファイヤ

- column
    - 出力するカラム名を指定します。
- encode
    - latin1のデータベースにutf8で保存されてしまっている場合、このモディファイヤにbinaryと指定します。


## 例

```
<mt:Anotherdatabase>
    <mt:AnotherDatabaseTable table="tablename"
        column = "id"
        method = "="
        value = "1,3,5"
        sort_by="modified_datetime"
        sort_order="descend"
        page="1"
        rows="4">
        <$mt:AnotherDatabaseColumn column="id"$>
        <$mt:AnotherDatabaseColumn column="name"$><br />
    </mt:AnotherDatabaseTable>
</mt:Anotherdatabase>
```

## 連絡先

作者：[Alliance Port, LLC.](http://www.allianceport.jp/)
