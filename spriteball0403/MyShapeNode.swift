

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
    var sizeRatio:CGFloat! = 1.0
    var ballCount:Int! = 0
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        self.ballCount = 0
        
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
    
    //    func makeBezierCurve4Points(pos:CGPoint) -> MyBezierShape.Bezier4Points{
    //
    //        var bp = MyBezierShape.Bezier4Points()
    //
    //        bp.stP = CGPoint(x: pos.x, y: _b4p.stP.y)
    //
    //        //スタート位置からエンド位置を計算する
    //        bp.endP = CGPoint(x: pos.x / 2.0, y: self.anchorPoint.y)
    //
    //        //コントロールポイント１、２を計算する
    //        //中心からタッチしたXまでと比率(ratio)を計算
    //        let contPos1Ratio =  abs(bp.stP.x) / (self.frame.size.width / 2.0)
    //        let contPos1X = abs(_b4p.contP1.x) * contPos1Ratio
    //
    //        bp.contP1 = CGPoint(x: contPos1X, y: _b4p.contP1.y)
    //
    //        let contPos2Ratio = abs(bp.endP.x) / (self.frame.size.width / 4.0)
    //        let contPos2X = abs(_b4p.contP2.x) * contPos2Ratio
    //
    //        bp.contP2 = CGPoint(x: contPos2X, y: _b4p.contP2.y)
    //
    //        //画面の左側がタッチされた場合は、ーXにする
    //        if pos.x < 0 {
    //            bp.contP1 = CGPoint(x: -contPos1X, y: _b4p.contP1.y)
    //            bp.contP2 = CGPoint(x: -contPos2X, y: _b4p.contP2.y)
    //        }
    //        return bp
    //    }

    
    
    //    func makeShapeLine(bp:MyBezierShape.Bezier4Points) -> SKShapeNode{
    //        let cgPath = makePath_4points(bp: bp)
    //
    //        let shape = SKShapeNode(path: cgPath)
    //        shape.strokeColor = .red
    //
    //        return shape
    //    }

    
    
    
    //    func makePath_4points(bp:MyBezierShape.Bezier4Points) -> CGPath{
    //        let path = UIBezierPath()
    //        path.move(to: bp.stP)
    //        path.addCurve(to: bp.endP, controlPoint1: bp.contP1, controlPoint2: bp.contP2)
    //        return path.cgPath
    //    }

    
}
