import UIKit
import SpriteKit
import GameplayKit

enum Throw:Int {
    case Nomal = 0
    case Big = 1
}

enum MagicBallType:Int {
    case FIRE = 0
    case ICE = 1
    case SPARK = 2
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var _playerCharaNumber = 1
    var _enemyCharaNumber = 2
    
    let _playerBallName                 = "playerball"
    let _enemyBallName                  = "enemyball"
    let _playerUpperBallName            = "playerUpperball"
    let _enemyUpperBallName             = "enemyUpperball"
    
    let _playerName                     = "player"
    let _enemyName                      = "enemy"
    let _playerBallShadowName_A         = "playerballshadowA"
    let _enemyBallShadowName_A          = "enemyballshadowA"
    
//    let _playerBallShadowName_B         = "playerballshadowB"
//    let _enemyBallShadowNName_B         = "enemyballshadowB"
    
    let _playerGroundLineNmae           = "playergroundline"
    let _enemyGroundLineName            = "enemygroundline"
    
    
    let _playerGroundLineCategory:UInt32 = 0x01 << 10
    let _enemyGroundLineCategory:UInt32 = 0x01 << 11
    
    let _playerCategory         :UInt32 = 0x01 << 1
    let _playerUpperBallCategory     :UInt32 = 0x01 << 2
//    let _playerBallShadowCategory:UInt32 = 0x01 << 5
    
    let _enemyCategory          :UInt32 = 0x01 << 3
    let _enemyUpperBallCategory      :UInt32 = 0x01 << 4
//    let _enemyBallShadowCategory:UInt32 = 0x01 << 6
    
    
//    let _playerRangeX = SKRange()
//    let _enemyRangeX = SKRange()
    
    
    let _gaugeWidth:CGFloat = 10.0
    let _gaugeHeight:CGFloat = 200.0

    
    var _life_Player = 100
    var _life_Enemy  = 100
    
    var _lifeGauge_Player:SKSpriteNode!
    var _magicGauge_Player:MYGauge!
    // SKSpriteNode!
    
//    var _magicGauge_Player:SKSpriteNode!
    var _lifeGauge_Enemy:SKSpriteNode!
    var _magicGauge_Enemy:MYGauge!

//    var _playerDummyball:MyShapeNode!
//    var _enemyDummyball:MyShapeNode!
    
    let _throwSec_Short = 1.0 //秒
    
    var _isTouchON      = false
    var _isTouchMove    = false
    var _hasDummyBall_Player   = false
    
    var _beganPoint:CGPoint!
    
    var _upDateCount_Touch = 0
    var _upDateCount_Enemy = 0//敵のアップデートカウント

    var _ballCount = 1
    var _hasBallName  = ""

    //ボールの大きさ
    let _ary_BallRadius:[CGFloat] = [5.0,10.0,15.0,30.0]
    var _power = 0
    var _power_Enemy = 0
    
    var _cgPath:CGPath? = nil
    
    var _b3p = MyBezierShape.Bezier3Points()
//    var _b4p = MyBezierShape.Bezier4Points()
    
    var _player:MyCharaNode!
    var _enemy:MyCharaNode!
    
    let _playerSize = CGSize(width: 30, height: 60)
    
    var _aryTexture = [SKTexture]()
    var _dic_CharaTex = [String:[String:SKTexture]]()
    //[キャラ名:[方向:アニメーションテクスチャ配列]
    
    var _groundPosY_Player:CGFloat!
    var _groundPosY_Enemy:CGFloat!
    
    var _groundPosX_LeftSide_Player:CGFloat!//
    var _groundPosX_RightSide_Player:CGFloat!//
    
    var _groundPosX_LeftSide_Enamey:CGFloat!//敵が移動可能な　左側の限界
    var _groundPosX_RightSide_Enamey:CGFloat!//敵が移動可能な　右側の限界
    
    
    
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
                print("power = \(_power)")
                print("上になげる")
                self.playerAction_BallThrow_Big()
            }
                //MARK:普通になげる
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
    
    
    func ballCountFromNode(node:SKNode) ->String{
        if node.name!.hasPrefix(_playerBallShadowName_A){
            return node.name!.replacingOccurrences(of: _playerBallShadowName_A, with: "")
            
        }else if node.name!.hasPrefix(_enemyBallShadowName_A){
            return node.name!.replacingOccurrences(of: _enemyBallShadowName_A, with: "")
        }
        print("！！！　ボールカウントは無い　　！！！")
        return ""
    }

    
//////////////////////////////////////////////////////////////////////////
//MARK:- 衝突処理
//////////////////////////////////////////////////////////////////////////
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        print("___---   衝突   ---___")
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        print(" body A = \(bodyA)")
        print(" body B = \(bodyB)")
        
        var nodeA:SKNode = SKNode()
        var nodeB:SKNode = SKNode()

        if let a = bodyA.node {
            nodeA = a
        }else{
            print("- A - represenetedObject:null 処理失敗")
            return
        }

        if let b = bodyB.node {
            nodeB = b
        }else{
            print("- B - represenetedObject:null 処理失敗")
            return
        }
        
            print("⭐️衝突 A = \(String(describing: nodeA.name!)):B = \(String(describing: nodeB.name!))")

// function
        
        //ボールカウントのみの文字列を取り出す
        func ballCountFromNode(name:String) -> String{
            if nodeA.name!.hasPrefix(name){
                return nodeA.name!.replacingOccurrences(of: name, with: "")
                
            }else
                if nodeB.name!.hasPrefix(name){
                    return nodeB.name!.replacingOccurrences(of: name, with: "")
            }
            print("！！！　ボールカウントは無い　　！！！")
            return ""
 
        }
        
        //プレイヤーのボールカウントのみの文字列を取り出す
        func ballCountFromNode_Player() ->String{
            return ballCountFromNode(name: _playerBallShadowName_A)
        }
        
        //敵のボールカウントのみの文字列を取り出す
        func ballCountFromNode_Enemy() ->String{
            return ballCountFromNode(name:_enemyBallShadowName_A)
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
            print("敵ボール名　\(enemyballName)")
            
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
                    }
                    else{
                        print("（；ー；）ボール削除失敗")
                    }
                }
            }
            
        }
        
        
        
        func deleteNodeA(){
            //破裂アニメーション
            let ballA = nodeA as! MyShapeNode
            self.addParticle(pos: ballA.position, ballLevel: ballA.ballLevel, type: .SPARK)
            ballA.isHidden = true
            //ボール削除
        }
        
        func deleteNodeB(){
            
        }
        
        func damege_BallSerch(){
            //ボール（影）はプレイヤーボールか？
            if nodeA.name!.hasPrefix(_playerBallShadowName_A) ||
                nodeB.name!.hasPrefix(_playerBallShadowName_A){
               
                let strCount = self.ballCountFromNode(node: nodeB)
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
                let strCount = self.ballCountFromNode(node: nodeB)
                let ballName = _enemyBallName + strCount
                print(ballName)
                let ball = self.childNode(withName: ballName)
                
                addSpark(pos: (ball?.position)!)
                
                nodeB.removeFromParent()
            }
        }

        
        func damage_Player(){
            print("-----プレイヤーダメージ")
            self.lifeDown_Player(value: 10)
            damege_BallSerch()
            }
        
        func damage_Enemy(){
            print("-------敵ダメージ")
            self.lifeDown_Enemy(value: 10)
            damege_BallSerch()
        }
        
//MARK:衝突判定
        
        //プレイヤーと　敵ボール
        if nodeA.name! == _playerName && nodeB.name!.hasPrefix(_enemyBallShadowName_A){
            print("プレイヤーに　ボールがあたった")
            damage_Player()
        }
        
        else
        //プレイヤーと　敵アッパーボール
            if nodeA.name! == _playerName && nodeB.name!.hasPrefix(_enemyUpperBallName){
                print("プレイヤーに　upperボールがあたった")
                damage_Player()
            }
            else
        //敵　と　プレイヤーボール
        if nodeA.name! == _enemyName && nodeB.name!.hasPrefix(_playerBallShadowName_A) {
            print("敵に　ボールが当たった")
            damage_Enemy()
        }
            
        else
            //敵　と　プレイヤーアッパーボール
            if nodeA.name! == _enemyName && nodeB.name!.hasPrefix(_playerUpperBallName) {
                print("敵に　upperボールが当たった")
                damage_Enemy()
            }
            else
   
        //Hit playerBall    & enemyBall
        if nodeA.name!.hasPrefix(_playerBallName) && nodeB.name!.hasPrefix(_enemyBallName) ||
            nodeB.name!.hasPrefix(_playerBallName) && nodeA.name!.hasPrefix(_enemyBallName)
        {
            print("ボールとボールがあたった")
            deleteBalls()
            
        }
        else
            if nodeA.name! == _enemyGroundLineName && nodeB.name!.hasPrefix(_playerUpperBallName){
                
                print("プレイヤーのアッパーボールが敵地面に当たった")
                //破裂
            addSpark(pos: nodeB.position)
                
            }
            else
                if nodeA.name! == _playerGroundLineNmae && nodeB.name!.hasPrefix(_enemyUpperBallName){
                    print("敵のアッパーボールが敵地面に当たった")
                    addSpark(pos: nodeB.position)
        }

    }
//////////////////////////////////////////////////////////////////////////
    //衝突処理 END
//////////////////////////////////////////////////////////////////////////

    func lifeDown_Player(value:Int){
        _player.life = _player.life - value
        self.chengeValue_LifeGauge_Player()
    }
    
    func lifeDown_Enemy(value:Int){
        _enemy.life = _enemy.life - value
        self.chengeValue_LifeGauge_Enemy()
    }

    //破裂アニメーション
    func addSpark(pos:CGPoint){
        let particle = makeParticle(pos: pos, ballLevel: 1, type: .SPARK)
        self.addChild(particle)
    }

    
//MARK:- GameOver Check
    
    func check_GameOver(){
        
        if _player.life <= 1{
            self.gameOver()
        }
        if _enemy.life <= 1 {
            self.gameOver()
        }
        
    }

    func gameOver(){
    print("---------- Game Over ---------------")
    
    }
    
    
//MARK:- イベントループ
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        self.check_GameOver()
        //Player
        //タッチ中で移動していない場合のカウントする
        if _isTouchON && !_isTouchMove{
            _upDateCount_Touch += 1
            
            if _upDateCount_Touch  == 10 ||
                _upDateCount_Touch  == 25 ||
                _upDateCount_Touch  == 60
            {
                print("ボールサイズアップ！！")
                _power += 1
//                _hasDummyBall_Player = true
            }
//            else{
//                _upDateCount_Touch = 0
//            }
        }
        
        if  _enemy.action == .STOP {
            _upDateCount_Enemy += 1
            print("_upDateCount_Enemy = \(_upDateCount_Enemy)")
            
            if _upDateCount_Enemy == 10 ||
            _upDateCount_Enemy == 25 ||
                _upDateCount_Enemy == 60 {
                _power_Enemy += 1
                print("＿敵の　ボールサイズアップ！！")
            }
        }else{
            _upDateCount_Enemy = 0
        }
        
        
    }
    
    func checkCount(){
        
    }
    
    override func didEvaluateActions() {
        if _enemy.action == .STOP{
            self.enemyActions()
        }
//        else{
//            print(_enemy.action.hashValue)
//        }


    }
    
    override func didSimulatePhysics() {
    }
    
///////////////////////////////////////////////////////////////////////
    
//MARK:- 開始
    
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
        
//MARK:中央線
        let beganPoint = CGPoint(x:-(self.frame.size.width) ,y:0 )
        let endPoint = CGPoint(x:self.frame.size.width ,y:0 )
        
        self.addEnemyGroundLine(beganPoint: beganPoint, endPoint: endPoint, name: _enemyGroundLineName)
        
//        self.addLine(beganPoint: CGPoint(x:-(self.frame.size.width) ,y:0 ), endPoint: CGPoint(x:self.frame.size.width ,y:0 ),name:"centerX_Line")
        
//MARK:中心線
//        self.addLine(beganPoint:CGPoint(x:0 ,y:-(self.frame.size.height)), endPoint: CGPoint(x:0 ,y:self.frame.size.height),name:"centerY_Line")
        
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
        
//        let path3 = MyBezierShape.makeLinePathFrom3Points(b3p: b3p2)
//        self.addLineFromPath(path: path3)
//        self.addPlayerBall(path: path3)

        
        
//        // 敵行動開始
//        let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(GameScene.enemyActions), userInfo: nil, repeats: true)
//        timer.fire()
        
        
//敵地面のY位置
        _groundPosY_Enemy = _enemy.position.y - _enemy.size.height / 2
        
//プレイヤー地面のY位置
        _groundPosY_Player = _player.position.y - _player.size.height / 2
        
//敵の移動できる左右の幅
        _groundPosX_LeftSide_Enamey = self.frame.size.width / 4
        _groundPosX_RightSide_Enamey = -self.frame.size.width / 4
//        let moveRangeEnemy:SKRange = SKRange(lowerLimit: _groundPosX_LeftSide_Enamey, upperLimit: _groundPosX_RightSide_Enamey)
        
        print("LeftSide = \(_groundPosX_LeftSide_Enamey)")
        print("RightSide = \(_groundPosX_RightSide_Enamey)")
        
        //Life
        self.addLife_Player()
        self.addLife_Enemy()
        
        //Magic
        
        self.addMagic_Player()
    }
    
////////////////////////////////////////////////
    
//MARK:- ライフゲージ　マジックゲージ
//    func makeGuage() -> SKSpriteNode{
//    
//    }
    
    func make_gauge(size:CGSize) -> MYGauge{
        let node = MYGauge(texture: nil, color: .white, size: size)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        return node
    }
    
    
    func make_gauge() ->SKSpriteNode{
        //ライフゲージ
        
        let gaugeSize = CGSize(width: _gaugeWidth, height: _gaugeHeight)
        let node = SKSpriteNode(color: .red, size: gaugeSize)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        
        let sideLine = SKShapeNode(rect: node.frame)
        sideLine.strokeColor = .white
        node.addChild(sideLine)
        
        return node
        
    }
    
    //マジックゲージ
    func make_gauge_Magic() ->  MYGauge{
        let node = make_gauge(size: CGSize(width: _gaugeWidth, height: _gaugeHeight))
        node.color = .green
        return node
    }
//    func make_gauge_Magic() -> SKSpriteNode{
//        let node = make_gauge()
//        node.color = .green
//        return node
//    }
    
    
    
    func addMagic_Player(){
        let magicGuage = make_gauge_Magic()
        magicGuage.position = CGPoint(x: -self.frame.size.width / 2 + 25,
                                      y: self.anchorPoint.y - (_gaugeHeight / 2))
        self.addChild(magicGuage)
    }
    
    
    func addLife_Player(){
        //ライフゲージ
        _lifeGauge_Player = make_gauge()
        
        _lifeGauge_Player.position = CGPoint(x: -self.frame.size.width / 2 + 10,
                                             y: self.anchorPoint.y - (_gaugeHeight / 2))
//        print("lifepos = \(_lifeGauge_Player.position)")
        
        self.addChild(_lifeGauge_Player)
    }
    
    func addLife_Enemy(){
       _lifeGauge_Enemy = make_gauge()
        _lifeGauge_Enemy.color = .blue
        _lifeGauge_Enemy.position = CGPoint(x: self.frame.size.width / 2 - 10,
                                            y: self.anchorPoint.y - (_gaugeHeight / 2))
        
        self.addChild(_lifeGauge_Enemy)
    }
    
    func addMagic_Enemy(){
        
    }
    
    //MARK:ライフ　マジックゲージ
    //MARK:ライフ値をゲージに反映
    func chengeValue_LifeGauge_Player(){
        //
        print("プレイヤーライフ値をゲージに反映")
        let newHeight = CGFloat(Double(_gaugeHeight) * Double(_player.life) / 100.0)
        _lifeGauge_Player.size = CGSize(width: _gaugeWidth, height:newHeight)
        
    }
    
    func chengeValue_LifeGauge_Enemy(){
        //
        print("敵ライフ値をゲージに反映")
        let newHeight = CGFloat(Double(_gaugeHeight) * Double(_enemy.life) / 100.0)
        _lifeGauge_Enemy.size = CGSize(width: _gaugeWidth, height:newHeight)
        
    }

    
    
    func changeValue_MagicGauge_Player(){
        print("マジック値をゲージに反映")
        let newHeight = CGFloat(Double(_gaugeHeight) * Double(_player.magicPower) / 100.0)
//        _magicGauge_Player.size = CGSize(width: _gaugeWidth, height:newHeight)
        
    }
    
    func changeValue_MagicGauge_Enemy(){
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
        
        //今なにもしていないか　チェック
        if _enemy.action == .STOP {
            
            //ランダムでアクションを選択
            _enemy.nextAction()

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
            case .BallThrow_Big:
                
                self.enemyAction_BallThrow_Upper()
                
            default:
                print("????   enemy default case")
            }
            
        }else{
            //何もしない
        }
    }

    
    //MARK:敵の行動
    //MARK:ボールを投げる
    func enemyAction_BallThrow(){
        print("ボールをなげる")
        let bp = makeBezierCurve3Points_Enemy(pos: _enemy.position)
        
        //ライン表示
//        self.addControlLine1(point0: bp.stP, point1: bp.contP)
//        self.addControlLine2(point0: bp.endP, point1: bp.contP)

    //軌道計算
        let path = self.makePath_3points(bp:bp)
        self.addEnemyBall(path:path)
        self._enemy.action = .STOP
    }
    
    //MARK:ボールを上に投げる
    func enemyAction_BallThrow_Upper(){
        print("ボールを上になげる")
        self.addEnemyBall_Upper()
        self._enemy.action = .STOP
        
    }
    
    //MARK:左へ移動
    func enemyAction_MoveLeft(){
        print("左へ移動")
        
        //移動できる幅
        let moveRangeX = abs(_groundPosX_LeftSide_Enamey) - abs(_enemy.position.x)
//        print("移動できる幅 \(moveRangeX)")
        //現在地から左の移動可能ポイント
        let randamX = arc4random_uniform(UInt32(moveRangeX))
//        print("\(randamX) 左に移動")
        //距離から移動時間を計算
        let moveSec:TimeInterval =  TimeInterval(Double(randamX) / 40.0)
        
        print("左へ　\(moveSec)秒で　\(randamX)移動　")
        
        //アクションを作成
        let action = SKAction.moveBy(x: -CGFloat(randamX), y: 0, duration: moveSec)
        
        _enemy.run(action, completion: {
         self._enemy.action = .STOP
        })
    }
    //MARK:右へ移動
    //move Right
    func enemyAction_MoveRight(){
        print("右へ移動")
        
        //移動できる幅
        let moveRangeX = abs(_groundPosX_RightSide_Enamey) - abs(_enemy.position.x)
        
        //現在地から左の移動可能ポイント
        let randamX = arc4random_uniform(UInt32(moveRangeX))
        
        //距離から移動時間を計算
        let moveSec:TimeInterval =  TimeInterval(Double(randamX) / 40.0)
        
        print("右へ　\(moveSec)秒で　\(randamX)移動　")

        //アクションを作成
        let action = SKAction.moveBy(x: CGFloat(randamX), y: 0, duration: moveSec)
        
        _enemy.run(action, completion: {
            self._enemy.action = .STOP
        })
    }
    
    //移動できるポイントをかえす
//    func enemy_MovingRandomPositionX() -> CGFloat{
//        var value:CGFloat = 0.0
//        let left = _groundPosX_LeftSide_Enamey - _enemy.position.x
//        let right = _enemy.position.x -  _groundPosX_RightSide_Enamey
//        
//        return value
//    }
    //移動するポイントから移動時間をかえす
//    func distanceToTime(value:CGFloat) -> TimeInterval{
//        
//    }

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
    //MARK:ボールを投げる
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
    
    //MARK:ボールを上に投げる
    func playerAction_BallThrow_Big(){
        self.addPlayerBall_Upper()
    }


    func playerAction_LeftMove(){
//        print("左に移動")
        _player.run(SKAction.moveBy(x: -10, y: 0, duration: 0.1))
    }
    
    func playerAction_RightMove(){
//        print("右に移動")
        _player.run(SKAction.moveBy(x: 10, y: 0, duration: 0.1))
        
    }
    
    func playerDamegeAction(damege:Int){
        _player.life -= damege
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
        let newSize = CGSize(width: size.width, height: size.height / 4)
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
        
        return shadow
    }

    func makeShadowNode_Enemy(size:CGSize,name:String) -> SKShapeNode{
        let shadow = makeShadowNode(size: size, name: name)
        shadow.physicsBody = SKPhysicsBody(circleOfRadius: shadow.frame.size.height / 2)
        shadow.physicsBody?.categoryBitMask     = _enemyCategory
        shadow.physicsBody?.collisionBitMask    = _playerCategory
        shadow.physicsBody?.contactTestBitMask  = _playerCategory
        
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

    
    //MARK:ボールなげるアクション
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
        
    //比率(ratio)を計算
        let contPosRatio = abs(bp.endP.x) / self.frame.size.width
        let contPosX = abs(_b3p.contP.x) * contPosRatio
        bp.contP = CGPoint(x: contPosX, y: _b3p.contP.y)
        //画面の左側の場合は、ーXにする
        if pos.x < 0 {
            bp.contP = CGPoint(x: -contPosX, y: _b3p.contP.y)
        }
        
        return bp
    }

    

    //Posから計算

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
        return ball
    }
    
    func makeBall_Enemy() -> MyShapeNode{
        let ball = makeShapeCircle(radius: _ary_BallRadius[_power_Enemy])
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
        self._player = self.makePlayer(charaNumber: _playerCharaNumber)
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
        let shadowSize = CGSize(width: self._player.size.width / 2, height:self._player.size.height / 4)
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
    
//MARK:Player Ball
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
        
    //playerボールのかげ
        let ballShadow = makeShadowNode_Player(size: ball.frame.size, name: ball.name!)
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
    
    func addPlayerBall_Upper(){
        print("アッパーボール発射！！！！！！！！")
        let ball = makeBall_Player()
        ball.fillColor = .black
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
            //削除する
            SKAction.removeFromParent()
            ])
        
        ball.run(action, completion: {
            print("アッパーボール　アクション終わり")
            
        })
        
//落下用のボール作成
        let fallBall = makeBall_Player()
        fallBall.name = _playerUpperBallName
        fallBall.fillColor = .black
        
        fallBall.setScale(0.5)
        fallBall.position = pos_Aerial
        fallBall.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width / 4)
        fallBall.physicsBody?.categoryBitMask = self._playerUpperBallCategory
        fallBall.physicsBody?.collisionBitMask = self._enemyCategory
        fallBall.physicsBody?.contactTestBitMask = self._enemyCategory

        
//  遅延実行  //////////////////////
        let dispatchTime = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter( deadline: dispatchTime ) {
    
        fallBall.addChild(emitter)
        self.addChild(fallBall)
        }
//  遅延実行 終わり  //////////////////////
        
        //ボールの影
        let shadow = makeShadowNode(size: ball.frame.size, name: "")
        shadow.alpha = 0.0
        shadow.setScale(0.1)
        shadow.position = pos_Fall
        self.addChild(shadow)
        
        let actionFallBall = SKAction.sequence([
            
            //落下
            actionFall,
            //削除する
            SKAction.removeFromParent()
            ])
        
        fallBall.run(actionFallBall, completion: {
            print("落下ボールアクション　終了")
            shadow.removeFromParent()
            
        })

        let shadowAction = SKAction.sequence([
            
            SKAction.group([
                SKAction.fadeAlpha(to: 0.8, duration: 2.0),
                SKAction.scale(to: 0.8, duration: 2.0)
                ]),
            SKAction.removeFromParent()
            ])
        shadowAction.timingMode = .easeIn
        shadow.run(shadowAction, completion: {
            
        })
    }

    
//MARK:- 敵
    func addEnemy(){
        self._enemy = makeEnemy(charaNumber: _enemyCharaNumber)
        
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
    
    //MARK:敵 Ball
    func addEnemyBall(path:CGPath){
        let ball = makeBall_Enemy()
        let str_Ballcount = makeBallCountString()
        ball.name = _enemyBallName + str_Ballcount
        
        ball.zPosition = _enemy.zPosition
        
        ball.setScale(0.5)
        ball.originalHeight = ball.frame.size.height
        
        let action = makeThrowAction_Enemy(path: path)
        
        action.timingMode = SKActionTimingMode.easeIn
        
        ball.run(action, completion: {
            print("Enemy Throw action end")
//            self.deleteControlLine()
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
    
    //MARK:敵Upperボール
    func addEnemyBall_Upper(){
        //上に投げるボール
        let ball = makeBall_Enemy()
        ball.fillColor = .blue
        ball.position = _enemy.position
        ball.zPosition = _enemy.zPosition + 0.01
        
        
        //エフェクト追加
        let emitter = makeEmitter_Ice()
//        emitter.setScale(CGFloat(_power))
        
        ball.addChild(emitter)
        
        ball.setScale(0.5)
        
        self.addChild(ball)

        //相手の上空のボール
        //ボールの　位置 プレイヤーの上空
        let pos_Aerial = CGPoint(x:_enemy.position.x * 2 ,y:(self.view?.frame.height)!)
        //アクション実行
        let action = SKAction.sequence([
            //上になげる（画面外へ消える）
            SKAction.moveTo(y: (self.view?.frame.size.height)!, duration: 0.5),
            //削除する
            SKAction.removeFromParent()
            ])
        
        ball.run(action, completion: {
            print("アッパーボール　アクション終わり")
        })

        
        //ボールの落ちる位置
        let pos_Fall = CGPoint(x: pos_Aerial.x, y: _groundPosY_Player)
        let actionFall = SKAction.move(to: pos_Fall, duration: 0.5)
        
        
        actionFall.timingMode = .easeIn
        
    //落下用のボール作成
        let fallBall = makeBall_Enemy()
        fallBall.name = _enemyUpperBallName
        fallBall.fillColor = .blue
        
//        fallBall.setScale(0.5)
        fallBall.position = pos_Aerial
        fallBall.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width / 2)
        fallBall.physicsBody?.categoryBitMask = self._enemyUpperBallCategory
        fallBall.physicsBody?.collisionBitMask = self._playerCategory
        fallBall.physicsBody?.contactTestBitMask = self._playerCategory

//  遅延実行  //////////////////////
        
        let dispatchTime = DispatchTime.now() + 1.25
        
        DispatchQueue.main.asyncAfter( deadline: dispatchTime ) {
            //処理
            
            fallBall.addChild(emitter)
            self.addChild(fallBall)
            
            
            let actionFallBall = SKAction.sequence([
                
                //落下
                actionFall,
                //削除する
                SKAction.removeFromParent()
                ])
            
            fallBall.run(actionFallBall, completion: {
                print("落下ボールアクション　終了")
            })
            
        }
//  遅延実行 終わり  //////////////////////

        //ボールの影
        let shadow = makeShadowNode(size: ball.frame.size, name: "")
        shadow.alpha = 0.0
        shadow.setScale(0.1)
        shadow.position = pos_Fall
        self.addChild(shadow)
        
        let shadowAction = SKAction.sequence([
            
            SKAction.group([
                SKAction.fadeAlpha(to: 0.8, duration: 2.0),
                SKAction.scale(to: 2.5, duration: 2.0)
                ]),
            SKAction.removeFromParent()
            ])
        shadowAction.timingMode = .easeIn
        shadow.run(shadowAction, completion: {
            
        })
    }
    
    
    //MARK:- パーティクル追加
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
    
    //MARK:- 線を表示
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
    
    func addEnemyGroundLine(beganPoint:CGPoint,endPoint:CGPoint,name:String?){
        let line = makeLine(beganPoint: beganPoint, endPoint: endPoint, name: name)
        line.name = name
        line.physicsBody = SKPhysicsBody(edgeFrom: beganPoint, to: endPoint)
        line.physicsBody?.categoryBitMask = _enemyGroundLineCategory
        line.physicsBody?.collisionBitMask = _playerUpperBallCategory
        line.physicsBody?.contactTestBitMask = _playerUpperBallCategory
        
        // Sceneに追加.
        self.addChild(line)
    }
}
