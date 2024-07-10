import SwiftUI
import MapKit

struct SelectedPlaceDetailView: View {
    @Binding var mapItem: MKMapItem?
    
    var body: some View {
        VStack(alignment: .leading){
            
            VStack(alignment: .leading) {
                
                if let mapItem = mapItem {
                    if let url = mapItem.url, WebView(url: url).hasValidURL() {
                        WebView(url: url)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    Text("No place selected")
                }
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 4)
        .padding()
    }
}

#Preview {
    let home = Binding<MKMapItem?>(
        get: { PreviewData.home },
        set: { _ in }
    )
    return SelectedPlaceDetailView(mapItem: home)
}
