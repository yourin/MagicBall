//
//  MyEnemyCharaNode.swift
//  spriteball0403
//
//  Created by 井上義晴 on 2017/04/24.
//  Copyright © 2017年 tone.youring. All rights reserved.
//

import SpriteKit

//enum ActionPattern:Int {
//    case STOP
//    case MoveLEFT = 1
//    case MoveRIGHT = 2
//    case Throw  = 3
//}

class MyEnemyCharaNode:MyCharaNode {
    
//    var actionPattern = ActionPattern.STOP
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.direction = .DOWN
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func newAction(){
        if self.action == .STOP {
            
            
            
            
        }
        
        
    }
    
}
