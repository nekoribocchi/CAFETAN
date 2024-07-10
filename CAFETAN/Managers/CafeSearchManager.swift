//CafeSearchManagerクラスは検索結果をキャッシュし、同じ駅に対する再検索を高速化
//CafeSearchManagerクラスは、特定の駅周辺のカフェを検索し、検索結果をキャッシュに保存することで、同じ駅に対する再検索時にキャッシュを利用して高速化を図りる
//これにより、ネットワークリクエストの頻度を減らし、エネルギー消費を抑える

import Foundation
import MapKit
import Combine
class CafeSearchManager {
    static let shared = CafeSearchManager()
    private var searchCache = [String: (results: [MKMapItem], timestamp: Date)]()
    private let cacheQueue = DispatchQueue(label: "com.example.CafeSearchCacheQueue")
    private let cacheExpirationInterval: TimeInterval = 60 * 60 // 1時間
    
    
    func searchCafes(near station: String, completion: @escaping ([MKMapItem]?) -> Void) {
        cacheQueue.async {
            // キャッシュのチェック
            if let cachedData = self.searchCache[station] {
                let cacheAge = Date().timeIntervalSince(cachedData.timestamp)
                if cacheAge < self.cacheExpirationInterval {
                    // キャッシュが有効期限内であればそれを返す
                    DispatchQueue.main.async {
                        completion(cachedData.results)
                    }
                    
                    return
                }
            }
            
            // キャッシュがない、または有効期限が切れている場合はネットワークリクエストを行う
            let query = "\(station)駅　近くのカフェ"
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                if let response = response {
                    // 結果をキャッシュに保存
                    self.cacheQueue.async {
                        self.searchCache[station] = (response.mapItems, Date())
                    }
                    // メインスレッドで結果を返す
                    DispatchQueue.main.async {
                        completion(response.mapItems)
                    }
                } else {
                    // エラーが発生した場合はnilを返す
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
}
