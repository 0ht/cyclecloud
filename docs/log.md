# CycleCloudでのログ管理

作成中

## 主要なログ一覧

主要なログは以下の通りです。

サーバー | 	目的	| パス
-|-|-
CycleCloud|CycleCloud サーバー アプリケーション ログ	| /opt/cycle_server/logs/cycle_server.log
CycleCloud|CycleCloud から Azure へのすべての API 要求のログ|/opt/cycle_server/logs/azure-*.log
クラスタノード|Chef ログ/ソフトウェアのインストールに関する問題のトラブルシューティング|/opt/cycle/jetpack/logs/chef-client.log
クラスタノード|詳細な chef stacktrace 出力|/opt/cycle/jetpack/system/chef/cache/chef-stacktrace.out
クラスタノード|詳細な cluster-init ログ出力|/opt/cycle/jetpack/logs/cluster-init/{PROJECT_NAME}
クラスタノード|Waagent ログ (Jetpack のインストールに使用)	|/var/log/waagent.log
マスターノード|PBS Pro ログ|/opt/cycle/pbspro/autoscale.log
マスターノード|PBS Pro ログ|/opt/cycle/pbspro/autoscale_repro.log
マスターノード|PBS Pro ログ|/opt/cycle/pbspro/demand.log
マスターノード|PBS Pro ログ|/opt/cycle/pbspro/last_cron.log
マスターノード|PBS Pro ログ|/opt/cycle/pbspro/qcmd.log

## ログ出力先の変更

ログの出力先の変更はできないようです。
どうしても変更が必要な場合は、シンボリックリンクを作成する、などでの対応を検討することになります。


## ログのローテーション

CycleCloudではログのローテーション機能は提供していません。
logrotate などのツールを利用してログのローテーションを行うことになります。

## ログレベルの変更

CycleCloudのログレベルは以下の方法で変更可能です。


### CycleCloud UIから

ポータル画面右上のアイコンを選択し、logging levelを選択します。

![](docs/images/2024-10-04-14-31-35.png)

表示される画面で、ログレベルを選択します。

![](docs/images/2024-10-04-14-32-16.png)

### コマンドラインから

以下のコマンドを実行します。

```bash
/opt/cycle_server/cycle_server execute 'update application.setting set value="TRACE" where name == "logging.level"'
```


## 参考
+ ログの場所：https://learn.microsoft.com/ja-jp/azure/cyclecloud/log_locations?view=cyclecloud-8

