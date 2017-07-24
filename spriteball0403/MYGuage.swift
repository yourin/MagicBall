//
//  MYGuage.swift
//  spriteball0403
//
//  Created by 井上義晴 on 2017/07/18.
//  Copyright © 2017年 tone.youring. All rights reserved.
//
import UIKit
import SpriteKit


class MYGauge:SKSpriteNode{
    var timer: Timer!

    var gauge:SKSpriteNode!
    
    var height:CGFloat!
    var width:CGFloat!
    var sideLine:SKShapeNode!
    
    var value:Int! = 100
    var maxValue:Int! = 100
    var minValue:Int! = 0
    
    var autoRecovery = false
    var autoRecoveryTime:TimeInterval = 1.0
    var autoRecoveryValue:Int! = 1
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
//        self.height = height
//        self.width = width
//        let size = CGSize(width: width, height: height)
        self.gauge = SKSpriteNode(color: .white, size: size)
//        gauge.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.sideLine = SKShapeNode(rect: gauge.frame)
        self.sideLine.strokeColor = .white
        gauge.addChild(sideLine)
        
    }
    
//    init(width:CGFloat,height:CGFloat) {
//        super.init()
//        self.height = height
//        self.width = width
//        let size = CGSize(width: width, height: height)
//        self.gauge = SKSpriteNode(color: .white, size: size)
//        gauge.anchorPoint = CGPoint(x: 0.5, y: 0.0)
//        
//        self.sideLine = SKShapeNode(rect: gauge.frame)
//        self.sideLine.strokeColor = .white
//        gauge.addChild(sideLine)
//        
//
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //自動で回復する
    func autoRecoveryOn(){
        if !timer.isValid{
            timer = Timer.scheduledTimer(timeInterval: autoRecoveryTime, target: self, selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    func autoRecoveryOFF(){
        if timer.isValid{
            timer.invalidate()
        }
    }
    
    @objc func timerUpdate(){
        if maxValue > value {
            value = value + autoRecoveryValue
        }else
            if maxValue <= value {
                value = maxValue
        }
        
    }
    
        
    
    
}
