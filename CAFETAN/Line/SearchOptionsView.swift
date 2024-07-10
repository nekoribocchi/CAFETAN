import SwiftUI
import MapKit

struct SearchOptionsView: View {
    @State private var stations: [String]
    @Binding var highlightedStation: String?
    let onSelected: (String) -> Void
    @State private var selectedStation: String?
    @State private var lineNames: [String] = []
    @State private var showLinesSheet: Bool = false
    @Binding var selectedLineName: String?
    @ObservedObject private var stationFinder = StationLineFinder.shared
    @State private var showPopover: Bool = false // ポップオーバー表示用の状態変数
    @State private var mapItems: [MKMapItem] = [] // ポップオーバーに渡すためのマップアイテム
    @State private var selectedMapItem: MKMapItem? = nil // 選択されたマップアイテム
    @State private var displayMode: DisplayMode = .list // 表示モード
    @State private var selectedDetent: PresentationDetent = .fraction(0.1) // 選択されたデテント
    @State private var webViewURL: URL? = nil // WebViewのURL
    let requestCalculateDirections: (MKMapItem) async -> Void // 渡す関数
    
    
    init(stations: [String], highlightedStation: Binding<String?>, onSelected: @escaping (String) -> Void, selectedLine: Binding<String?>, requestCalculateDirections: @escaping (MKMapItem) async -> Void) {
        _stations = State(initialValue: stations)
        self._highlightedStation = highlightedStation
        self.onSelected = onSelected
        self._selectedLineName = selectedLine
        self.requestCalculateDirections = requestCalculateDirections // ここで初期化
    }


    private var unwrappedSelectedLineName: Binding<String> {
        Binding(
            get: { selectedLineName ?? "" },
            set: { selectedLineName = $0.isEmpty ? nil : $0 }
        )
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 4) {
                    ForEach(stations, id: \.self) { station in
                        LineSelectButton(
                            station: station,
                            highlightedStation: $highlightedStation,
                            onSelected: { selectedStation in
                                self.selectedStation = selectedStation
                                self.onSelected(selectedStation)
                                Task {
                                    await searchCafes(near: selectedStation)
                                    self.showPopover = true
                                }
                            },
                            lineNames: $lineNames,
                            showLinesSheet: $showLinesSheet,
                            selectedStation: $selectedStation,
                            stationFinder: stationFinder,
                            selectedLineName: unwrappedSelectedLineName,
                            showPopover: $showPopover // ポップオーバー表示用の状態変数を渡す
                        )
                    }
                }
            }
        }
        .background(Color.clear) // 全体の背景色をクリアにする
        .onChange(of: selectedLineName) { oldLineName, newLineName in
            if let newLineName = newLineName, let stations = stationFinder.getStations(for: newLineName) {
                self.stations = stations
            } else {
                self.stations = []
            }
        }
        .popover(isPresented: $showPopover,attachmentAnchor: .point(.trailing)) {
            PopoverContentView(
                mapItems: $mapItems, // カフェリストを渡す
                selectedMapItem: $selectedMapItem, // 選択されたマップアイテム
                displayMode: $displayMode, // 表示モード
                selectedDetent: $selectedDetent, // 選択されたデテント
                webViewURL: $webViewURL, // WebViewのURL
                stationName: selectedStation ?? "未選択",
                onSelect: { mapItem in
                    selectedMapItem = mapItem
                    Task {
                        await requestCalculateDirections(mapItem)
                    }
                   // showPopover = false  // ポップオーバーを閉じる
                }
            )
            .frame(width: 400, height: UIScreen.main.bounds.height*0.8)  // ポップオーバーのサイズをデバイスの高さの80%に設定
        }
    }
    private func searchCafes(near station: String) async {
        await withCheckedContinuation { continuation in
            CafeSearchManager.shared.searchCafes(near: station) { items in
                DispatchQueue.main.async {
                    self.mapItems = items ?? []
                    self.showPopover = true
                    continuation.resume()
                }
            }
        }
    }
}

#Preview{
        ContentView()
    }


