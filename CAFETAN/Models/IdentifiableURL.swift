import Foundation
struct IdentifiableURL: Identifiable {
    var id = UUID() // ユニークID
    var url: URL // URL
}
