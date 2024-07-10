import SwiftUI

struct LineButton: View {
    @ObservedObject var stationFinder: StationLineFinder
    var selectedLineName: String?
    
    var body: some View {
        VStack {
            if stationFinder.isLoaded {
                if let selectedLineName = selectedLineName {
                    HStack{
                        Text(selectedLineName)
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(.gray)
                    .cornerRadius(10)
                    
                }
            }
        }
    }
}

struct LineButton_Previews: PreviewProvider {
    static var previews: some View {
        LineButton(stationFinder: StationLineFinder.shared, selectedLineName: "山手線")
    }
}
