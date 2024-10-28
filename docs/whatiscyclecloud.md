# CycleCloudとは

## 概要

- [概要 - Azure CycleCloud](https://learn.microsoft.com/ja-jp/azure/cyclecloud/overview?view=cyclecloud-8)

## アーキテクチャー

全体のアーキテクチャーは以下の様になります。

![アーキテクチャー](/docs/images/architecture/CycleCloudArchitecture.png)


参考
- [CycleCloud アーキテクチャの概念 - Azure CycleCloud](https://learn.microsoft.com/ja-jp/azure/cyclecloud/concepts/core?view=cyclecloud-8)
- https://github.com/Azure/cyclecloud-pbspro

### 構成要素

CycleCloudの構成要素およびその役割は以下の通りです。

- アプリケーションサーバー
  - 管理インターフェースとして以下を提供
    - REST APIエンドポイント
    - ウェブベースのユーザーインターフェイス
    - CLI
- NoSQLデータストア
- オーケストレーター
  - Azure VMの管理を行う
- モニター
  - CycleCloud アプリケーション サーバーで実行
  - Azure サブスクリプション内のリソースの可用性について Azure サービスを定期的にポーリング
  - 取得した情報をスケジューラアダプターに提供

- スケジューラー
  - ジョブ (またはタスク) を受け入れ、ジョブのリソース要件とジョブ間の依存関係と優先順位を考慮して、これらのタスクを使用可能なリソースのプールに分散するソフトウェア
  - CycleCloud では、一般的に使用されるスケジューラ を Azure にデプロイするためのテンプレートを提供
  - サポートされるスケジューラー
    - [OpenPBS](https://learn.microsoft.com/ja-jp/azure/cyclecloud/openpbs?view=cyclecloud-8) （[PBS Pro](https://techcommunity.microsoft.com/t5/azure-high-performance-computing/deploy-an-altair-pbs-professional-cluster-in-azure-cyclecloud/ba-p/3727224)）
    - [Grid Engine](https://learn.microsoft.com/ja-jp/azure/cyclecloud/gridengine?view=cyclecloud-8)
    - [Slurm](https://learn.microsoft.com/ja-jp/azure/cyclecloud/slurm?view=cyclecloud-8)
    - [HT Condor](https://learn.microsoft.com/ja-jp/azure/cyclecloud/htcondor?view=cyclecloud-8)
    - [IBM Spectrum LSF](https://learn.microsoft.com/ja-jp/azure/cyclecloud/lsf?view=cyclecloud-8)
    - [Microsoft HPC Pack](https://learn.microsoft.com/ja-jp/azure/cyclecloud/hpcpack?view=cyclecloud-8)
    
- スケジューラ アダプター
  - スケジューラーの種類ごとに存在
  - 以下を実行
    - スケジューラ キューからのリソース要件の集計
    - リソース要件を Azure VM サイズのセットの割り当て要求に変換
  - 自動スケーリングプラグインがアプリケーションサーバー上で実行されている自動スケーリングREST APIと対話する事でクラスターのサイズを変更
- ノードアロケーター
  - CycleCloud アプリケーション サーバーで実行
  - REST API を介してスケジューラ アダプターから割り当て要求を受け取り、要求を満たすために必要な Azure リソースをプロビジョニング
  - プロビジョニングされたリソースをノードのセットとしてスケジューラ アダプターに返す
  - 実装の詳細は、スケジューラ アダプターに依存
- CycleCloudエージェント（Jetpack）
  - 各ノードのVMのbootプロセス中にHPCノードとして必要な構成を行う（スケジューラ構成、必要なソフトウェアの導入・構成、ファイルシステムマウント、など）
  - 各ノードの構成仕様 は、cloud-init仕様に従って定義される
  - cloud-initは、ChefロールまはたCookbookレシピにマップされる
  - Cookbookレシピは、ストレージアカウントから取得される
- プロジェクト
  - クラスターの構成仕様の定義
  - スケジューラ毎に用意され、ノードの構成に使用される
- クラスター
  - 接続されたコンピュータ（ノード）の集合を指します
  - 例えば、スケジューラーノード、ワーカーノード、ストレージノードなどの一連のリソースを指します
- ノード
  - クラスターの構成要素
  - 実態は準備と構成プロセスを完了した Azure 仮想マシン
- ノードアレイ
  - 同じように構成されたノードのグループ
  - 複数のVMSSで構成可能
- クラスターテンプレート
  - クラスターの構成を定義するINIファイル
  - クラスターの構成を再利用するために使用

## その他

参考情報

- [Azure CycleCloud を使用してデプロイされたハイ パフォーマンス コンピューティング クラスターをカスタマイズする - Training](https://learn.microsoft.com/ja-jp/training/modules/customize-clusters-azure-cyclecloud/)
- [CycleCloud 実稼働デプロイの計画 - Azure CycleCloud](https://learn.microsoft.com/ja-jp/azure/cyclecloud/how-to/plan-prod-deployment?view=cyclecloud-8)
- [クラスター テンプレートリファレンスの概要 - Azure CycleCloud](https://learn.microsoft.com/ja-jp/azure/cyclecloud/cluster-references/cluster-template-reference?view=cyclecloud-8)
