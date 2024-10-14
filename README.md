# CAFETAN


電車での移動中、沿線の駅周辺のカフェを簡単に見つけることができます。

 【アプリの特徴】
- **簡単操作**：直感的なインターフェースで、誰でもすぐに使える
- **GPS機能搭載**：リアルタイムで現在地を把握し、最寄り駅周辺のカフェを探索
- **経路表示**：カフェまでの詳細な経路を表示
- **WEBサイト表示**：カフェの公式WEBサイトをワンタップで表示
- **路線変更可能**：乗り換え時の路線変更も可能


<img src="https://github.com/nekoribocchi/CAFETAN/assets/168393598/01c9a838-f012-4e8b-8900-dd677ccdf940" width="250">
<img src="https://github.com/nekoribocchi/CAFETAN/assets/168393598/ef21f728-1283-44c8-870a-88bf86ae25d2" width="250"> 
<img src="https://github.com/nekoribocchi/CAFETAN/assets/168393598/f8472af8-a069-44fb-b918-ea43b35b45a0" width="250" > 
<img src="https://github.com/nekoribocchi/CAFETAN/assets/168393598/b49a3db2-76d9-4475-a5e9-9828e070b9cc" width="250"> 
<img src="https://github.com/nekoribocchi/CAFETAN/assets/168393598/c6c35580-1216-4c41-a4a8-c8fcd98f9583" width="250" > 

***

# 「CafeSearchManager」クラスの設計と実装

このクラスは、駅名ボタンをタップした時の、駅周辺カフェを検索する処理を実装しています。

## この記事の内容

- CafeSearchManagerクラスの概要
- 実装ポイント
    - キャッシュの利用による同じ駅の再検索を高速化
    - 非同期処理によるUX向上


## CafeSearchManagerクラスの概要

1. キャッシュの確認　
キャッシュが期限内であればキャッシュの内容を返します。
2. キャッシュが存在しない場合は、カフェを検索
自然言語クエリを使用
3. 結果を取得後キャッシュを保存

```swift
//CafeSearchManagerクラスは検索結果をキャッシュし、同じ駅に対する再検索を高速化
//CafeSearchManagerクラスは、特定の駅周辺のカフェを検索し、検索結果をキャッシュに保存することで、同じ駅に対する再検索時にキャッシュを利用して高速化を図りる
//これにより、ネットワークリクエストの頻度を減らし、エネルギー消費を抑える

import Foundation
import MapKit

class CafeSearchManager {
    //シングルトンパターンを使って、CafeSearchManagerクラスのインスタンスをアプリ全体で1つだけにし、必要な時にどこからでも同じインスタンスを使用できるようにする
    static let shared = CafeSearchManager()
    
    private var searchCache = [String: (results: [MKMapItem], timestamp: Date)]()
    private let cacheQueue = DispatchQueue(label: "com.example.CafeSearchCacheQueue")
    private let cacheExpirationInterval: TimeInterval = 60 * 60 // 1時間
    
    // 特定の駅に対するカフェ検索を行ったときに、このメソッドが呼ばれる
    func searchCafes(near station: String) async -> [MKMapItem]? {
        // キャッシュの確認
        if let cachedData = await getCachedData(for: station) {
            let cacheAge = Date().timeIntervalSince(cachedData.timestamp)
            if cacheAge < cacheExpirationInterval {
                print("キャッシュを利用")
                // キャッシュが有効期限内であればそれを返す
                return cachedData.results
                
            }
        }
        
        // キャッシュがない、または有効期限が切れている場合はネットワークリクエストを行う
        //自然言語クエリを使用
        //request.naturalLanguageQueryに任意のクエリを設定し、searchForCafesにrequestを引数として渡す。
        let query = "\(station)駅　近くのカフェ"
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        do {
            let response = try await searchForCafes(request: request)
            // キャッシュに保存
            await saveToCache(station: station, results: response.mapItems)
            return response.mapItems
        } catch {
            // エラーが発生した場合はnilを返す
            return nil
        }
    }
    
    // キャッシュされたデータを非同期で取得
    private func getCachedData(for station: String) async -> (results: [MKMapItem], timestamp: Date)? {
        return await withCheckedContinuation { continuation in
            cacheQueue.async {
                continuation.resume(returning: self.searchCache[station])
            }
        }
    }
    
    // 検索結果をキャッシュに保存する非同期関数
    private func saveToCache(station: String, results: [MKMapItem]) async {
        await withCheckedContinuation { continuation in
            cacheQueue.async {
                self.searchCache[station] = (results, Date())
                continuation.resume()
            }
        }
    }
    
    // MKLocalSearchでカフェを検索する非同期関数
    private func searchForCafes(request: MKLocalSearch.Request) async throws -> MKLocalSearch.Response {
        return try await withCheckedThrowingContinuation { continuation in
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                if let response = response {
                    continuation.resume(returning: response)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "UnknownError", code: 0, userInfo: nil))
                }
            }
        }
    }
}
```

---

## 実装ポイント

- キャッシュの利用による同じ駅の再検索を高速化
- 非同期処理によるUX向上

### 実装ポイント① 利用による同じ駅の再検索を高速化

キャッシュの内容

- `self.searchCache` は辞書（Dictionary）の形式
- キーが駅名 (`station`)、値がタプル (`(response.mapItems, Date())`)

```jsx
<MKMapItem: 0x103aaafe0> {
    isCurrentLocation = 0;
    name = "Chai Cafe";
    placemark = "Chai Cafe, \U3012211-0025, \U795e\U5948\U5ddd\U770c\U5ddd\U5d0e\U5e02\U4e2d\U539f\U533a, \U6728\U67082\U4e01\U76ee25-34 @ <+35.56169270,+139.65566060> +/- 0.00m, region CLCircularRegion (identifier:'<+35.56169271,+139.65566060> radius 141.17', center:<+35.56169271,+139.65566060>, radius:141.17m)";
    timeZone = "Asia/Tokyo (JST) offset 32400";
    url = "https://www.instagram.com/chaicafe1/";
}, <MKMapItem: 0x149444180> {
    isCurrentLocation = 0;
    name = "\U30b3\U30e1\U30c0\U73c8\U7432\U5e97\U5ddd\U5d0e\U5357\U52a0\U702c\U5e97";
    phoneNumber = "+81 44 599 5500";
    placemark = "\U30b3\U30e1\U30c0\U73c8\U7432\U5e97\U5ddd\U5d0e\U5357\U52a0\U702c\U5e97, \U3012212-0055, \U795e\U5948\U5ddd\U770c\U5ddd\U5d0e\U5e02\U5e78\U533a, \U5357\U52a0\U702c2\U4e01\U76ee30-7 @ <+35.54740290,+139.66008540> +/- 0.00m, region CLCircularRegion (identifier:'<+35.54740291,+139.66008540> radius 141.17', center:<+35.54740291,+139.66008540>, radius:141.17m)";
    timeZone = "Asia/Tokyo (JST) offset 32400";
    url = "https://www.komeda.co.jp/shop/detail.html?id=505";
}, 

...

], timestamp: 2024-10-14 02:01:29 +0000))

```

| キー | 値 | 値 |
| --- | --- | --- |
| Station | MapItem | CachedDate |
| 東京駅 | 現在地`かどうかの`フラグ(`isCurrentLocation`),名前 (`name`),位置情報 (`placemark`),時間帯 (`timeZone`),URL（`url`） | キャッシュされた日時`timestamp` |

https://developer.apple.com/documentation/mapkit/mkmapitem

### 実装ポイント② 非同期処理によるUX向上

検索の処理は非同期で行われ、Concurrencyを使った`async/await` 構文を活用しています。これにより、他の処理をブロックせずに検索が完了するのを待つことができます。

`async` キーワードは、関数を非同期に処理するために使います。非同期関数では、処理が完了するのを待つ間、他の処理をブロックせずに並行して実行できます。

非同期関数が返り値を持つ場合（今回の例では `[MKMapItem]` ）、その返り値をどこかで受け取る必要があります。その際に使用するのが `await` です。`await` は、その非同期処理が完了するまで一時的に待機し、完了後に返り値を受け取ります。

例えば、今回のコードでは `searchCafes(near:)` という `async` 関数を使ってカフェの検索結果を取得していますが、別の場所でこの関数を呼び出すときに `await` をつけることで、その処理が完了し結果が返ってくるまで待つことができます。これにより、検索結果（[MKMapItem]）を適切に受け取ることができます。

例えば受け取り先の `SearchOptionsView`クラスではこのような記述をしています。

```swift
 private func searchCafes(near station: String) async {
        // カフェ検索の結果を取得
        let items = await CafeSearchManager.shared.searchCafes(near: station)
        
        // 検索結果をUIに反映（メインスレッドで実行される）
        self.mapItems = items ?? []
        self.showPopover = true
    }
```

このメソッドでは`await` で返り値を受け取った後、その返り値をitemsとして格納しています。

また`SearchOptionsView`クラスには、ボタンをタップすると、 上記のsearchCafes関数が実行される仕組みにしています。

こちらは、Taskでawaitの処理を囲んでいますが、その理由を以下で説明します。

```swift

      onSelected: { selectedStation in
          self.selectedStation = selectedStation
          self.onSelected(selectedStation)
          Task {
              await searchCafes(near: selectedStation)
              self.showPopover = true
          }
      },

```

## Taskを使うメリット-UIの更新時

- **ViewやButtonのような同期処理の中ではawaitは使えない → Taskで囲む必要あり**

Swiftでは、`async` 関数を呼び出す際に必ず `await` が必要です。しかし、`await` を使用するには、`async` コンテキスト（非同期処理を扱える範囲）内で行う必要があります。通常、`async` コンテキストでない場所から `async` 関数を呼び出す場合は、その非同期処理を `Task` に包む必要があります。

たとえば、`View` や `Button` のタップ処理は同期処理として定義されています。この同期的な処理内で `async` 関数（非同期処理）を実行したいときに `Task` を使うことで、その場で非同期コンテキストを作り、`await` を使用して非同期処理を実行できます。

もし、`View` や `Button` のタップ処理の中で同期的に検索を行ってしまうと、その間にUIがフリーズしたり、他の操作を受け付けなくなってしまいます。`Task` を使うことで、検索が完了するまで他の操作をブロックせず、並行して処理を進められます。

- **メインスレッド上でUIの更新を保証するため**
非同期処理の結果をもとにUIを更新する場合、メインスレッドでの実行が保証されなければなりません。`Task` を使うことで、UI関連の処理を自動的にメインスレッドで行うことができるため、安全にUI更新が可能です。

例えば、カフェ検索の結果を受け取った後にUIを更新する場合、`Task` を使用すれば、メインスレッドでUIが確実に更新されます。


https://blog.personal-factory.com/2022/01/23/how-to-use-async-await-since-swift5_5/
