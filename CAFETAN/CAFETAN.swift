import SwiftUI

@main
struct CAFETAN: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // バックグラウンドスレッドでI/O操作を実行
                    DispatchQueue.global(qos: .background).async {
                        if let data = NSData(contentsOfFile: "path/to/file") {
                            // I/O操作が完了した後の処理をメインスレッドで行う
                            DispatchQueue.main.async {
                                // メインスレッドでの更新処理
                                handleIOResult(data: data)
                            }
                        }
                    }
                }
        }
    }
    
    // I/O操作の結果を処理する関数
    private func handleIOResult(data: NSData) {
        print("I/O操作が完了しました。データサイズ: \(data.length) バイト")
    }
}
