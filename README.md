# CAFETAN
***

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

## 非同期処理の流れ
1.LocationManager が非同期にユーザーの位置情報を取得します。

2.位置情報が更新されると、CafeSearchManager がその位置を基にカフェの情報を検索します。

3.検索結果が CafeSearchManager の cafes プロパティに保存されると、MapContentView が更新されます。

4.MapContentView の更新により、地図上にカフェの情報が表示されます。

5.ContentView は MapContentView の更新を受け取り、全体のUIを更新します。
