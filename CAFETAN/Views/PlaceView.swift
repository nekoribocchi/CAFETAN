import SwiftUI
import MapKit

struct PlaceView: View {
    let mapItem: MKMapItem
    
    private var address: String {
        let placemark = mapItem.placemark
        return "\(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
    }
    
    private var distance: Measurement<UnitLength>? {
        guard let userLocation = LocationManager.shared.manager.location,
              let destinationLocation = mapItem.placemark.location
        else {
            return nil
        }
        return calculateDistance(from: userLocation, to: destinationLocation)
    }
    
    private var url: URL? {
        return mapItem.url
    }
    
    private var distanceFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter = numberFormatter
        formatter.unitOptions = .providedUnit
        return formatter
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 4) // セルに影を追加
            
            HStack {
                
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading) {
                    Text(mapItem.name ?? "")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                    if let distance = distance {
                        Text(distance.converted(to: .kilometers), formatter: distanceFormatter)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal) // 横方向のパディングを追加
        }
        .padding(.horizontal) // 横方向のパディングを追加
        .padding(.vertical, 5) // 縦方向のパディングを調整
    }
}

// プレビュー用データ
#Preview {
    PlaceView(mapItem: PreviewData.home)
}
