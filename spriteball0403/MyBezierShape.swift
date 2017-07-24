//
//  MyBezierShape.swift
//  spriteball0403
//
//  Created by 井上義晴 on 2017/04/08.
//  Copyright © 2017年 tone.youring. All rights reserved.
//

import UIKit
import SpriteKit

class MyBezierShape: UIBezierPath {
    
    struct Bezier4Points {
        var stP:CGPoint!
        var contP1:CGPoint!
        var contP2:CGPoint!
        var endP:CGPoint!
    }
    
    struct Bezier3Points {
        var stP:CGPoint!
        var contP:CGPoint!
        var endP:CGPoint!
    }

    class func makeShapeLineFormPath<T>(cgPath:T) -> SKShapeNode{
        return SKShapeNode(path: cgPath as! CGPath)
    }
    
    class func makeShapeLineFormPath(b4p:Bezier4Points) ->SKShapeNode{
        let cgPath = makeLinePathFrom4Points(b4p: b4p)
        return SKShapeNode(path: cgPath)
    }
    
    class func makeLinePathFrom4Points(b4p:Bezier4Points) -> CGPath{
        let path = UIBezierPath()
        path.move(to: b4p.stP)
        path.addCurve(to: b4p.endP, controlPoint1: b4p.contP1 , controlPoint2: b4p.contP2)
        return path.cgPath
    }
    
    class func makeLinePathFrom3Points(b3p:Bezier3Points) -> CGPath{

        let path = UIBezierPath()
        path.move(to: b3p.stP)
        path.addQuadCurve(to: b3p.endP , controlPoint:b3p.contP)
        return path.cgPath
    }
    
    class func makeLinePath(beganPoint:CGPoint,endPoint:CGPoint) -> CGPath{
        
            // 線のパスを生成.
            let myPath = UIBezierPath()
            myPath.move(to: beganPoint)
            myPath.addLine(to: endPoint)
            
//            // パスを線に反映.
//            myLine.path = myPath.cgPath
//            
//            // 線の色を設定.
//            myLine.strokeColor = .white
//            
//            // 線の太さ.
//            myLine.lineWidth = 1.0
//            
//            // グローの幅.
//            myLine.glowWidth = 3.0
        
            // Sceneに追加.
            return myPath.cgPath
        

    }
    
}
