//
//  GameScene.swift
//  test
//
//  Created by Shannah Santucci on 12.05.21.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    public var player: SKNode?
    private var target: SKNode?
    private var restartButton: SKNode?
    private var timer: Timer?
    private var xAcc: Double?
    private var yAcc: Double?
    private var zAcc: Double?

    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        self.player = self.childNode(withName: "//player")
        if let player = self.player {
            player.alpha = 0.0
            player.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        self.target = self.childNode(withName: "//coin")
        if let target = self.target {
            target.alpha = 0.0
            target.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
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
    let motion = CMMotionManager()

    func startAccelerometers(){
       // Make sure the accelerometer hardware is available.
       if self.motion.isAccelerometerAvailable {
        self.motion.accelerometerUpdateInterval = 1.0 / 10.0  // 10 Hz
          self.motion.startAccelerometerUpdates()

          // Configure a timer to fetch the data.
        self.timer = Timer(fire: Date(), interval: (1.0/10.0),
                repeats: true, block: { (timer) in
             // Get the accelerometer data.
             if let data = self.motion.accelerometerData {
                self.xAcc = data.acceleration.x
                self.yAcc = data.acceleration.y
                self.zAcc = data.acceleration.z

                // Use the accelerometer data in your app.
                //print(x,y,z)
                if let player = self.player {
                    self.xAcc! >= 0 ? player.run(SKAction.scaleX(to: 0.1, duration: 0.1)) : player.run(SKAction.scaleX(to: -0.1, duration: 0.1))
                    
                    if self.xAcc! > 1 {
                        self.restartPosition()
                    }
                    print(self.xAcc!)
                }
             }
          })

          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer!, forMode: .default)
       }
    }
    func restartPosition() {
        print("restartPosition")
        if let player = self.player {
            player.position = CGPoint(x: 0, y: -300)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        startAccelerometers()
        
        if let player = self.player {
            if let xAcc = self.xAcc {
                player.run(SKAction.applyForce(CGVector(dx: xAcc/10, dy: 0.1), duration: 0.01))
            }
        }
        
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        //if let n = self.spinnyNode?.copy() as! SKShapeNode? {
        //    n.position = pos
        //    n.strokeColor = SKColor.blue
        //    self.addChild(n)
        //}
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
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
}
