import Foundation
import Combine

class StationLineFinder: ObservableObject {
    static let shared = StationLineFinder()
    @Published private(set) var stations: [String: [String]] = [:]
    @Published private(set) var lines: [String: [String]] = [:]
    @Published var isLoaded: Bool = false
    
    private init() {
        Task {
            await loadStationsAndLines(from: "station_line")
        }
    }
    
    private func loadStationsAndLines(from file: String) async {
        guard let path = Bundle.main.path(forResource: file, ofType: "csv") else {
            print("StationLine file not found: \(file).csv")
            return
        }
        
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let rows = data.split(separator: "\n")
            
            await MainActor.run {
                for row in rows.dropFirst() {
                    let columns = row.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    if columns.count >= 2 {
                        let stationName = columns[0]
                        let lineName = columns[1]
                        
                        if stations[stationName] == nil {
                            stations[stationName] = []
                        }
                        stations[stationName]?.append(lineName)
                        
                        if lines[lineName] == nil {
                            lines[lineName] = []
                        }
                        lines[lineName]?.append(stationName)
                    }
                }
                isLoaded = true
            }
        } catch {
            print("Error reading station_line file: \(error)")
        }
    }
    
    func getLineNames(for stationName: String) -> [String]? {
        return stations[stationName]
    }
    
    func getStations(for lineName: String) -> [String]? {
        return lines[lineName]
    }
}
