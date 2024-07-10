import SwiftUI
import MapKit
import Foundation

// 位置情報関連のカスタムエラー型の定義
enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case unknownLocation
    case accessDenied
    case network
    case operationFailed
    
    // 各エラーに対応するローカライズされたエラーメッセージを定義
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return NSLocalizedString("Location access denied.", comment: "")
        case .authorizationRestricted:
            return NSLocalizedString("Location access restricted.", comment: "")
        case .unknownLocation:
            return NSLocalizedString("Unknown location.", comment: "")
        case .accessDenied:
            return NSLocalizedString("Access denied.", comment: "")
        case .network:
            return NSLocalizedString("Network failed.", comment: "")
        case .operationFailed:
            return NSLocalizedString("Operation failed.", comment: "")
        }
    }
}

// `ObservableObject`プロトコルに準拠した`LocationManager`クラス
class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    // `CLLocationManager`インスタンスの作成
    let manager = CLLocationManager()
    static let shared = LocationManager() // シングルトンインスタンスの作成
    @Published var error: LocationError? = nil // エラーを保持するプロパティ
    @Published var showAlert: Bool = false
    @Published var region: MKCoordinateRegion = MKCoordinateRegion() // 現在の地域情報を保持するプロパティ
    @Published var userLocation: CLLocation?
    @Published var nearestStation: MKMapItem?
    @Published var errorMessage: String?
    @Published var highlightedStation: String?
    private var searchRadius: Double = 0.0005 // 検索範囲の初期値50m
    private var isSearching: Bool = false // 検索中かどうかを示すフラグ
    
    // プライベートな初期化メソッド
    private override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest // 最高精度の設定
        manager.distanceFilter = 30 // 30メートルごとに位置情報を更新
        self.manager.delegate = self // デリゲートの設定
        self.manager.requestWhenInUseAuthorization()
    }
    
    // 位置情報が更新されたときに呼び出されるメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: searchRadius, longitudeDelta: searchRadius))
            self.userLocation = location
            if !isSearching {
                findNearestStation()
            }
        }
    }

    // 認証ステータスが変更されたときに呼び出されるメソッド
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization() // 位置情報の利用許可をリクエスト
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation() // 位置情報の更新を開始
        case .denied:
            error = .authorizationDenied // エラーを設定
        case .restricted:
            error = .authorizationRestricted // エラーを設定
        @unknown default:
            break
        }
    }
    
    // 位置情報の取得に失敗したときに呼び出されるメソッド
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                self.error = .unknownLocation // エラーを設定
            case .denied:
                self.error = .accessDenied // エラーを設定
            case .network:
                self.error = .network // エラーを設定
            default:
                self.error = .operationFailed // エラーを設定
            }
        }
        self.errorMessage = error.localizedDescription
    }
    
    // 現在地から最寄り駅を検索するメソッド
    private func findNearestStation() {
        guard let userLocation = userLocation, !isSearching else { return }
        
        isSearching = true // 検索中フラグを設定
        
        // 検索リクエストを作成
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "駅" // 検索クエリを設定 駅を検索対象
        request.region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: searchRadius, longitudeDelta: searchRadius)) // 検索範囲を設定
        let search = MKLocalSearch(request: request)
        
        // 検索を開始
        search.start { response, error in
            defer { self.isSearching = false } // 検索終了後にフラグをリセット
            
            if let error = error {
                self.errorMessage = error.localizedDescription // エラーメッセージを設定
                self.showAlert = true // アラートを表示するためのフラグを設定
                return
            }
            
            // 検索結果を処理
                       if let mapItems = response?.mapItems, !mapItems.isEmpty {
                           if let nearestItem = mapItems.first {
                               let distance = userLocation.distance(from: nearestItem.placemark.location!)
                               if distance > 5000 { // 5km以上の場合
                                   print("見つかった最寄駅 \(nearestItem.name ?? "不明") が5km以上離れています: \(distance)メートル")
                                   self.searchRadius *= 2 // 検索範囲を広げる
                                   self.isSearching = false // 検索中フラグをリセット
                                   self.findNearestStation() // 再検索
                               } else {
                                   self.nearestStation = nearestItem // 最寄り駅を設定
                                   self.highlightedStation = nearestItem.name // ハイライトする駅名を設定
                                   self.printNearestStationDetails() // 検索結果を出力
                                   self.isSearching = false // 検索終了後にフラグをリセット
                               }
                           }
                       } else {
                           if self.searchRadius < 0.1 { // 最大範囲を指定
                               self.searchRadius *= 2 // 検索範囲を広げる
                               print("再検索: 緯度の範囲 = \(self.searchRadius), 経度の範囲 = \(self.searchRadius)")
                               self.isSearching = false // 検索中フラグをリセット
                               self.findNearestStation() // 再検索
                           } else {
                               self.errorMessage = "近くに駅が見つかりませんでした。" // エラーメッセージを設定
                               self.showAlert = true // アラートを表示するためのフラグを設定
                               self.isSearching = false // 検索終了後にフラグをリセット
                           }
                       }
                   }
               }

    
    // 最寄り駅の情報をコンソールに出力する関数
    func printNearestStationDetails() {
        if let nearestStation = nearestStation {
            print("最寄り駅: \(nearestStation.name ?? "不明")")
        } else {
            print(errorMessage ?? "最寄り駅を検索中...")
        }
    }
    
    // 現在地を更新するメソッド
    func updateLocation() {
        manager.requestLocation()
    }
}
