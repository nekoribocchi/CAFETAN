import SwiftUI
import MapKit

struct PlaceListView: View {
    let mapItems: [MKMapItem]
    @Binding var selectedMapItem: MKMapItem?
    let stationName: String // 駅名を追加
    let onSelect: (MKMapItem) -> Void
    
    private var sortedItems: [MKMapItem] {
        guard let userLocation = LocationManager.shared.manager.location else {
            return mapItems
        }
        
        return mapItems.sorted { lhs, rhs in
            guard let lhsLocation = lhs.placemark.location,
                  let rhsLocation = rhs.placemark.location else {
                return false
            }
            
            let lhsDistance = userLocation.distance(from: lhsLocation)
            let rhsDistance = userLocation.distance(from: rhsLocation)
            
            return lhsDistance < rhsDistance
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                
                Text("【 \(stationName) 】周辺カフェ")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.gray)
                    .padding(.top, 30)
                    .padding(.bottom, 5)
                    .background(Color.white.opacity(0.7))
                
                //list初め
                List(sortedItems, id: \.self, selection: $selectedMapItem) { mapItem in
                    // URLが存在する場合のみNavigationLinkを作成
                    if let url = mapItem.url, WebView(url: url).hasValidURL() {
                        NavigationLink(destination: SelectedPlaceDetailView(mapItem: .constant(mapItem))) {
                            // 各地図アイテムを表示するためのPlaceView
                            PlaceView(mapItem: mapItem)
                                .listRowBackground(Color.white.opacity(0.7)) // セルの背景を半透明に設定
                                .frame(maxWidth: .infinity, alignment: .leading) // セルの幅を親ビューに合わせる
                                .onTapGesture {
                                    onSelect(mapItem) // カフェが選択されたときにクロージャを呼び出す
                                }
                        }
                    } else {
                        // URLが存在しない場合、ただのテキストビューを表示
                        HStack {
                            PlaceView(mapItem: mapItem)
                                .listRowBackground(Color.white.opacity(0.7)) // セルの背景を半透明に設定
                                .frame(maxWidth: .infinity, alignment: .leading) // セルの幅を親ビューに合わせる
                            Spacer()
                                .frame(width: 20)
                                .onTapGesture {
                                    onSelect(mapItem) // カフェが選択されたときにクロージャを呼び出す
                                }// 右側に空白を追加
                        }
                        
                    }
                    
                } .background(Color.white.opacity(0.7))
                    .scrollContentBackground(.hidden)
                    .padding(.top, -10)
                //list終わり
                
                
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white.opacity(0.7))
        }
    }
}

#Preview{
    ContentView()
}
