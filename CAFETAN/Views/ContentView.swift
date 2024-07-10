import SwiftUI
import MapKit

enum DisplayMode {
    case list
    case detail
}

struct ContentView: View {
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var query: String = ""
    @State private var isSearching: Bool = false
    @State private var selectedDetent: PresentationDetent = .fraction(0.15)
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var mapItems: [MKMapItem] = []
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var selectedMapItem: IdentifiableMapItem?
    @State private var displayMode: DisplayMode = .list
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var route: MKRoute?
    @State private var webViewURL: URL?
    let finder = StationLineFinder.shared
    @State private var selectedStation: String?
    @State private var selectedLine: String?
    @State private var stationNames: [String] = []
    @State private var showPopover: Bool = false  // ポップオーバー表示用の状態変数
    
    private var lineNames: [String] {
        if let nearestStationName = locationManager.nearestStation?.name {
            let sanitizedStationName = nearestStationName.replacingOccurrences(of: "駅", with: "")
            return finder.getLineNames(for: sanitizedStationName) ?? []
        }
        return []
    }
    
    var body: some View {
        ZStack {
            MapView(
                position: $position,
                mapItems: $mapItems,
                selectedMapItem: Binding(
                    get: { selectedMapItem?.mapItem },
                    set: { newValue in
                        if let newValue = newValue {
                            selectedMapItem = IdentifiableMapItem(mapItem: newValue)
                            // マップピンが選択されたときにリストの選択を更新
                            Task {
                                await requestCalculateDirections(to: newValue)
                            }
                        }
                    }
                ),
                displayMode: $displayMode,
                selectedDetent: $selectedDetent,
                route: $route,
                webViewURL: $webViewURL,
                visibleRegion: $visibleRegion,
                locationManager: locationManager,
                stationName: selectedStation ?? "未選択"
            )
            
            VStack {
                HStack {
                    LineButton(stationFinder: finder, selectedLineName: selectedLine)
                    CurrentLocationButton(action: {
                        updateSelectedLine()
                    })
                }
                SearchOptionsView(
                    stations: stationNames,
                    highlightedStation: $locationManager.highlightedStation,
                    onSelected: { selectedStation in
                        self.selectedStation = selectedStation
                        self.showPopover = true  // 駅が選択されたときにポップオーバーを表示
                        Task {
                            await searchCafes(near: Station(name: selectedStation))
                        }
                    },
                    selectedLine: $selectedLine,
                    requestCalculateDirections: requestCalculateDirections // ここで関数を渡す
                )

                Spacer()
            }
        }
        .onAppear {
            updateSelectedLine()
            updateStationNames() // 起動時に駅名を更新
        }
        .onChange(of: selectedLine) {
            updateStationNames()
        }
    }
    
    private func updateSelectedLine() {
        if let nearestStationName = locationManager.nearestStation?.name {
            let sanitizedStationName = nearestStationName.replacingOccurrences(of: "駅", with: "")
            if let lineNames = finder.getLineNames(for: sanitizedStationName), !lineNames.isEmpty {
                selectedLine = lineNames.first
                updateStationNames() // selectedLineが更新された後にstationNamesを更新
            }
        }
    }
    
    private func updateStationNames() {
        if let selectedLine = selectedLine, !selectedLine.isEmpty {
            stationNames = finder.getStations(for: selectedLine) ?? []
        } else {
            stationNames = []
        }
    }
    
    private func requestCalculateDirections(to mapItem: MKMapItem) async {
        route = nil
        guard let currentUserLocation = locationManager.manager.location else { return }
        let startingMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
        let request = MKDirections.Request()
        request.source = startingMapItem
        request.destination = mapItem
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            await MainActor.run {
                self.route = response.routes.first
            }
        } catch {
            print("Error calculating directions: \(error)")
        }
    }
    
    private func searchCafes(near station: Station) async {
        query = "\(station)駅　近くのカフェ"
        isSearching = true
        print("\(station.name)駅近くのカフェ")
        
        CafeSearchManager.shared.searchCafes(near: station.name) { items in
            DispatchQueue.main.async {
                self.mapItems = items ?? []
                self.isSearching = false
                print("Search completed, found \(self.mapItems.count) items")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
