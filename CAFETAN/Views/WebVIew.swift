import SwiftUI
import WebKit

// WebView structはUIViewRepresentableプロトコルを採用している
struct WebView: UIViewRepresentable {
    // 表示するURLを保持するプロパティ
    let url: URL
    
    // makeUIViewは、UIViewを生成するメソッド
    func makeUIView(context: Context) -> WKWebView {
        // WKWebViewのインスタンスを返す
        return WKWebView()
    }
    
    // updateUIViewは、UIViewの状態を更新するメソッド
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 指定されたURLをロードするためのリクエストを作成
        let request = URLRequest(url: url)
        // WKWebViewにリクエストをロードする
        uiView.load(request)
    }
    
    // URLの有無を返すメソッド
    func hasValidURL() -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
}

// Previewプロバイダー
#Preview{
    // WebViewのインスタンスを作成し、Appleのホームページを表示
    WebView(url: URL(string: "https://www.apple.com")!)
        .edgesIgnoringSafeArea(.all) // WebViewを画面全体に広げる
}
