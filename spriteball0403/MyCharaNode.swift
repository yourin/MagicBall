//
//  MyCharaNode.swift
//  spriteball0403
//
//  Created by 井上義晴 on 2017/04/13.
//  Copyright © 2017年 tone.youring. All rights reserved.
//

import SpriteKit

enum CharactorType:Int {
    case POWER  = 0
    case NORMAL = 1
    case SPEED  = 2
}

enum MoveSpeed:Int {
    case SLOW   = 0
    case NORMAL = 1
    case FAST   = 2
}

enum ThrowPower:Double {
    case WEAK   = 0.8
    case NORMAL = 1.0
    case STRONG = 1.5
}

enum MagicType:Int {
    case FIRE   = 0
    case ICE    = 1
    case THUNDER = 2
}

enum Direction:Int {
    case LEFT   = 0
    case DOWN   = 1
    case RIGHT  = 2
    case UP     = 3
    
}

enum Action:Int {
    case STOP = 0
    case BallThrow = 1
    case MoveToLeft = 2
    case MoveToRight = 3
}



class MyCharaNode:SKSpriteNode {
    var charaNumber:Int! = 0
    var charType:CharactorType! = .NORMAL
    var moveSpeed:MoveSpeed!    = .NORMAL
    var throwPower:ThrowPower!  = .NORMAL
    var magicType:MagicType!    = .FIRE
    var action:Action!          = .STOP
    var direction:Direction!    = .UP
    
    var life:Int = 100  //
    var ary_LeftTextures:[SKTexture]!    = [SKTexture]()
    var ary_RightTextures:[SKTexture]!   = [SKTexture]()
    var ary_UpTextures:[SKTexture]!      = [SKTexture]()
    var ary_DownTextures:[SKTexture]!    = [SKTexture]()

    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCharaType(type:CharactorType){
        switch type {
            
        case .POWER:
            moveSpeed = MoveSpeed.SLOW
            throwPower = ThrowPower.STRONG
            print("パワータイプ")

        case .SPEED:
            moveSpeed = MoveSpeed.FAST
            throwPower = ThrowPower.WEAK
            print("スピードタイプ")
        case .NORMAL:
            print("ノーマルタイプ")
        }
        
    }
    
    // テクスチャファイル名、横のタイル数、縦のタイル数
    
    class func make_tile(textureName:String,numRow:UInt,numColums:UInt) -> [SKTexture]{
        let texture = SKTexture(imageNamed: textureName)
        let tileSizeX:CGFloat = 1.0 / CGFloat(numRow)
        let tileSizeY:CGFloat = 1.0 / CGFloat(numColums)
        var aryTexture = [SKTexture]()
        
        for j in 0..<numColums{
            for i in 0..<numRow {
                let rect = CGRect(x:  CGFloat(i) / CGFloat(numRow), y: CGFloat(j) / CGFloat(numColums),
                                  width: tileSizeX, height: tileSizeY)
                let tex = SKTexture(rect: rect, in: texture)
                aryTexture.append(tex)
            }
        }
        
        print("aryCount = \(aryTexture.count)")
        return aryTexture
    }
   
    func nextAction(){
        //停止中であるか？
        if self.action == .STOP {
            //ランダムで次のアクション
            let val:UInt32 = 10
            let nextValue = Int(arc4random_uniform(val))
            print("nextValue = \(nextValue)")
            
            switch nextValue{
            case 0:
                self.action = .STOP
                print("STOPにセット")
            case 1,3,7,8:
                self.action = .BallThrow
                print("BallThrowにセット")
            case 2,4:
                self.action = .MoveToLeft
                print("MoveLeftにセット")
            case 3,6:
                self.action = .MoveToRight
                print("MoveRightにセット")
            default:
                //self.action = .STOP
                print("変更しない")
            }
        }
        
        
    }
    

}
