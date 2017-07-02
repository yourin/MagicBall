//
//  GameScene.swift
//  spriteball0403
//
//  Created by 井上義晴 on 2017/04/03.
//  Copyright © 2017年 tone.youring. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

//enum Direction:Int {
//    case LEFT   = 0
//    case DOWN   = 1
//    case RIGHT  = 2
//    case UP     = 3
//    
//}
//
//enum Action:Int {
//    case Stop = 0
//    case BallThrow = 1
//    case MoveToLeft = 2
//    case MoveToRight = 3
//}

enum Throw:Int {
    case Nomal = 0
    case Big = 1
}


enum MagicBallType:Int {
    case FIRE = 0
    case ICE = 1
    case SPARK = 2
}

enum NodeName:String {
    case Player     = "player"
    case Enemy      = "enemy"
    case PlayerBall = "playerball"
    
    case EnemyBall  = "enemyball"
    case Shadow     = "shadow"
}


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let _playerBallName                 = "playerball"
    let _enemyBallName                  = "enemyball"
    let _playerName                     = "player"
    let _enemyName                      = "enemy"
    let _playerBallShadowName_A         = "playerballshadowA"
    let _enemyBallShadowName_A          = "enemyballshadowA"
    
    let _playerBallShadowName_B         = "playerballshadowB"
    let _enemyBallShadowNName_B         = "enemyballshadowB"
    
    
    let _playerCategory         :UInt32 = 0x01 << 1
//    let _playerBallCategory     :UInt32 = 0x01 << 2
//    let _playerBallShadowCategory:UInt32 = 0x01 << 5
    
    let _enemyCategory          :UInt32 = 0x01 << 3
//    let _enemyBallCategory      :UInt32 = 0x01 << 4
//    let _enemyBallShadowCategory:UInt32 = 0x01 << 6
    
    
//    let _playerRangeX = SKRange()
//    let _enemyRangeX = SKRange()
    
    var _life_Player = 100
    var _life_Enemy  = 100
    
    var _playerDummyball:MyShapeNode!
    var _enemyDummyball:MyShapeNode!
    
    
    let _throwSec_Short = 1.0 //秒
    
    var _isTouchON      = false
    var _isTouchMove    = false
    var _hasDummyBall_Player   = false
    
    var _beganPoint:CGPoint!
    
    var _upDateCount_Touch = 0

    var _ballCount = 1
    var _hasBallName  = ""
    
    let _ary_BallRadius:[CGFloat] = [5.0,10.0,15.0,30.0]
    var _power = 0
    
    var _cgPath:CGPath? = nil
    
    var _b3p = MyBezierShape.Bezier3Points()
    var _b4p = MyBezierShape.Bezier4Points()
    
    var _player:MyCharaNode!
    var _enemy:MyCharaNode!
    
    let _playerSize = CGSize(width: 30, height: 60)
    
    var _aryTexture = [SKTexture]()
    var _dic_CharaTex = [String:[String:SKTexture]]()
    //[キャラ名:[方向:アニメーションテクスチャ配列]
    
    var _groundPosY_Player:CGFloat!
    var _groundPosY_Enemy:CGFloat!
    
    
/////////////////////////////////////////////////////////////////////////
    
//    func round<T>() -> Float {
//        
//    }

    func round(val:CGFloat,point:Int) -> Double{
        
        var p:Double = 10.0
        for _ in 1...point {
            p = p * p
        }
        
        var newVal =  Darwin.round(Double(val) * p)
        newVal = newVal / p
        return newVal
    }
    
    //MARK:- タッチ処理
    
    func touchDown(atPoint pos : CGPoint) {
        _beganPoint = pos
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        //画面タッチ中かつ、移動フラグ　false
        if _isTouchON {
            print("pos = \(pos)")
            
            //タッチ位置が左右３ポイント以上ずれた場合は移動
            if (_beganPoint.x + 3) < pos.x || (_beganPoint.x - 3) > pos.x
            {
                //移動
                self.touchMove()
                if pos.x < _beganPoint.x {
                    self.playerAction_LeftMove()
                    
                }else if pos.x > _beganPoint.x {
                    self.playerAction_RightMove()
                }
                _beganPoint = pos
                
            }
            
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
        print("初期タッチ  \(round(val: _beganPoint.y, point: 1))")
        print("リリース  \(round(val: pos.y, point: 1))")

//移動していない場合
        if !_isTouchMove {
            
            let y = _beganPoint.y - pos.y
            print("差  \(round(val: y, point: 1))")
            
            //上にフリックした場合
            if y < -30 {
                //MARK:プレイヤーボールを　上に投げる
                //            if (_beganPoint.y - 30) < pos.y {
                print("power = \(_power)")
                print("上になげる")
                self.playerAction_BallThrow_Big()
            }
                //普通になげる
            else  {
                print("power = \(_power)")
                //MARK:プレイヤーボールを　まっすぐ投げる
                self.playerAction_BallThrow()
            }
            
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchON()
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self))  }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        self.touchOff()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        self.touchOff()
    }
    
    func touchON(){ _isTouchON = true }
    
    func touchMove(){ _isTouchMove = true }
    
    func touchOff(){
        _isTouchON = false  //タッチ解除
        _isTouchMove = false//移動してない
        _beganPoint = nil   //初期タッチ位置の初期化

        _hasDummyBall_Player = false // ダミーボールをもっていない
        print("upDatecont = \(_upDateCount_Touch)")
        _upDateCount_Touch = 0
        _power = 0              //溜めた力を解放
        _cgPath = nil
        _hasBallName = ""


    }
    
//////////////////////////////////////////////////////////////////////////
    
//MARK:- 衝突処理
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        print(" body A = \(bodyA)")
        print(" body B = \(bodyB)")
        
        var nodeA:SKNode = SKNode()
        if let a = bodyA.node {
            nodeA = a
            
        }else{
            print("ーーーA　衝突処理失敗　ーーー")
            return
        }

        var nodeB:SKNode = SKNode()
        if let b = bodyB.node {
            nodeB = b
        }else{
            print("ーーーB　衝突処理失敗　ーーー")
            return
        }
        
            print("⭐️衝突 A = \(String(describing: nodeA.name!)):B = \(String(describing: nodeB.name!))")

// function
        
        func ballCountFromNode(node:SKNode) ->String{
            if node.name!.hasPrefix(_playerBallShadowName_A){
                return node.name!.replacingOccurrences(of: _playerBallShadowName_A, with: "")
                
            }else if node.name!.hasPrefix(_enemyBallShadowName_A){
                return node.name!.replacingOccurrences(of: _enemyBallShadowName_A, with: "")
            }
            
            print("！！！　ボールカウントは無い　　！！！")
            return ""
        }
        
        
        //プレイヤーのボールカウントのみの文字列を取り出す
        func ballCountFromNode_Player() ->String{
            if nodeA.name!.hasPrefix(_playerBallShadowName_A){
                return nodeA.name!.replacingOccurrences(of: _playerBallShadowName_A, with: "")
                
            }else
                if nodeB.name!.hasPrefix(_playerBallShadowName_A){
                    return nodeB.name!.replacingOccurrences(of: _playerBallShadowName_A, with: "")
            }
            print("！！！　ボールカウントは無い　　！！！")
            return ""

        }
        
        //敵のボールカウントのみの文字列を取り出す
        func ballCountFromNode_Enemy() ->String{
            if nodeA.name!.hasPrefix(_enemyBallShadowName_A){
                return nodeA.name!.replacingOccurrences(of: _enemyBallShadowName_A, with: "")
                
            }else
                if nodeB.name!.hasPrefix(_enemyBallShadowName_A){
                return nodeB.name!.replacingOccurrences(of: _enemyBallShadowName_A, with: "")
            }
            
            print("！！！　ボールカウントは無い　　！！！")
            return ""
        }

        
        
        func deleteBalls(){
            print(#function)
            
            //ボールカウント 抽出
            let strPlayerBallCount = ballCountFromNode_Player()
            print("playerBallCount = \(strPlayerBallCount)")
            let strEnemyBallCount = ballCountFromNode_Enemy()
            print("enemyBallCount = \(strEnemyBallCount)")
            
            
            //敵ボールの名前
            let enemyballName = _enemyBallName + strEnemyBallCount
            print("敵ボール名\(enemyballName)")
            
            //敵ボールの位置に　破裂パーティクルを表示する
            for node in self.children{
                if node.name == enemyballName{
                    addParticle(pos: node.position, ballLevel: 1, type: .SPARK)
                }
            }
            
            //削除するボールと影のリスト
            let deleteNodeNames = [
                _playerBallName         + strPlayerBallCount,
                _playerBallShadowName_A   + strPlayerBallCount,
                _enemyBallName          + strEnemyBallCount,
                _enemyBallShadowName_A    + strEnemyBallCount
                
            ]
            
            
            //ボールを探す
            for name in deleteNodeNames{
                for node in self.children {
                    if node.name == name {
                        //ボールを削除
                        node.removeFromParent()
                        print("\(name) 削除")
                    }else{
//                        print("（；ー；）ボール削除失敗")
                        
                    }
                }
            }
            
        }
        
        //破裂アニメーション
        func addSpark(pos:CGPoint){
            let particle = makeParticle(pos: pos, ballLevel: 1, type: .SPARK)
            self.addChild(particle)
        }
        
        
        func deleteNodeA(){
            //破裂アニメーション
            let ballA = nodeA as! MyShapeNode
            self.addParticle(pos: ballA.position, ballLevel: ballA.ballLevel, type: .SPARK)
            ballA.isHidden = true
            //ボール削除
        }
        
        
        func damege_BallSerch(){
            //ボール（影）はプレイヤーボールか？
            if nodeA.name!.hasPrefix(_playerBallShadowName_A) ||
                nodeB.name!.hasPrefix(_playerBallShadowName_A){
               
                let strCount = ballCountFromNode(node: nodeB)
                print(strCount)
                let ballName = _playerBallName + strCount
                print(ballName)
                let ball = self.childNode(withName: ballName)
                print(ball!)

                addSpark(pos: (ball?.position)!)
                
                nodeB.removeFromParent()

            //ボール（影）は敵ボールか？
            }else if
                nodeA.name!.hasPrefix(_enemyBallShadowName_A) ||
                    nodeB.name!.hasPrefix(_enemyBallShadowName_A){
                let strCount = ballCountFromNode(node: nodeB)
                let ballName = _enemyBallName + strCount
                print(ballName)
                let ball = self.childNode(withName: ballName)
                
                addSpark(pos: (ball?.position)!)
//                addParticle(pos: (ball?.position)!, ballLevel: 1, type: .SPARK)
                
                nodeB.removeFromParent()
            }
        }

        
        func damage_Player(){

            print("プレイヤーダメージ")
            damege_BallSerch()
        }
        
        func damage_Enemy(){
            print("敵ダメージ")
            damege_BallSerch()
            
        }
        
//判定
        
        //プレイヤーと　敵ボール
        if nodeA.name! == _playerName && nodeB.name!.hasPrefix(_enemyBallShadowName_A){
            print("プレイヤーに　ボールがあたった")
            damage_Player()
        }else
            
        //敵　と　プレイヤーボール
        if nodeA.name! == _enemyName && nodeB.name!.hasPrefix(_playerBallShadowName_A) {
            print("敵に　ボールが当たった")
            damage_Enemy()
            
        }else
           
        //Hit playerBall    & enemyBall
        if nodeA.name!.hasPrefix(_playerBallName) && nodeB.name!.hasPrefix(_enemyBallName) ||
            nodeB.name!.hasPrefix(_playerBallName) && nodeA.name!.hasPrefix(_enemyBallName)
        {
            print("ボールとボールがあたった")
            deleteBalls()
            
        }
        
    }
    
//MARK:- イベントループ
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //タッチ中で移動していない場合のカウントする
        if _isTouchON && !_isTouchMove{
            _upDateCount_Touch += 1
            
            if _upDateCount_Touch  == 10 ||
                _upDateCount_Touch  == 25 ||
                _upDateCount_Touch  == 60{
                print("ボールサイズアップ！！")
                _power += 1
                _hasDummyBall_Player = true
            }
        }
        
    }
    
    override func didEvaluateActions() {

    }
    
    override func didSimulatePhysics() {
    }
    
///////////////////////////////////////////////////////////////////////
    
//MARK:-
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.anchorPoint = CGPoint(x: 0.5, y: 0.75)
        print("self.frame.size = \(self.frame.size)")
        
        self.backgroundColor = .lightGray

//MARK:キャラクターのテクスチャ準備
        self.make_charaTexture()
        
//MARK:player　作成
        self.addPlayer()
        
//MARK:Enamy　作成
        self.addEnemy()
        
//中央線
        self.addLine(beganPoint: CGPoint(x:-(self.frame.size.width) ,y:0 ), endPoint: CGPoint(x:self.frame.size.width ,y:0 ),name:"centerX_Line")
        self.addLine(beganPoint:CGPoint(x:0 ,y:-(self.frame.size.height)), endPoint: CGPoint(x:0 ,y:self.frame.size.height),name:"centerY_Line")
        
//MARK:初期設定　ボールの軌跡計算
//        b4p.stP     = CGPoint(x: -(self.frame.size.width / 2), y: -(self.frame.size.height / 4 * 3))
//        b4p.contP1  = CGPoint(x: -(self.frame.size.width / 2) + 10, y: -200)
//        b4p.contP2  = CGPoint(x: -(self.frame.size.width / 3), y: 150)
//        b4p.endP    = CGPoint(x: -(self.frame.size.width / 4), y: 0)
        
        
////MARK:ベジェ曲線のpathを作る
//        let path = makePath_4points(bp: b4p)
//        
//    //開始位置からコントロールポイント１までの　線
//        self.addControlLine1(point0: b4p.stP, point1: b4p.contP1)
//    //終了位置からコントロールポイント２までの　線
//        self.addControlLine2(point0: b4p.endP, point1: b4p.contP2)
//        
//        self.addPlayerBall(path: path)
        
//MARK:3点のベジェ曲線
        _b3p.stP     = CGPoint(x: -(self.frame.size.width / 2), y: -(self.frame.size.height / 4 * 3))
        _b3p.contP   = CGPoint(x: -(self.frame.size.width / 2) + 10, y: 40)
        _b3p.endP    = CGPoint(x: -(self.frame.size.width / 4), y: 0)
        
        //
//        self.addControlLine1(point0: b3p.stP, point1: b3p.contP)
//        self.addControlLine2(point0: b3p.endP, point1: b3p.contP)
//        
//        point(pos:b3p.stP);point(pos:b3p.contP);point(pos:b3p.endP)
//        
//        let path2 = MyBezierShape.makeLinePathFrom3Points(b3p: b3p)
//        self.addLineFromPath(path: path2)
//        self.addPlayerBall(path: path2)
        
    //ベジェ曲線を表示
//        let line = self.makeShapeLine(bp: b4p)
//        self.addChild(line)
        
        var b3p2 = MyBezierShape.Bezier3Points()
        b3p2.stP     = CGPoint(x: self.frame.size.width / 4, y: 0)
        b3p2.contP   = CGPoint(x: (self.frame.size.width / 2) + 10, y: 50)
        b3p2.endP    = CGPoint(x: self.frame.size.width / 2, y: -(self.frame.size.height / 4 * 3))
        
        let path3 = MyBezierShape.makeLinePathFrom3Points(b3p: b3p2)
        self.addLineFromPath(path: path3)
        self.addPlayerBall(path: path3)
        
        // 敵行動開始
        let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(GameScene.enemyActions), userInfo: nil, repeats: true)
        timer.fire()
        
        
        //敵地面のY位置
        _groundPosY_Enemy = _enemy.position.y - _enemy.size.height / 2
        
        //プレイヤー地面のY位置
        _groundPosY_Player = _player.position.y - _player.size.height / 2
        
    }
    
    
    
    
    //MARK:-
    func deleteControlLine(){
        
        if let node1 = self.childNode(withName: "controlpoint1") {
            node1.removeFromParent()
        }
        if let node2 = self.childNode(withName: "controlpoint2"){
            node2.removeFromParent()
        }
        
    }
    
    //MARK:- Enemy Action
    
    func enemyActions(){
        print(#function)
        
//        print(_enemy.action)
        
        _enemy.nextAction()
        
        //今なにもしていないか　チェック
//        if _enemy.action == .STOP {
            
            switch _enemy.action!{
            
            case .BallThrow:
                //ボールを投げる
                self.enemyAction_BallThrow()
                
            case .MoveToLeft:
           //左　移動する
                self.enemyAction_MoveLeft()
            case .MoveToRight:
             //右　移動する
                self.enemyAction_MoveRight()
            
            default:
                print("????   enemy default case")
                
            }
            
//        }else{
//            //何もしない
//            
//        }
        
        
    }

    
    //MARK:敵の行動
    //MARK:ボールを投げる
    func enemyAction_BallThrow(){
        print("ボールをなげる")
        let bp = makeBezierCurve3Points_Enemy(pos: _enemy.position)
        
        self.addControlLine1(point0: bp.stP, point1: bp.contP)
        self.addControlLine2(point0: bp.endP, point1: bp.contP)
        //軌道計算
        let path = self.makePath_3points(bp:bp)
        self.addEnemyBall(path:path)
        self._enemy.action = .STOP
    }
    //MARK:ボールを上に投げる
    func enemyAction_BallThrow_Big(){
    print("ボールを上になげる")
        
        self._enemy.action = .STOP
        
    }
    
    //MARK:左へ移動
    func enemyAction_MoveLeft(){
        print("左へ移動")
        //どこへ移動するか　-画面の横幅/4 +画面の横幅/4
        
        //現在地から目的地まで
        
        
        
        //今の位置と移動先の距離
        
        //距離から移動時間を計算
        
        //アクションを作成
        let action = SKAction.moveBy(x: 5, y: 0, duration: 0.5)
        
        _enemy.run(action, completion: {
         self._enemy.action = .STOP
        })
    }
    //MARK:右へ移動
    //move Right
    func enemyAction_MoveRight(){
        print("右へ移動")
        
        let action = SKAction.moveBy(x: -5, y: 0, duration: 0.5)
        
        _enemy.run(action, completion: {
            self._enemy.action = .STOP
        })

    }

//    func enemyAction_LeftMove(){
//        //左に移動できるスペースがあるか？
//        
//        print("左に移動")
//        enemy.run(SKAction.moveBy(x: -3, y: 0, duration: 0.1))
//        
//    }
//    
//    func enemyAction_RightMove(){
//        //右に移動できるスペースがあるか？
//        print("右に移動")
//        enemy.run(SKAction.moveBy(x: 3, y: 0, duration: 0.1))
//        
//    }

    
    
    //MARK:- player Action
    func playerAction_BallThrow(){
        
        let bp = makeBezierCurve3Points_Player(pos: _player.position)
        
//        self.addControlLine1(point0: bp.stP, point1: bp.contP)
//        self.addControlLine2(point0: bp.endP, point1: bp.contP)
        
        //ベジェ曲線
//        let shapeLine = self.makeShapeLine(bp: bp)
//        self.addChild(shapeLine)
        //軌道計算
        let path = self.makePath_3points(bp:bp)
        
        self.addPlayerBall(path:path)
        
    }
    
    func playerAction_BallThrow_Big(){
        //上になげる
        
        let ball = makeBall_Player()
        ball.position = _player.position
        //プレイヤーより奥に表示
        ball.zPosition = _player.zPosition - 0.01
        
        
        // 火のエフェクトを追加
        let emitter = makeEmitter_Fire()
        emitter.setScale(CGFloat(_power))
        
        ball.addChild(emitter)
        self.addChild(ball)
        
        //ボールの上空　位置
        let pos_Aerial = CGPoint(x:_player.position.x / 2.0,y:(self.view?.frame.height)!)
        //ボールの落ちる位置
        let pos_Fall = CGPoint(x: pos_Aerial.x, y: _groundPosY_Enemy)
        let actionFall = SKAction.move(to: pos_Fall, duration: 0.5)
        
        actionFall.timingMode = .easeIn

        //アクション実行
        let action = SKAction.sequence([
            //上になげる（画面外へ消える）
            SKAction.moveTo(y: (self.view?.frame.size.height)!, duration: 0.5),
            //１秒後
            SKAction.wait(forDuration: 1),
            //スケールを半分に
            SKAction.scale(by: 0.5, duration: 0.0),
            //敵上空に移動
            SKAction.move(to: pos_Aerial, duration: 0.0),
            //落下
            actionFall,
            //削除する
            SKAction.removeFromParent()
            ])
        
        ball.run(action, completion: {
          print("")
        })
        
        //ボールの影
        let shadow = makeShadowNode(size: ball.frame.size, name: "")
        shadow.alpha = 0.0
        shadow.setScale(0.1)
        shadow.position = pos_Fall
        self.addChild(shadow)
        
        let shadowAction = SKAction.sequence([
            
            SKAction.group([
                SKAction.fadeAlpha(to: 1.0, duration: 2.0),
                SKAction.scale(to: 1.0, duration: 2.0)
                ]),
            SKAction.removeFromParent()
            ])
        shadowAction.timingMode = .easeIn
        shadow.run(shadowAction, completion: {
            
        })
        
    }

    

    func playerAction_LeftMove(){
//        print("左に移動")
        _player.run(SKAction.moveBy(x: -10, y: 0, duration: 0.1))
    }
    
    func playerAction_RightMove(){
        //右に移動できるスペースがあるか？
//        print("右に移動")
        _player.run(SKAction.moveBy(x: 10, y: 0, duration: 0.1))
        
    }
    
    func playerDamegeAction(damege:Int){
        
        _player.life -= damege
        
        if _player.life <= 0 {
            
            
        }
        
        
        
    }
    
//MARK:- Set
    //アニメーションパターンをセットする
    func setCharaAnimeTextureDirection(node:MyCharaNode) -> MyCharaNode{
        
        if node.charaNumber < _aryTexture.count {
            node.ary_DownTextures = makeCharaAnimationTextures(charaNumber: node.charaNumber, direction: .DOWN)
            node.ary_UpTextures = makeCharaAnimationTextures(charaNumber: node.charaNumber, direction: .UP)
            node.ary_LeftTextures = makeCharaAnimationTextures(charaNumber: node.charaNumber, direction: .LEFT)
            node.ary_RightTextures = makeCharaAnimationTextures(charaNumber: node.charaNumber, direction: .RIGHT)
            
        }else{
            print(#function)
            print("存在しないキャラクターです。")
        }
        return node
        
        
    }


    
    
//MARK:- Makeing
//MARK:- パーティクル作成
    func makeParticle(pos:CGPoint, ballLevel:Int, type:MagicBallType) ->SKEmitterNode{
        print(#function)
        var emitter = SKEmitterNode()
        
        switch type {
        case .FIRE:
            emitter = makeEmitter_Fire()
        case .ICE:
            emitter = makeEmitter_Ice()
            
        case .SPARK:
            emitter = makeEmitter_Spark()
        }
        
        
        emitter.setScale(CGFloat(ballLevel))
        print("ballLevel = \(ballLevel)")
        emitter.position = pos
        
        let action = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
            ])
        emitter.run(action, completion: {
            print("パーティクル終了")
        })
        
        return emitter
    }

    
    
    //MARK:- 影を作成
    func makeShadowNode(size:CGSize,name:String) -> SKShapeNode{
        let newSize = CGSize(width: size.width, height: size.height / 2)
        let shadow = SKShapeNode(ellipseOf: newSize)
        shadow.fillColor = .black
        shadow.alpha = 0.8
        
        shadow.name = name
        
        return shadow
    }


    func makeShadowNode_Player(size:CGSize,name:String) -> SKShapeNode{
        let shadow = makeShadowNode(size: size, name: name)
        shadow.physicsBody = SKPhysicsBody(circleOfRadius: shadow.frame.size.height / 2)
        shadow.physicsBody?.categoryBitMask     = _playerCategory
        shadow.physicsBody?.collisionBitMask    = _enemyCategory
        shadow.physicsBody?.contactTestBitMask  = _enemyCategory
        
//        shadow.name = name
        
        return shadow
    }

    func makeShadowNode_Enemy(size:CGSize,name:String) -> SKShapeNode{
        let shadow = makeShadowNode(size: size, name: name)
        shadow.physicsBody = SKPhysicsBody(circleOfRadius: shadow.frame.size.height / 2)
        shadow.physicsBody?.categoryBitMask     = _enemyCategory
        shadow.physicsBody?.collisionBitMask    = _playerCategory
        shadow.physicsBody?.contactTestBitMask  = _playerCategory
        
//        shadow.name = name
        
        return shadow
    }
    
    
//MARK:影のうごき
    func makeShadowActon(endPoint:CGPoint) -> SKAction {
        let action =
        SKAction.sequence([
            SKAction.group([
                SKAction.move(to: endPoint , duration: _throwSec_Short),
                SKAction.scale(by: 0.5, duration: _throwSec_Short)
                ]),
            SKAction.removeFromParent()
            ])
        action.timingMode = .easeOut

        return action
    }
    
    
    func makeShadowActon_Enemy(endPoint:CGPoint) -> SKAction {
        let action =
            SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: endPoint , duration: _throwSec_Short),
                    SKAction.scale(by: 2.0, duration: _throwSec_Short)
                    ]),
                SKAction.removeFromParent()
                ])
        action.timingMode = .easeIn
        
        return action
        
        
    }

    
    //MARK:ボールなげる
    func makeThrowAction(path:CGPath) ->SKAction{
        let action =
            SKAction.sequence([
                SKAction.group([
                    SKAction.follow(path, duration: _throwSec_Short),
                    SKAction.scale(by: 0.5, duration: _throwSec_Short)
                    ]),
                SKAction.removeFromParent()
                ])
        action.timingMode = .easeOut
        return action
    }
    
    
    func makeThrowAction_Enemy(path:CGPath) ->SKAction{
        let action =
            SKAction.sequence([
                SKAction.group([
                    SKAction.follow(path, duration: _throwSec_Short),
                    SKAction.scale(by: 2.0, duration: _throwSec_Short)
                    ]),
                SKAction.removeFromParent()
                ])
        action.timingMode = .easeIn
        return action
    }


    ///MARK:- キャラクターのアニメーションパターン返す
    func makeCharaAnimationTextures(charaNumber:Int,direction:Direction) -> [SKTexture]{
        
        var pos = charaNumber * 3
        
        if charaNumber > 4 {
            pos += 48
        }
        
        switch direction {
        case .LEFT:
            print()
        case .DOWN:
            pos += 12
        case .RIGHT:
            pos += 24
        case .UP:
            pos += 36
        }
        
        let tex0 = _aryTexture[pos]
        let tex1 = _aryTexture[pos + 1]
        let tex2 = _aryTexture[pos + 2]
        
        return [tex0,tex1,tex2,tex1]
    }

    
    
    func make_charaTexture(){
        
        //chara.png から　キャラパターンごとtextureに分割
        
        let ary_charaTex = MyCharaNode.make_tile(textureName: "chara1.png",
                                                 numRow: 12, numColums: 8)

        _aryTexture = ary_charaTex
        //キャラクターのテクスチャーを分割
        
        var aryTex = [SKTexture]()
        var dicTex = [String:[SKTexture]]()
//        var dicCharaAnimeTex = [String:[String:[SKTexture]]]()
//        let direction:[String] = ["left","down","right","up"]
        
//        let numAnimePattern = ary_charaTex.count / 3 //アニメーションパターン数

        //キャラクタの数を計算　１キャラ（３アニメパターン　x　４方向）
        let numCharas = ary_charaTex.count / (3 * 4) //キャラクター数
        
        print("numCharas = \(numCharas)")
        
        var chareNumber = 0
      
        //3つずつに分割
        for tex in _aryTexture {
            aryTex.append(tex)
            
            if aryTex.count == 3 {
                dicTex[chareNumber.description] = aryTex
                print(dicTex)
                chareNumber += 1
                aryTex.removeAll()
            }
            
        }
    }
    
    ////////////////////////
    
    func makePlayer(charaNumber:Int) -> MyCharaNode{
        
        var node = MyCharaNode(color: .clear,
                               size: CGSize(width: _aryTexture[0].size().width, height: _aryTexture[0].size().height))
        
        node.charaNumber = charaNumber
        
        //向きのアニメーションパターンを得る
        node = setCharaAnimeTextureDirection(node: node)
        
        let act_Anime = SKAction.animate(with:node.ary_UpTextures , timePerFrame: 0.3)
        
        node.setScale(2.0)
        
        //プレイヤーとして設定する
        node.name = _playerName
        node.zPosition = 1.0
        node.run(SKAction.repeatForever(act_Anime))
        
//        let physicsSize = CGSize(width: node.frame.size.width * 0.75, height: node.frame.size.height)
//        
//        node.physicsBody = SKPhysicsBody(rectangleOf:physicsSize)
//        node.physicsBody?.affectedByGravity = false
//        node.physicsBody?.allowsRotation = false
//        
//        node.physicsBody?.categoryBitMask = _playerCategory
//        node.physicsBody?.collisionBitMask = 0//_enemyBallShadowCategory
//        node.physicsBody?.contactTestBitMask = 0//_enemyBallShadowCategory
        
        return node
        
    }

    func makeEnemy(charaNumber:Int) -> MyCharaNode{
        
        var node = MyCharaNode(color: .clear, size: CGSize(width: _aryTexture[0].size().width, height: _aryTexture[0].size().height))
        
        node.charaNumber = charaNumber
        
        //向きのアニメーションパターンを得る
        node = setCharaAnimeTextureDirection(node: node)
        
        let act_Anime = SKAction.animate(with:node.ary_DownTextures , timePerFrame: 0.3)
  
        
        //敵として設定
        node.name = _enemyName
        node.zPosition = 0.5
        
        node.run(SKAction.repeatForever(act_Anime))
        
//        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
//        node.physicsBody?.affectedByGravity = false
//        node.physicsBody?.allowsRotation = false
//        node.physicsBody?.categoryBitMask = _enemyCategory
//        node.physicsBody?.collisionBitMask = 0//_playerBallShadowCategory
//        node.physicsBody?.contactTestBitMask = 0//_playerBallShadowCategory
        return node
        
    }
    
    //コントロールポイントを計算する
    func calcControllPoint(bp:MyBezierShape.Bezier3Points) -> MyBezierShape.Bezier3Points{
        
        var newBp = bp
        
        //中心からタッチしたXまでと比率(ratio)を計算
        let contPosRatio = abs(bp.endP.x) / (self.frame.size.width / 4.0)
        //
        let contPosX = abs(_b3p.contP.x) * contPosRatio
        
        newBp.contP = CGPoint(x: contPosX, y: _b3p.contP.y)
        
        return newBp
        
    }

    
    //pos から　ボール軌道計算して返す ３ポイントを返す
    func makeBezierCurve3Points_Player(pos:CGPoint) -> MyBezierShape.Bezier3Points{
        var bp = MyBezierShape.Bezier3Points()
        
        bp.stP = CGPoint(x: _player.position.x, y: _player.position.y + _player.size.height / 2)

        //Player 位置からエンド位置を計算する (敵の頭の上）
        bp.endP = CGPoint(x: pos.x / 2.0, y: _enemy.position.y)

    //コントロールポイントを計算する
        
        //中心からタッチしたXまでと比率(ratio)を計算
        let contPosRatio = abs(bp.endP.x) / (self.frame.size.width / 4.0)
        //比率からcontroll point を計算
        let contPosX = abs(_b3p.contP.x) * contPosRatio
        
        bp.contP = CGPoint(x: contPosX, y: _b3p.contP.y)
    ///
    //画面の左側の場合は、ーXにする
        if pos.x < 0 {
            bp.contP = CGPoint(x: -contPosX, y: _b3p.contP.y)
        }
        
        return bp
    }
    

    //敵のボール軌道計算
    
    func makeBezierCurve3Points_Enemy(pos:CGPoint) -> MyBezierShape.Bezier3Points{
        var bp = MyBezierShape.Bezier3Points()
        
        bp.stP = CGPoint(x: _enemy.position.x, y: _enemy.position.y + _enemy.size.height / 2)
        
        //Enemy 位置からエンド位置を計算する
        bp.endP = CGPoint(x: pos.x * 2.0, y: _player.position.y)

        //コントロールポイントを計算する
        //        bp = calcControllPoint(bp: bp)
        
    //比率(ratio)を計算
        let contPosRatio = abs(bp.endP.x) / self.frame.size.width
        //
        let contPosX = abs(_b3p.contP.x) * contPosRatio
        
        bp.contP = CGPoint(x: contPosX, y: _b3p.contP.y)
    ///
        
        //画面の左側の場合は、ーXにする
        if pos.x < 0 {
            bp.contP = CGPoint(x: -contPosX, y: _b3p.contP.y)
        }
        
        return bp
    }

    

    //Posから計算
    func makeBezierCurve4Points(pos:CGPoint) -> MyBezierShape.Bezier4Points{
        
        var bp = MyBezierShape.Bezier4Points()
        
        bp.stP = CGPoint(x: pos.x, y: _b4p.stP.y)
        
        //スタート位置からエンド位置を計算する
        bp.endP = CGPoint(x: pos.x / 2.0, y: self.anchorPoint.y)
        
        //コントロールポイント１、２を計算する
        //中心からタッチしたXまでと比率(ratio)を計算
        let contPos1Ratio =  abs(bp.stP.x) / (self.frame.size.width / 2.0)
        let contPos1X = abs(_b4p.contP1.x) * contPos1Ratio
        
        bp.contP1 = CGPoint(x: contPos1X, y: _b4p.contP1.y)
        
        let contPos2Ratio = abs(bp.endP.x) / (self.frame.size.width / 4.0)
        let contPos2X = abs(_b4p.contP2.x) * contPos2Ratio
        
        bp.contP2 = CGPoint(x: contPos2X, y: _b4p.contP2.y)
        
        //画面の左側がタッチされた場合は、ーXにする
        if pos.x < 0 {
            bp.contP1 = CGPoint(x: -contPos1X, y: _b4p.contP1.y)
            bp.contP2 = CGPoint(x: -contPos2X, y: _b4p.contP2.y)
        }
        return bp
    }

    //ボール名
    func makeBallCountString() -> String{
        let str = String(_ballCount)
        _ballCount += 1
        return str
    }
    
    func makeLine(beganPoint:CGPoint,endPoint:CGPoint,name:String?) ->SKShapeNode{
        let shape = SKShapeNode()
        if name != nil {
            shape.name = name!
        }
        // 線のパスを生成.
        let myPath = UIBezierPath()
        myPath.move(to: beganPoint)
        myPath.addLine(to: endPoint)
        
        // パスを線に反映.
        shape.path = myPath.cgPath
        
        // 線の色を設定.
        shape.strokeColor = .red
        
        // 線の太さ.
        shape.lineWidth = 0.5
        
        // グローの幅.
        shape.glowWidth = 0.0
        
        return shape
    }
    
    func makeShapeCircle(radius:CGFloat) ->MyShapeNode{
        let shape = MyShapeNode(circleOfRadius: radius)
        shape.fillColor = .yellow
        shape.zPosition = 1.0
        shape.name = makeBallCountString()
        
        shape.ballLevel = _power
        
        return shape
    }

    
//    func makeShapeLine(bp:MyBezierShape.Bezier4Points) -> SKShapeNode{
//        let cgPath = makePath_4points(bp: bp)
//        
//        let shape = SKShapeNode(path: cgPath)
//        shape.strokeColor = .red
//        
//        return shape
//    }
    
    func makeShapeLine(bp:MyBezierShape.Bezier3Points) -> SKShapeNode{
        let cgPath = makePath_3points(bp: bp)
        let shape = SKShapeNode(path: cgPath)
        shape.strokeColor = .red
        
        return shape
    }

    
    //MARK:- Make CGPath
    func makePath_3points(bp:MyBezierShape.Bezier3Points) -> CGPath{
        let path = UIBezierPath()
        path.move(to: bp.stP)
        path.addQuadCurve(to: bp.endP, controlPoint: bp.contP)
        return path.cgPath
    }

//    func makePath_4points(bp:MyBezierShape.Bezier4Points) -> CGPath{
//        let path = UIBezierPath()
//        path.move(to: bp.stP)
//        path.addCurve(to: bp.endP, controlPoint1: bp.contP1, controlPoint2: bp.contP2)
//        return path.cgPath
//    }
    
    func makeBallShadowMoveLine_Player() -> CGPath{
        let bp = makeBezierCurve3Points_Player(pos: _player.position)
        self.addControlLine1(point0: bp.stP, point1: bp.contP)
        self.addControlLine2(point0: bp.endP, point1: bp.contP)
        return  MyBezierShape.makeLinePath(beganPoint: bp.stP, endPoint: bp.endP)
        
    }

    
    
    func makePath_Line(beganPoint:CGPoint,endPoint:CGPoint) -> CGPath{
        
        // 線のパスを生成.
        let path = UIBezierPath()
        path.move(to: beganPoint)
        path.addLine(to: endPoint)
        
        // パスを線に反映.
        return path.cgPath
    }
    
    //MARK:-
    
    func makeBall_Player() -> MyShapeNode{
        let ball = makeShapeCircle(radius: _ary_BallRadius[_power])
        ball.fillColor = .orange
        
//        print("height = \(ball.frame.size.height)")

            return ball
        
    }
    
    
    func makeBall_Enemy() -> MyShapeNode{
        let ball = makeShapeCircle(radius: _ary_BallRadius[1])
        ball.fillColor = .orange
        ball.zPosition = 0.5
        
        return ball
        
    }

    
    func makeEmitter_Fire() ->SKEmitterNode{
         let node = SKEmitterNode(fileNamed: "FireParticle.sks")
        return node!
    }
    func makeEmitter_Spark() ->SKEmitterNode{
        let node = SKEmitterNode(fileNamed: "SparkParticle.sks")
        return node!
    }
    func makeEmitter_Ice() -> SKEmitterNode{
        let node = SKEmitterNode(fileNamed: "IceParticle.sks")
        return node!
    }
    
    ////////////////////////////////////////////////////////////////////////////
    
    //MARK:- Add 画面に追加する
    //MARK:プレイヤー追加
    func addPlayer(){
        self._player = self.makePlayer(charaNumber: 3)
        self._player.position = CGPoint(x: 0, y: -(self.frame.size.height / 2))
      
        //移動できる幅を制限
        let rangeX = SKRange(lowerLimit: -self.frame.size.width / 2 + _player.size.width / 2,
                            upperLimit: self.frame.size.width / 2 - _player.size.width / 2)
        let rangeY = SKRange(lowerLimit: -(self.frame.size.height / 2),
                             upperLimit: -(self.frame.size.height / 2))
        
        let constraint = SKConstraint.positionX(rangeX, y: rangeY)
        self._player.constraints = [constraint]

        self.addChild(self._player)
        
        
        //プレイヤーの影
        let shadowSize = CGSize(width: self._player.size.width / 2, height:self._player.size.height / 6)
        let shadow = SKShapeNode(ellipseOf:shadowSize)
        shadow.name = _playerName
        shadow.fillColor = .black
        shadow.alpha = 0.8
        shadow.position = CGPoint(x: 0, y: -_player.size.height / 4)
        
        shadow.physicsBody = SKPhysicsBody(edgeLoopFrom: shadow.path!)
        shadow.physicsBody?.affectedByGravity = false
        shadow.physicsBody?.categoryBitMask     = _playerCategory
        shadow.physicsBody?.collisionBitMask    = _enemyCategory
        shadow.physicsBody?.contactTestBitMask  = _enemyCategory
        
        self._player.addChild(shadow)
        
    }
    

    func addPlayerBall(path:CGPath){
        
        let ball = makeBall_Player()
        
        let str_Ballcount = makeBallCountString()
        ball.ballCount = Int(str_Ballcount)!
        ball.name = _playerBallName + str_Ballcount
        print("playerBallname = \(ball.name!)")
        ball.zPosition = _player.zPosition
        
        ball.setScale(1.0)
        // 投げるアクション
        let action = makeThrowAction(path: path)
        action.timingMode = SKActionTimingMode.easeOut
        
        //なげる
        ball.run(action, completion: {
            print("Player Throw Action end")
            self.deleteControlLine()
        })
        
        // 火のエフェクトを追加
        let emitter = makeEmitter_Fire()
        emitter.setScale(CGFloat(_power))
        emitter.zRotation = .pi

        ball.addChild(emitter)
        self.addChild(ball)
        
        //MARK:playerボールのかげ
        
        let ballShadow = makeShadowNode_Player(size: ball.frame.size, name: ball.name!)
//        ballShadow.name = ball.name!
        ballShadow.name = _playerBallShadowName_A + str_Ballcount
        ballShadow.position = CGPoint(x: _player.position.x, y: _player.position.y - _player.frame.size.height / 3)
        self.addChild(ballShadow)
        
        //影の　最終　移動　位置
        let x = _player.position.x / 2
        let endPoint = CGPoint(x: x, y: _enemy.position.y)
        
        let shadowAction = makeShadowActon(endPoint: endPoint)
        
        ballShadow.run(shadowAction, completion: {
            
            
        })
        
    }
    
    //MARK:Enemy
    func addEnemy(){
        self._enemy = makeEnemy(charaNumber: 2)
        
        //移動できる幅を制限
        let rangeX = SKRange(lowerLimit: -self.frame.size.width / 4 + _enemy.size.width / 2,
                             upperLimit: self.frame.size.width / 4 - _enemy.size.width / 2)
        let rangeY = SKRange(lowerLimit: anchorPoint.y + self._enemy.frame.size.height / 2,
                             upperLimit: anchorPoint.y + self._enemy.frame.size.height / 2)
        
        let constraint = SKConstraint.positionX(rangeX, y: rangeY)
        self._enemy.constraints = [constraint]

        
        
        self._enemy.position = CGPoint(x: 0, y: anchorPoint.y + self._enemy.frame.size.height / 2)
        self.addChild(self._enemy)
        
        //enemy の影
        let shadowSize = CGSize(width: _enemy.size.width, height:_enemy.size.height / 4)
        let shadow = SKShapeNode(ellipseOf:shadowSize)
        shadow.name = _enemyName
        shadow.fillColor = .black
        shadow.alpha = 0.8
        shadow.position = CGPoint(x: 0, y: -_enemy.size.height / 2)
        
        
        shadow.physicsBody = SKPhysicsBody(edgeLoopFrom: shadow.path!)

        shadow.physicsBody?.affectedByGravity = false
        shadow.physicsBody?.categoryBitMask     = _enemyCategory
        shadow.physicsBody?.collisionBitMask    = _playerCategory
        shadow.physicsBody?.contactTestBitMask  = _playerCategory
        
        self._enemy.addChild(shadow)
    }
    
    //MARK:Enemy Ball
    func addEnemyBall(path:CGPath){
        let ball = makeBall_Enemy()
        let str_Ballcount = makeBallCountString()
        ball.name = _enemyBallName + str_Ballcount
        
        ball.zPosition = _enemy.zPosition
        
        ball.setScale(0.5)
        ball.originalHeight = ball.frame.size.height
//        print("enemyBallOrigin = \(ball.originalHeight)")
        
        let actionThrow = makeThrowAction_Enemy(path: path)

        let action = SKAction.group([
            actionThrow,
            ])
        
        action.timingMode = SKActionTimingMode.easeIn
        
        ball.run(action, completion: {
            print("Enemy Throw action end")
            self.deleteControlLine()
        })
        
        let emitter = makeEmitter_Ice()
        ball.addChild(emitter)
       
        
        self.addChild(ball)
        
        //MARK:enemyボールのかげ

        let ballShadow = makeShadowNode_Enemy(size: ball.frame.size, name: ball.name!)
        ballShadow.name = _enemyBallShadowName_A + str_Ballcount
        ballShadow.position = CGPoint(x: _enemy.position.x, y: _enemy.position.y - _enemy.frame.size.height / 3)
        self.addChild(ballShadow)
        
        let x = _enemy.position.x * 2
        //プレイヤーの足元までとどかせる
        let endPoint = CGPoint(x: x, y: _player.position.y - _player.frame.size.height / 2)
        
        let shadowAction = makeShadowActon_Enemy(endPoint: endPoint)
        
        ballShadow.run(shadowAction, completion: {
            print("敵ボール \(ballShadow.name!)")
        })

    }
    
    //MARK:パーティクル追加
    func addParticle(pos:CGPoint, ballLevel:Int, type:MagicBallType){
        print(#function)
        var emitter = SKEmitterNode()
        
        switch type {
        case .FIRE:
            emitter = makeEmitter_Fire()
        case .ICE:
            emitter = makeEmitter_Ice()
            
        case .SPARK:
            emitter = makeEmitter_Spark()
        }
        
    
       emitter.setScale(CGFloat(ballLevel))
        print("ballLevel = \(ballLevel)")
        emitter.position = pos
        
        let action = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
            ])
        emitter.run(action, completion: {
            print("パーティクル終了")
        })
        
        self.addChild(emitter)
    }
    
    //MARK: 線を表示

    
    func addControlLine1(point0:CGPoint,point1:CGPoint){
        let line = self.makeLine(beganPoint: point0, endPoint: point1,name:"controlpoint1")
        line.strokeColor = .red
        self.addChild(line)
    }
    
    func addControlLine2(point0:CGPoint,point1:CGPoint){
        let line = self.makeLine(beganPoint: point0, endPoint: point1,name:"controlpoint2")
        line.strokeColor = .blue
        self.addChild(line)
    }

    
    func addLineFromPath(path:CGPath){
        let line = SKShapeNode(path:path)
        line.strokeColor = .yellow
        self.addChild(line)
    }
    
    func addLine(beganPoint:CGPoint,endPoint:CGPoint,name:String?){
        let line = makeLine(beganPoint: beganPoint, endPoint: endPoint, name: name)
        // Sceneに追加.
        self.addChild(line)
    }
    
    
}
