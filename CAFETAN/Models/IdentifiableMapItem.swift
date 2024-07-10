
import Foundation
import MapKit

class IdentifiableMapItem: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
}
