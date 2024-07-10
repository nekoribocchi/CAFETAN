import SwiftUI
import MapKit

struct MapView: View {
    @Binding var position: MapCameraPosition
    @Binding var mapItems: [MKMapItem]
    @Binding var selectedMapItem: MKMapItem?
    @Binding var displayMode: DisplayMode
    @Binding var selectedDetent: PresentationDetent
    @Binding var route: MKRoute?
    @Binding var webViewURL: URL?
    @Binding var visibleRegion: MKCoordinateRegion?
    @ObservedObject var locationManager: LocationManager
    let stationName: String // 駅名を追加
    
    var body: some View {
        ZStack {
            MapContentView(
                position: $position,
                mapItems: $mapItems,
                selectedMapItem: $selectedMapItem,
                route: $route,
                visibleRegion: $visibleRegion,
                locationManager: locationManager
            )
            
            .sheet(item: Binding(
                get: { webViewURL.map { IdentifiableURL(url: $0) } },
                set: { webViewURL = $0?.url }
            )) { identifiableURL in
                WebView(url: identifiableURL.url)
            }
        }
        .onChange(of: selectedMapItem) {
            Task {
                await requestCalculateDirections()
            }
        }
    }
    
    private func requestCalculateDirections() async {
        route = nil
        if let selectedMapItem {
            guard let currentUserLocation = locationManager.manager.location else { return }
            let startingMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
            let request = MKDirections.Request()
            request.source = startingMapItem
            request.destination = selectedMapItem
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
    }
}
