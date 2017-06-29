

//
//  MyShapeNode.swift
//  spriteball0403
//
//  Created by 井上義晴 on 2017/04/15.
//  Copyright © 2017年 tone.youring. All rights reserved.
//

import SpriteKit

class MyShapeNode: SKShapeNode {
    
    var originalHeight:CGFloat! = 0.0
    var ballLevel:Int! = 0
    var emitter:SKEmitterNode!
//    var timer:Timer!
    var sizeRatio:CGFloat! = 1.0
    var ballCount:Int! = 0
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        self.ballCount = 0
        
//        self.timer = Timer.scheduledTimer(timeInterval: 1/30, target: self, selector: #selector(MyShapeNode.update), userInfo: nil, repeats: true)
//        
    }
    
//    func update(){
    
    //元サイズと比べてZPositionに変換
    func chenge_Fake3DPosisionZ(){
//        let z =  CGFloat(self.frame.size.height / self.originalHeight)
//        if z > 1.0 {
//        self.zPosition =  1.0
//        }else if z < 0.5 {
//        self.zPosition = 0.5
//        }
        self.zPosition =  CGFloat(self.frame.size.height / self.originalHeight)
    }
    
    func sizeToRatio(){
       self.sizeRatio =  CGFloat(self.frame.size.height / self.originalHeight)
//        print("\(self.name) sizeRatio = \(self.sizeRatio)")
    }
}
