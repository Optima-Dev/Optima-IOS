import UIKit

class OverlayMaskView: UIView {
    
    private let transparentRect = CGRect(x: 35, y: 61, width: 358, height: 644)

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(bounds)
        
        context.setBlendMode(.clear)
        context.fill(transparentRect)
        
        context.setBlendMode(.normal)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(4)
        
        let cornerLength: CGFloat = 30
        
        // Top-left corner
        context.move(to: CGPoint(x: transparentRect.minX, y: transparentRect.minY + cornerLength))
        context.addLine(to: CGPoint(x: transparentRect.minX, y: transparentRect.minY))
        context.addLine(to: CGPoint(x: transparentRect.minX + cornerLength, y: transparentRect.minY))
        
        // Top-right corner
        context.move(to: CGPoint(x: transparentRect.maxX - cornerLength, y: transparentRect.minY))
        context.addLine(to: CGPoint(x: transparentRect.maxX, y: transparentRect.minY))
        context.addLine(to: CGPoint(x: transparentRect.maxX, y: transparentRect.minY + cornerLength))
        
        // Bottom-left corner
        context.move(to: CGPoint(x: transparentRect.minX, y: transparentRect.maxY - cornerLength))
        context.addLine(to: CGPoint(x: transparentRect.minX, y: transparentRect.maxY))
        context.addLine(to: CGPoint(x: transparentRect.minX + cornerLength, y: transparentRect.maxY))
        
        // Bottom-right corner
        context.move(to: CGPoint(x: transparentRect.maxX - cornerLength, y: transparentRect.maxY))
        context.addLine(to: CGPoint(x: transparentRect.maxX, y: transparentRect.maxY))
        context.addLine(to: CGPoint(x: transparentRect.maxX, y: transparentRect.maxY - cornerLength))
        
        context.strokePath()
    }
}
