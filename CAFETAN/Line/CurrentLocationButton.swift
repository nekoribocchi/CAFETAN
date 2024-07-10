import SwiftUI

struct CurrentLocationButton: View {
    @ObservedObject private var locationManager = LocationManager.shared
    var action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                locationManager.updateLocation()
                action()
            }) {
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.white)
                    Text("最寄りの路線を表示")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color.green)
                .cornerRadius(10)
                .shadow(color: .gray, radius: 4, x: 0, y: 4)
            }
        }
    }
}

struct CurrentLocationButton_Previews: PreviewProvider {
    static var previews: some View {
        CurrentLocationButton(action: {})
    }
}

