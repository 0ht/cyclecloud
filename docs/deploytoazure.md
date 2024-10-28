# 構成

以下の環境を構築します。

![構成](/docs/images/cyclecloud_architecture.png)

ポイント
- 1つの仮想ネットワーク内に、以下のサブネットを作成しています
  - subnet-admin
    - Azure CycleCloud Serverと、踏み台として利用する管理用VMを配置します。
  - subnet-compute
    - CycleCloudによって実際にジョブが実行される計算ノードがデプロイされます。
  - subnet-anf
    - ストレージとしてAzure Netapp Filesをデプロイするdelegatedサブネットです。
  - AzureBastionSubnet
    - 各VMへアクセスするためのBastionをデプロイするdelegatedサブネットです。
- 閉域で構成し、Bastion経由で各VMにアクセスします。
  
# 構築手順

## Azureリソースのデプロイ

main.bicepから必要なモジュールを呼び出して構築します。
パラメータは、[main.bicepparam](bicep/main.bicepparam) にまとめられていますので、必要に応じて編集しておきます。実行時にはこのパラメータファイルを指定します。

### Bicepの実行

#### VSCodeからデプロイ

以下、main.bicepを選択して、「Deploy Bicep File...」を実行します。
command paletteで必要事項を指定しします。

![VSCodeからのデプロイ](/docs/images/vscode_deploy.png)

詳細な手順は以下も参考にしてください。

参考：[Visual Studio Code を使用して Bicep ファイルをデプロイする - Azure Resource Manager](https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/deploy-vscode)


#### CLIでのデプロイ

以下のコマンドを実行します。
```
az deployment sub create --location eastus --parameters 'main.bicepparam'
```

詳細な手順は以下も参考にしてください。

参考：[Azure CLI と Bicep ファイルを使用してリソースをデプロイする - Azure Resource Manager](https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/deploy-cli)

### 実行結果の確認

進行状況および結果は、Azure Portalのリソースグループの Settings → Deployments から確認可能です。

![実行結果](/docs/images/deployment_status.png)

### Tips

CycleCloud imageを初めて利用する場合は、”VMがデプロイされない” 問題が発生することがあります。これは ”Marketplace purchase eligibilty check" によるものです。以下のコマンドを実行しtermsをacceptしたうえでリトライください。

```bash
az vm image terms accept --urn azurecyclecloud:azure-cyclecloud:cyclecloud8-gen2:latest
```

実行結果例：
```bash
$ az vm image terms accept --urn azurecyclecloud:azure-cyclecloud:cyclecloud8-gen2:latest
{
  "accepted": true,
  "id": "/subscriptions/d4a69daf-7d19-4fa9-9840-3e522d9321fb/providers/Microsoft.MarketplaceOrdering/offerTypes/Microsoft.MarketplaceOrdering/offertypes/publishers/azurecyclecloud/offers/azure-cyclecloud/plans/cyclecloud8-gen2/agreements/current",
  "licenseTextLink": "https://storeordersprodsn.blob.core.windows.net/legalterms/XXXXXXXXX.txt",
  "marketplaceTermsLink": "https://storeordersprodsn.blob.core.windows.net/marketplaceterms/XXXXXXXX.txt",
  "name": "cyclecloud8-gen2",
  "plan": "cyclecloud8-gen2",
  "privacyPolicyLink": "https://privacy.microsoft.com/en-us/privacystatement",
  "product": "azure-cyclecloud",
  "publisher": "azurecyclecloud",
  "retrieveDatetime": "2024-09-25T09:48:02.679178Z",
  "signature": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "systemData": {
    "createdAt": "2024-09-25T09:48:05.232484+00:00",
    "createdBy": "d4a69daf-7d19-4fa9-9840-3e522d9321fb",
    "createdByType": "ManagedIdentity",
    "lastModifiedAt": "2024-09-25T09:48:05.232484+00:00",
    "lastModifiedBy": "d4a69daf-7d19-4fa9-9840-3e522d9321fb",
    "lastModifiedByType": "ManagedIdentity"
  },
  "type": "Microsoft.MarketplaceOrdering/offertypes"
}
```