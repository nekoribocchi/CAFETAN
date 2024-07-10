import SwiftUI
import MapKit

struct PopoverContentView: View {
    @Binding var mapItems: [MKMapItem]
    @Binding var selectedMapItem: MKMapItem?
    @Binding var displayMode: DisplayMode
    @Binding var selectedDetent: PresentationDetent
    @Binding var webViewURL: URL?
    let stationName: String
    let onSelect: (MKMapItem) -> Void

    var body: some View {
        VStack {
            switch displayMode {
            case .list:
                PlaceListView(mapItems: mapItems, selectedMapItem: $selectedMapItem, stationName: stationName, onSelect: onSelect)
            case .detail:
                SelectedPlaceDetailView(mapItem: $selectedMapItem)
                    .padding()
                if selectedDetent == .medium || selectedDetent == .large {
                    if let selectedMapItem, let url = selectedMapItem.url {
                        WebView(url: url)
                            .padding()
                    } else {
                        Text("ウェブサイトが見つかりません")
                            .padding()
                    }
                }
            }
            Spacer()
        }
        .background(Color.white)
        .presentationDetents([.fraction(0.1), .medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        
    }
}
