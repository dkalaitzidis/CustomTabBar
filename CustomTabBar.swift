//
//  CustomTabBar.swift
//  CustomTabBar
//
//  Created by Dimitrios Kalaitzidis on 25/02/2019.
//  Copyright © 2019 Dimitrios Kalaitzidis. All rights reserved.
//

import UIKit

@IBDesignable class CustomTabBar: UITabBar {

    @IBInspectable public var customBarBackgroundColor : UIColor = UIColor.white
    @IBInspectable public var customBarHeight : CGFloat = 65
    @IBInspectable public var customBarTopRadius : CGFloat = 20
    @IBInspectable public var customBarBottomRadius : CGFloat = 20

    @IBInspectable public var customBarCircleBackgroundColor : UIColor = UIColor.white
    @IBInspectable public var customBarCircleRadius : CGFloat = 40

    @IBInspectable var customBarMarginBottom : CGFloat = 5
    @IBInspectable var customBarMarginTop : CGFloat = 0
    @IBInspectable var customMarginLeft : CGFloat = 15
    @IBInspectable var customMarginRight : CGFloat = 15


    let customBarCornerRad : CGFloat = 10
    let customBarCircleDistanceOffset : CGFloat = 7
    let animationDuration: TimeInterval = 0.3

    let pi = CGFloat.pi
    let pi2 = CGFloat.pi / 2

    private var barRect : CGRect{
        get{
            let height = customBarHeight
            let width = bounds.width - (customMarginLeft + customMarginRight)
            let x = bounds.minX + customMarginLeft
            let y = customBarMarginTop + customBarCircleRadius

            let rect = CGRect(x: x, y: y, width: width, height: height)
            return rect
        }
    }

    private func createCircleRect() -> CGRect{

        let backRect = barRect
        let radius = customBarCircleRadius
        let circleXCenter = getCircleCenter()
        let x : CGFloat = circleXCenter - radius
        let y = backRect.origin.y - radius + customBarCircleDistanceOffset
        let pos = CGPoint(x: x, y: y)
        let size = CGSize(width: radius * 2, height: radius * 2)

        let result = CGRect(origin: pos, size: size)
        return result
    }

    private func createCirclePath() -> CGPath{
        let circleRect = createCircleRect()
        let result = UIBezierPath(roundedRect: circleRect, cornerRadius: circleRect.height / 2)

        return result.cgPath
    }


    private func getCircleCenter() -> CGFloat{
        let totalWidth = self.bounds.width
        var x = totalWidth / 2
        if let v = getViewForItem(item: selectedItem){
            x = v.frame.minX + (v.frame.width / 2)
        }

        return x
    }


    func createPitMaskPath(rect: CGRect) -> CGMutablePath {
        let circleXcenter = getCircleCenter()
        let backRect = barRect
        let x : CGFloat = circleXcenter + customBarCornerRad
        let y = backRect.origin.y

        let center = CGPoint(x: x, y: y)

        let maskPath = CGMutablePath()
            maskPath.addRect(rect)

        let pit = createPitPath(center: center)
            maskPath.addPath(pit)

        return maskPath
    }



    func createPitPath(center : CGPoint) -> CGPath{
        let rad = customBarCircleRadius + 5
        let x = center.x - rad - customBarCornerRad
        let y = center.y

        let result = UIBezierPath()
            result.lineWidth = 0
            result.move(to: CGPoint(x: x, y: y))

            result.addArc(withCenter: CGPoint(x: (x - customBarCornerRad), y: (y + customBarCornerRad)), radius: customBarCornerRad, startAngle: CGFloat(270).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: true)

            result.addArc(withCenter: CGPoint(x: (x + rad), y: (y + customBarCornerRad ) ), radius: rad, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: false)

            result.addArc(withCenter: CGPoint(x: (x + (rad * 2) + customBarCornerRad), y: (y + customBarCornerRad) ), radius: customBarCornerRad, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(270).toRadians(), clockwise: true)

            result.addLine(to: CGPoint(x: x + (customBarCornerRad * 2) + (rad * 2), y: y))
            result.addLine(to: CGPoint(x: 0, y: 0))
            result.close()

        return result.cgPath
    }

    private func createBackgroundPath() -> CGPath{
        let rect = barRect
        let topLeftRadius = customBarTopRadius
        let topRightRadius = customBarTopRadius
        let bottomRigtRadius = customBarBottomRadius
        let bottomLeftRadius = customBarBottomRadius

        let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - topLeftRadius, y:rect.minY))

            path.addArc(withCenter: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius), radius: topRightRadius, startAngle:3 * pi2, endAngle: 0, clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRigtRadius))
            path.addArc(withCenter: CGPoint(x: rect.maxX - bottomRigtRadius, y: rect.maxY - bottomRigtRadius), radius: bottomRigtRadius, startAngle: 0, endAngle: pi2, clockwise: true)
            path.addLine(to: CGPoint(x: rect.minX + bottomRigtRadius, y: rect.maxY))
            path.addArc(withCenter: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY - bottomLeftRadius), radius: bottomLeftRadius, startAngle: pi2, endAngle: pi, clockwise: true)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
            path.addArc(withCenter: CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius), radius: topLeftRadius, startAngle: pi, endAngle: 3 * pi2, clockwise: true)
            path.close()

        return path.cgPath
    }

    private lazy var background: CAShapeLayer = {
        let result = CAShapeLayer()
            result.fillColor = customBarBackgroundColor.cgColor
            result.mask = backgroundMask

        return result
    }()

    private lazy var circle : CAShapeLayer = {
        let result = CAShapeLayer()
            result.fillColor = customBarCircleBackgroundColor.cgColor

        return result
    }()

    private lazy var backgroundMask : CAShapeLayer = {
        let result = CAShapeLayer()
        result.fillRule = .evenOdd
        return result
    }()

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
            sizeThatFits.height = customBarHeight + customBarMarginTop + customBarMarginBottom + customBarCircleRadius
        return sizeThatFits
    }

    private func getTabBarItemViews() -> [(item : UITabBarItem, view : UIView)]{
        guard let items = self.items else {
            return []
        }

        var result : [(item : UITabBarItem, view : UIView)] = []
        for item in items {
            if let v = getViewForItem(item: item) {
                result.append((item: item, view: v))
            }
        }

        return result
    }

    private func getViewForItem(item : UITabBarItem?) -> UIView? {
        if let item = item {
            let v = item.value(forKey: "view") as? UIView
            return v
        }

        return nil

    }

    private func positionItem(barRect : CGRect, totalCount : Int, idx : Int, item : UITabBarItem, view : UIView) -> CGRect {
        let margin : CGFloat = 5
        let x = view.frame.origin.x
        var y = barRect.origin.y + margin
        let height = customBarHeight - (margin * 2)
        let width = view.frame.width
        if selectedItem == item {
            y = barRect.origin.y - (customBarCircleRadius / 2)
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func animateItems(itemView : UIView, frameRect: CGRect){
        UIView.animate(withDuration: animationDuration, animations: {
            itemView.frame = frameRect
        })
    }

    private func createPathMoveAnimation(toVal : CGPath) -> CABasicAnimation {

        let animation = CABasicAnimation(keyPath: "path")
            animation.duration = animationDuration
            animation.toValue = toVal
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards

        return animation
    }

    private func replaceAnimation(layer: CAShapeLayer, withNew: CABasicAnimation, forKey: String) {

        let existing = layer.animation(forKey: forKey) as? CABasicAnimation
        if existing != nil {
            withNew.fromValue = existing!.toValue
        }

        layer.removeAnimation(forKey: forKey)
        layer.add(withNew, forKey: forKey)
    }

    private func moveCircleAnimated(){
        let bgMaskNewPath = createPitMaskPath(rect: self.bounds)
        let circleNewPath = createCirclePath()

        let bgAni = createPathMoveAnimation(toVal: bgMaskNewPath)
        let circleAni = createPathMoveAnimation(toVal: circleNewPath)

        replaceAnimation(layer: backgroundMask, withNew: bgAni, forKey: "move_animation")
        replaceAnimation(layer: circle, withNew: circleAni, forKey: "move_animation")

    }

    private func layoutElements(selectedChanged : Bool){
        background.path = createBackgroundPath()
        if backgroundMask.path == nil {
            backgroundMask.path = createPitMaskPath(rect: self.bounds)
            circle.path = createCirclePath()
        }
        else{
            moveCircleAnimated()
        }

        let items = getTabBarItemViews()
        if items.count <= 0 {
            return
        }

        let barR = barRect
        let total = items.count
        for (idx, item) in items.enumerated() {
            let frameRect = positionItem(barRect: barR, totalCount: total, idx: idx, item: item.item, view: item.view)

            if selectedChanged {
                animateItems(itemView: item.view, frameRect: frameRect)
            } else {
                item.view.frame = frameRect
            }
        }
    }

    override var selectedItem: UITabBarItem? {
        get{
            return super.selectedItem
        }
        set{
            let changed = super.selectedItem != newValue
            super.selectedItem = newValue
            if changed {
                layoutElements(selectedChanged: changed)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        background.fillColor = customBarBackgroundColor.cgColor
        circle.fillColor = customBarCircleBackgroundColor.cgColor

        self.layoutElements(selectedChanged: false)
    }

    override func prepareForInterfaceBuilder() {
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()

        background.fillColor = customBarCircleBackgroundColor.cgColor
        circle.fillColor = customBarCircleBackgroundColor.cgColor
    }

    private func setup(){
        self.isTranslucent = true
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
        self.layer.insertSublayer(background, at: 0)
        self.layer.insertSublayer(circle, at: 0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

}

extension CGFloat {
    public func toRadians() -> CGFloat {
        return self * CGFloat.pi / 180.0
    }
}
