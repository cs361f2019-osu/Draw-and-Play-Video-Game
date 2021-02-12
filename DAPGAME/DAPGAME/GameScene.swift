//
//  GameScene.swift
//  DAPGAME
//
//  Created by Ying Li on 11/14/20.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var mssg:String?="NOOO"
    
    typealias MapObject = (String,CGPoint,CGFloat,CGFloat)
    var demodata:[MapObject] = [
        ("o",CGPoint(x:1.0,y:1.0),48.0,48.0),
        ("b",CGPoint(x:-60.0,y:-60.0),48.0,48.0),
        ("b",CGPoint(x:60.0,y:-60.0),48.0,48.0),
        ("x",CGPoint(x:0.0,y:-500.0),48.0,48.0)
    ]
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var motion = CMMotionManager()
    
    private var lastUpdateTime : TimeInterval = 0
    
    private var spinnyNode : SKShapeNode?
    
    private var timer : Timer?
    private var ball : SKSpriteNode?
    private var goal : SKSpriteNode?
    
    private var gyrox : Double?
    private var gyroy : Double?
    private var accmx : Double?
    private var accmy : Double?
    
    
    private var labelx : SKLabelNode?
    private var labely : SKLabelNode?
    private var winText : SKLabelNode?
    
    override func sceneDidLoad() {
        startAccelerometers()
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.labelx = self.childNode(withName: "//labelx") as? SKLabelNode
        self.labely = self.childNode(withName: "//labely") as? SKLabelNode
        
        self.winText = self.childNode(withName: "//wintext") as? SKLabelNode
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        self.backgroundColor = SKColor.white
        
        self.winText?.text = mssg
//
        //create a ball
        initialize(data:demodata)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        
        addBlock(px: pos.x, py: pos.y)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    //add a block to the game view
    
    func addBlock(px:CGFloat, py:CGFloat ) {
        let block = SKSpriteNode(imageNamed: "block")

        block.position = CGPoint(x:px,y:py)
        block.name = "block"
        block.setScale(0.2)
        block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: block.size.width,height: block.size.height))
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.pinned = true
        block.physicsBody?.allowsRotation = false
        self.addChild(block)
    }
    
    func addBall(px:CGFloat, py:CGFloat ) {
        self.ball = SKSpriteNode(imageNamed: "ball")
        self.ball!.name = "Ball"
        self.ball!.position = CGPoint(x: px, y: py)
        self.ball!.setScale(0.1)
        self.ball!.physicsBody = SKPhysicsBody(circleOfRadius: self.ball!.size.width / 2.0)
        self.ball!.physicsBody?.contactTestBitMask = 1
        self.addChild(self.ball!)
    }
    
    func addGoal(px:CGFloat, py:CGFloat ) {
        self.goal = SKSpriteNode(imageNamed: "Xmark")
        self.goal!.name = "Xmark"
        self.goal!.position = CGPoint(x: px, y: py)
        self.goal!.zPosition = -1
        self.goal!.physicsBody = SKPhysicsBody(texture: (self.goal?.texture)!, size:(self.goal?.texture)!.size())
        self.goal!.setScale(0.2)
        self.goal!.physicsBody?.isDynamic = false
        self.goal!.physicsBody?.allowsRotation = false
        self.goal!.physicsBody?.affectedByGravity = false
        self.goal!.physicsBody?.pinned = true
        self.goal!.physicsBody?.categoryBitMask = 0
        self.goal!.physicsBody?.fieldBitMask = 0
        self.goal!.physicsBody?.collisionBitMask = 0
        self.goal!.physicsBody?.contactTestBitMask = 1
        self.addChild(self.goal!)
    }
    
    func initialize(data:[MapObject]) {
        //name position wdith height
        for (name,pos,_,_)in data{
            if(name=="o"||name=="O"){
                addBall(px: pos.x, py: pos.y)
            }
            if(name=="b"||name=="B"){
                addBlock(px: pos.x, py: pos.y)
            }
            if(name=="x"||name=="X"){
                addGoal(px: pos.x, py: pos.y)
            }
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        let x = 10.0 * (self.accmx ?? 0 )
        let y = 10.0 * (self.accmy ?? -0.98)
        self.labelx!.text = "X: " + String(format: "%f", x )
        self.labely!.text = "Y: " + String(format: "%f", y )
        self.physicsWorld.gravity = CGVector(dx:x ,dy:y )
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {

        if contact.bodyA.node?.name == "Ball" &&
            contact.bodyB.node?.name == "Xmark" || contact.bodyA.node?.name == "Xmark" &&
            contact.bodyB.node?.name == "Ball" {

            winAction()
            
        }
    }
    
    
    func startGyros() {
       if motion.isGyroAvailable {
          self.motion.gyroUpdateInterval = 1.0 / 60.0
          self.motion.startGyroUpdates()

          // Configure a timer to fetch the accelerometer data.
          self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                 repeats: true, block: { (timer) in
             // Get the gyro data.
             if let data = self.motion.gyroData {
                self.gyrox = data.rotationRate.x
                self.gyroy = data.rotationRate.y
                //let z = data.rotationRate.z

                // Use the gyroscope data in your app.
             }
          })

          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
       }
    }
    
    func startAccelerometers() {
       // Make sure the accelerometer hardware is available.
       if self.motion.isAccelerometerAvailable {
          self.motion.accelerometerUpdateInterval = 1.0 / 100.0  // 100 Hz
          self.motion.startAccelerometerUpdates()

          // Configure a timer to fetch the data.
          self.timer = Timer(fire: Date(), interval: (1.0/100.0),
                repeats: true, block: { (timer) in
             // Get the accelerometer data.
             if let data = self.motion.accelerometerData {
                self.accmx = data.acceleration.x
                self.accmy = data.acceleration.y
               //let z = data.acceleration.z

                // Use the accelerometer data in your app.
             }
          })

          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
       }
    }
    
    func stopAccelerometers() {
       if self.timer != nil {
          self.timer?.invalidate()
          self.timer = nil

        self.motion.stopAccelerometerUpdates()
       }
    }
    
    func stopGyros() {
       if self.timer != nil {
          self.timer?.invalidate()
          self.timer = nil

          self.motion.stopGyroUpdates()
       }
    }
    
    func winAction() {
        self.winText?.text = "Win！"
    }
    
    func getDistance(p1:CGPoint,p2:CGPoint)->CGFloat {
        let xDist = (p2.x - p1.x)
        let yDist = (p2.y - p1.y)
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}
