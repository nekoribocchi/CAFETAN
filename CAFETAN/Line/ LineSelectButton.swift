import SwiftUI
import MapKit

struct LineSelectButton: View {
    let station: String
    @Binding var highlightedStation: String?
    let onSelected: (String) -> Void
    @Binding var lineNames: [String]
    @Binding var showLinesSheet: Bool
    @Binding var selectedStation: String?
    @ObservedObject var stationFinder: StationLineFinder
    @Binding var selectedLineName: String
    @ObservedObject private var locationManager = LocationManager.shared // LocationManagerのインスタンスを取得
    @Binding var showPopover: Bool // ポップオーバー表示用の状態変数
    @State private var mapItems: [MKMapItem] = []
    
    var body: some View {
        Button(action: {
            // ボタンが押されたときに選択された駅を設定
            selectedStation = station
            // 駅に対応する路線名を取得
            lineNames = stationFinder.getLineNames(for: station) ?? []
            // ポップオーバーの表示状態を切り替え
            showPopover = true
            // 選択された駅名を親ビューに通知
            onSelected(station)
        }) {
            VStack {
                // 駅名テキストと背景
                Text(station)
                    .font(.headline)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isNearestStation(sanitizedStation: station) ? Color.green : Color.white) // ここで最寄り駅の場合の背景色を設定
                            .shadow(color: .gray, radius: 4, x: 0, y: 4)
                    )
                    .foregroundColor(isNearestStation(sanitizedStation: station) ? .white : .gray) // 文字の色を設定
                    .contextMenu {
                        // 駅に対応する路線名が存在する場合、コンテキストメニューに表示
                        if let lines = stationFinder.getLineNames(for: station) {
                            ForEach(lines, id: \.self) { line in
                                Button(action: {
                                    selectedStation = station
                                    lineNames = lines
                                    selectedLineName = line
                                    onSelected(station)
                                }) {
                                    Text(line)
                                }
                            }
                        } else {
                            Text("路線が見つかりません")
                        }
                    }
                    .foregroundColor(highlightedStation == station ? .black : .gray)
            }
            .padding(.bottom, 10) // ボタンの下部分に余白を追加
        }
    
    }

    // 駅名が最寄り駅かどうかを判定するメソッド
    private func isNearestStation(sanitizedStation: String) -> Bool {
        let sanitizedNearestStation = locationManager.nearestStation?.name?.replacingOccurrences(of: "駅", with: "") ?? ""
        return sanitizedStation.replacingOccurrences(of: "駅", with: "") == sanitizedNearestStation
    }
}
