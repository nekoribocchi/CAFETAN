import Foundation
import MapKit

// 2つの地図アイテム間の経路を計算する関数
func calculatedirections(from: MKMapItem, to: MKMapItem) async -> MKRoute? {
    // 経路リクエストの作成
    let directionsRequest = MKDirections.Request()
    directionsRequest.transportType = .automobile // 移動手段を自動車に設定
    directionsRequest.source = from // 出発地点
    directionsRequest.destination = to // 目的地点
    
    // 経路計算の実行
    let directions = MKDirections(request: directionsRequest)
    let response = try? await directions.calculate() // 経路計算を非同期で実行
    return response?.routes.first // 最初のルートを返す
}

// 2つの場所間の距離を計算する関数
func calculateDistance(from: CLLocation, to: CLLocation) -> Measurement<UnitLength> {
    // メートル単位での距離を計算
    let distanceInMeters = from.distance(from: to)
    // 距離をメートル単位のMeasurementオブジェクトとして返す
    return Measurement(value: distanceInMeters, unit: .meters)
}

// 検索用の関数
func performSearch(searchTerm: String, visibleRegion: MKCoordinateRegion?) async throws -> [MKMapItem] {
    // ローカル検索リクエストの作成
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchTerm // 検索クエリを設定
    request.resultTypes = .pointOfInterest // 検索結果のタイプをポイントオブインタレストに設定
    
    // 表示領域が指定されている場合、その領域を設定
    guard let region = visibleRegion else { return [] }
    request.region = region
    
    // 検索の実行
    let search = MKLocalSearch(request: request)
    let response = try await search.start() // 非同期で検索を実行
    
    // 検索結果のマップアイテムを返す
    return response.mapItems
}
