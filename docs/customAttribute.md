# Entra ID および Entra Domain Serviceでのカスタム属性

Entra ID および Entra Domain Service では、ユーザやグループに対してカスタム属性を追加することができます。

## Entra ID でのカスタム属性

Entra IDでは、カスタム属性として以下のものを追加することができます。

- カスタムセキュリティ属性
- 拡張機能

両者の位置づけは[ドキュメント](https://learn.microsoft.com/ja-jp/entra/fundamentals/custom-security-attributes-overview#how-do-custom-security-attributes-compare-with-extensions)で以下の様に説明されています。

機能 | Extensions | カスタム セキュリティ属性
--- | --- | ---
Microsoft Entra ID と Microsoft 365 オブジェクトを拡張する | はい | はい
サポート対象のオブジェクト | 拡張機能の種類によって異なる | ユーザーとサービス プリンシパル
制限付きアクセス | いいえ。 オブジェクトを読み取るアクセス許可を持つすべてのユーザーは、拡張機能データを読み取ることができます。 | はい。 読み取りおよび書き込みアクセスは、別のアクセス許可とロールベースのアクセス制御 (RBAC) のセットによって制限されます。
使用する場合 | アプリケーションで使用されるデータを保存する。機密以外のデータを保存する | 機密データを保存する。認可シナリオに使用する
ライセンスの要件 | Microsoft Entra ID のすべてのエディションで利用可能 | Microsoft Entra ID のすべてのエディションで利用可能

さらに、`拡張機能`については、以下の4種が提供されています。

- 拡張属性
  - **定義済みの名前**を持つ 15 個の拡張属性のセット
  - onPremisesExtensionAttributes プロパティと extensionAttributes プロパティを通じて、ユーザーまたはデバイスのリソース インスタンスに文字列値を格納するために使用
  - 15 個の拡張属性は Microsoft Graph で既に定義済み（extensionAttribute1 ～ extensionAttribute15 で固定）であり、**プロパティ名は変更不可**
  - よって、どの属性がどの目的で使用されているかを明確にするために、拡張属性の使用目的を文書化することが重要
- [ディレクトリ (Microsoft Entra ID) 拡張](https://learn.microsoft.com/ja-jp/graph/api/resources/extensionproperty?view=graph-rest-1.0)
  - アプリケーションに対して、ディレクトリ拡張機能の定義を行い、その定義を使用してディレクトリ オブジェクトにカスタム データを格納する
- スキーマ拡張
  - こちらもアプリに対してスキーマ拡張の定義を行い、その定義を使用してディレクトリ オブジェクトにカスタム データを格納する
- オープン拡張
  - 型指定されていないデータを直接リソース インスタンスに追加するためのシンプルで柔軟な方法

それぞれの差異については[ドキュメント：拡張機能の種類の比較](https://learn.microsoft.com/ja-jp/graph/extensibility-overview?tabs=http#comparison-of-extension-types)にまとめられています。

## Entra Domain Service でのカスタム属性

Entra Domain Service は、Azure が管理するドメインサービスで、自動的にEntra IDから一方向での同期が行われます。
先に見た4つの拡張機能のうち、Entra Domain Service では以下の2つの拡張機能を利用可能です。

- 拡張属性（onPremisesExtensionAttributes）
- ディレクトリ拡張

[以下](https://learn.microsoft.com/ja-jp/entra/identity/domain-services/concepts-custom-attributes)にある通り、その他の拡張はサポートされていません。
![Entra DSでサポートされない拡張](/docs/images/customattribute/entrads_unsupportedextension.png)

また、カスタム属性を利用するためには、Enterprise SKUが必要です。

## 検証：Entra IDからEntra DSへのディレクトリ拡張 の同期を確認する

以下の手順を参考に、Entra IDからEntra DSへのディレクトリ拡張の同期を確認してみます。
https://learn.microsoft.com/ja-jp/graph/api/resources/extensionproperty?view=graph-rest-1.0
https://learn.microsoft.com/ja-jp/entra/identity/domain-services/concepts-custom-attributes

### ディレクトリ拡張属性を定義する

ディレクトリ拡張を利用するには、まずはそれを所有するアプリケーションを作成する必要があります。

以下の手順で、ディレクトリ拡張属性を定義するアプリケーションを作成します。
作成したアプリのオブジェクト ID はこの後使用するため、コピーしておきます。

- [CycleCloud で使用する Entra アプリ登録を作成する (プレビュー)](https://learn.microsoft.com/ja-jp/azure/cyclecloud/how-to/create-app-registration?view=cyclecloud-8#creating-the-cyclecloud-app-registration)

#### プロパティを作成

APIをコールして、ディレクトリ拡張属性を定義します。
APIは Graph Explorer (https://developer.microsoft.com/en-us/graph/graph-explorer) から呼び出します。

APIコールの際には、予め 「Consent to permissions」からコール対象のAPIに対してConsentしておく必要があります。

![consenttopermissions](/docs/images/customattribute/consenttopermissions.png)

次の 2 つを検索して「Consent」をクリックし、同意します。

- User.ReadWrite.All
- Application.ReadWrite.All

![Consent](/docs/images/customattribute/2024-11-13_11h31_00.png)
![Consent](/docs/images/customattribute/2024-11-13_11h36_28.png)

Graph Explorer を操作するユーザーの権限によっては、管理者の同意が求められます。

[「管理者の承認が必要」のメッセージが表示された場合の対処法](https://jpazureid.github.io/blog/azure-active-directory/azure-ad-consent-framework/)

![Consent](/docs/images/customattribute/2024-11-13_11h31_35.png)

以下のリクエストを送信し、HomeDir 拡張プロパティを作成します。

```http
POST https://graph.microsoft.com/v1.0/applications/<作成したアプリのオブジェクト ID>/extensionProperties
```

Request Body
```json
{
    "name": "HomeDir",
    "dataType": "String",
    "targetObjects": [
        "User"
    ]
}
```

![](/docs/images/customattribute/2024-11-13_11h43_56.png)

以下のような応答が返ります。
プロパティ名 (extension_xxxx_HomeDir) の xxx 部分は作成したアプリのオブジェクト ID になるため、環境により異なります。

```json
{
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#applications('04cbb5c6-538a-4e72-9b6c-6b94d1d9a2ac')/extensionProperties/$entity",
    "id": "52de8db5-1939-4fac-9414-a5fece25fc52",
    "deletedDateTime": null,
    "appDisplayName": "SyncTest2",
    "dataType": "String",
    "isMultiValued": false,
    "isSyncedFromOnPremises": false,
    "name": "extension_2a966f16f6104a42ba80bb7b8dc0e3c2_HomeDir",
    "targetObjects": [
        "User"
    ]
}
```
正常に作成されたようです。

![](/docs/images/customattribute/2024-11-13_11h44_04.png)

同様の API に対して Request Body を以下に変更して実行し、2 つ目のプロパティを追加します

```json
{
    "name": "shell",
    "dataType": "String",
    "targetObjects": [
        "User"
    ]
}
```

こちらも作成されました。

![](/docs/images/customattribute/2024-11-13_11h50_16.png)
![](/docs/images/customattribute/2024-11-13_11h50_26.png)

#### プロパティ登録の確認

以下のAPIをコールして、作成したプロパティが登録されていることを確認します。

```http
GET https://graph.microsoft.com/v1.0/applications/<作成したアプリのオブジェクト ID>/extensionProperties
```

![](/docs/images/customattribute/2024-11-13_11h50_56.png)

以下の応答が返り、プロパティが作成されていることが確認できました。
それぞれの name プロパティはこの後使用するため、コピーしておきます。

```json
{
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#applications('04cbb5c6-538a-4e72-9b6c-6b94d1d9a2ac')/extensionProperties",
    "@microsoft.graph.tips": "Use $select to choose only the properties your app needs, as this can lead to performance improvements. For example: GET applications('<guid>')/extensionProperties?$select=appDisplayName,dataType",
    "value": [
        {
            "id": "520f040e-060f-4ab0-8dd7-e76bd6c86be1",
            "deletedDateTime": null,
            "appDisplayName": "",
            "dataType": "String",
            "isMultiValued": false,
            "isSyncedFromOnPremises": false,
            "name": "extension_2a966f16f6104a42ba80bb7b8dc0e3c2_shell",
            "targetObjects": [
                "User"
            ]
        },
        {
            "id": "52de8db5-1939-4fac-9414-a5fece25fc52",
            "deletedDateTime": null,
            "appDisplayName": "",
            "dataType": "String",
            "isMultiValued": false,
            "isSyncedFromOnPremises": false,
            "name": "extension_2a966f16f6104a42ba80bb7b8dc0e3c2_HomeDir",
            "targetObjects": [
                "User"
            ]
        }
    ]
}
```
![](/docs/images/customattribute/2024-11-13_11h51_13.png)


### ターゲットオブジェクト（ユーザー）に拡張プロパティを追加する

作成したプロパティは、そのプロパティを付与するオブジェクトに関連付けて初めて利用できるようになります。以下のAPIをコールして、ユーザーオブジェクトに拡張プロパティを追加します。

```http
PATCH https://graph.microsoft.com/v1.0/users/<プロパティ追加対象ユーザーのオブジェクト ID>
```

Request Body には先ほどコピーした name を指定します。
```json
{
    "<extension_xxx_HomeDir>": "/shared/home/",
    "<extension_xxx_shell>": "/bin/bash"
}
```
![](/docs/images/customattribute/2024-11-13_16h30_57.png)

ここでの応答は特にありません。

![](/docs/images/customattribute/2024-11-13_16h31_15.png)

### 確認する

次の API ではユーザーのプロパティを取得できますが、そのままで既定のプロパティしか取得できず、先ほど追加した拡張属性は表示されません。

```http
GET https://graph.microsoft.com/v1.0/users/<プロパティ追加対象ユーザーのオブジェクト ID>
```

![](/docs/images/customattribute/2024-11-13_16h34_17.png)

`$select`を用いて取得するプロパティを指定することで、拡張属性を表示できます。

```http
GET https://graph.microsoft.com/v1.0/users/<プロパティ追加対象ユーザーのオブジェクト ID>?$select=id,displayName,<extension_xxx_HomeDir>,<extension_xxx_shell>
```

以下の通り、ユーザーに追加したプロパティ2つが取得できました。
![](/docs/images/customattribute/2024-11-13_16h37_57.png)

```json
{
    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(id,displayName,extension_2a966f16f6104a42ba80bb7b8dc0e3c2_HomeDir,extension_2a966f16f6104a42ba80bb7b8dc0e3c2_shell)/$entity",
    "id": "78f3cfa1-8f4a-4cf4-b1e0-5fc19357b781",
    "displayName": "testuser01",
    "extension_2a966f16f6104a42ba80bb7b8dc0e3c2_shell": "/bin/bash",
    "extension_2a966f16f6104a42ba80bb7b8dc0e3c2_HomeDir": "/shared/home/"
}
```
これで、対象のオブジェクト（ユーザー）に、拡張プロパティを追加することができました。

### Entra DSへの同期を確認する

次に、Entra IDからEntra DSへの同期を確認します。

#### Entra DSの同期設定

Azure Portalにログインし、Entra DSへの同期対象になるプロパティを設定します。カスタム属性 から、追加 ボタンをクリックします。

![](/docs/images/customattribute/2024-05-24-18-19-26.png)

以下の画面が開きますので、先のステップで追加した属性を選択します。

![](/docs/images/customattribute/2024-11-13_16h40_02.png)

確認し、保存します。

![](/docs/images/customattribute/2024-05-24-18-21-55.png)

Entra DSへの同期を、Active Directory 管理ツールから確認してみます。

以下の通り、先ほど追加したプロパティが同期されていることが確認できました。

![](/docs/images/customattribute/2024-11-13_18h19_36.png)
![](/docs/images/customattribute/2024-11-13_18h19_57.png)


