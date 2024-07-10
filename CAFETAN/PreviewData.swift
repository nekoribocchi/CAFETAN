import MapKit
import Contacts

struct PreviewData {
    static var home: MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009020) // Apple本社の座標
        let addressDictionary: [String: Any] = [
            CNPostalAddressStreetKey: "1 Apple Park Way",
            CNPostalAddressCityKey: "Cupertino",
            CNPostalAddressStateKey: "CA",
            CNPostalAddressPostalCodeKey: "95014",
            CNPostalAddressCountryKey: "USA"
        ]
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Apple Park"
        mapItem.url = URL(string: "https://www.apple.com")
        return mapItem
    }
}
