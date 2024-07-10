import UIKit

class PinView: UIView {
    var pinColor: UIColor = UIColor.green // デフォルトの色を設定
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard UIGraphicsGetCurrentContext() != nil else { return }
        
        let outerRadius: CGFloat = rect.width / 4
        let innerRadius: CGFloat = outerRadius / 2.5
        let center = CGPoint(x: rect.width / 2, y: rect.height / 1.22)
        pinColor.setFill()
        // 円弧と三角形を連続して描画
        let combinedPath = UIBezierPath()
        let startAngle: CGFloat = .pi
        let endAngle: CGFloat = 10
        
        // 左側の円弧
        combinedPath.addArc(withCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        // 三角形の頂点に向かう曲線
        let leftPoint = CGPoint(x: center.x - outerRadius * cos(.pi / 6), y: center.y + outerRadius * sin(.pi / 6))
        combinedPath.addLine(to: leftPoint)
        
        combinedPath.fill()
        // 三角形の頂点
        let bottomPoint = CGPoint(x: center.x, y: center.y + outerRadius * 1.5)
        combinedPath.addLine(to: bottomPoint)
        combinedPath.fill()
        // 右側の円弧と接続する点
        let rightPoint = CGPoint(x: center.x + outerRadius * cos(.pi / 6), y: center.y + outerRadius * sin(.pi / 6))
        combinedPath.addLine(to: rightPoint)
        combinedPath.fill()
        // 終了点に戻る
        combinedPath.addLine(to: CGPoint(x: center.x + outerRadius * cos(.pi), y: center.y - outerRadius * sin(.pi)))
        
        pinColor.setFill()
        combinedPath.fill()
        
        
        // 内側の円を描画
        let innerCirclePath = UIBezierPath(arcCenter: center, radius: innerRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        UIColor.white.setFill() // 内側の円を白くする
        innerCirclePath.fill()
        
    }
}

#Preview {
    PinView(frame: CGRect(x: 0, y: 0, width: 50, height: 80))
}
