# CycleCloud 環境の構築

+ このリポジトリは、Cycle Cloud の利用イメージをつかむための実環境を構築するための手順、リソースを提供するものです。
+ Azure環境構築のためのBicepコード、クラスタセットアップのスクリプトを提供するとともに、構築の手順を紹介しています。
+ CycleCloud環境構築に必要なAzure関連のリソースのデプロイを省力化し、クラスターのセットアップからジョブ投入を体験頂ける様な流れにしています。
+ CycleCloudは8.6 （ OSS や、その他 Azure 等プラットフォームのバージョンは2024年4月時点の環境）を利用しています。

目次
+ [CycleCloudとは](/docs/whatiscyclecloud.md)
+ 構築手順
  + [Azureリソースのデプロイ](/docs/deploytoazure.md)
  + [CycleCloudサーバーの設定](/docs/configCCserver.md)
  + [CycleCloudクラスターのデプロイ・起動・動作確認](docs/deploycccluster.md)
  + [クラスターの動作確認](/docs/testcluster.md)

+ クラスター定義・カスタマイズ
  + クラスターテンプレート
  + PBS スケジューラーとの連携
  + [カスタムイメージの利用](/docs/customimage.md)

+ セキュリティ
  + [認証構成](/docs/authconfig.md)
  
+ 運用・管理
  + [クラスターの操作](/docs/clusteroperations.md)
  + [ログ管理](/docs/log.md)
  + [トラブルシューティング](/docs/errors.md) 

