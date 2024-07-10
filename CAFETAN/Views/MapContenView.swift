import SwiftUI
import MapKit

struct PinViewWrapper: UIViewRepresentable {
    var color: Color
    
    func makeUIView(context: Context) -> PinView {
        let pinView = PinView(frame: .zero)
        pinView.pinColor = UIColor(color)
        return pinView
    }
    
    func updateUIView(_ uiView: PinView, context: Context) {
        uiView.pinColor = UIColor(color)
        uiView.setNeedsDisplay()
    }
}

struct MapContentView: View {
    @Binding var position: MapCameraPosition
    @Binding var mapItems: [MKMapItem]
    @Binding var selectedMapItem: MKMapItem?
    @Binding var route: MKRoute?
    @Binding var visibleRegion: MKCoordinateRegion?
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        Map(position: $position, selection: $selectedMapItem) {
            ForEach(mapItems.prefix(20), id: \.self) { mapItem in
                Annotation("",
                           coordinate: mapItem.placemark.coordinate, anchor: .bottom) {
                    ZStack {
                        PinViewWrapper(color: .green)
                            .frame(width: 50, height: 100)
                    }
                }
            }
            // 現在地のアイコンを表示する
            if let currentLocation =
                LocationManager.shared.manager.location{
                Annotation("",
                           coordinate: currentLocation.coordinate, anchor: .bottom) {
                    ZStack {
                        PinViewWrapper(color: .blue) // 現在地のピンの色を変更
                            .frame(width: 50, height: 100)
                    }
                }
            } // 経路が設定されている場合、ポリラインを描画
            if let route = route {
                MapPolyline(route)
                    .stroke(Color.blue, lineWidth: 6)
            }
        }
        
        .onMapCameraChange { context in
            visibleRegion = context.region
            
            
            // アニメーションを適用して地図の表示範囲を更新
            withAnimation(.easeInOut(duration: 1)) {
                visibleRegion = context.region
            }
        }
    }
}
