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
    private var batteryLoad : SKShapeNode?
    private var battery : SKNode?
    private var player: Element?
    private var target: SKNode?
    private var ground: SKNode?
    private var restartButton: SKNode?
    private var timer: Timer?
    private var xAcc: Double?
    private var yAcc: Double?
    private var zAcc: Double?
    private var counter = 0
    

    let motion = CMMotionManager()
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        player = Element(gameScene: self, withName: "sausage", size: CGSize(width: 160, height: 80))
        self.target = self.childNode(withName: "//coin")
        self.ground = self.childNode(withName: "//ground")
        self.restartButton = self.childNode(withName: "//restart")
        self.battery = self.childNode(withName: "//battery")
        
        for children in self.children {
            children.alpha = 0.0
            children.run(SKAction.fadeIn(withDuration: 2.0))
            children.physicsBody?.usesPreciseCollisionDetection = true
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
        move()
    }
    
    func move(){
       // Make sure the accelerometer hardware is available
       if self.motion.isAccelerometerAvailable {
        self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
          self.motion.startAccelerometerUpdates()

          // Configure a timer to fetch the data
        self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                repeats: true, block: { (timer) in
             // Get the accelerometer data
             if let data = self.motion.accelerometerData {
                self.xAcc = data.acceleration.x
                self.yAcc = data.acceleration.y
                self.zAcc = data.acceleration.z

                if let player = self.player, let targetBody = self.target?.physicsBody, let battery = self.battery {
                    player.centerScene()
                    player.explodeContactedBodies(target: targetBody)
                    //self.xAcc! >= 0 ? player.run(SKAction.scaleX(to: 0.09, duration: 0.1)) : player.run(SKAction.scaleX(to: -0.09, duration: 0.1))

                    //update battery position
                    battery.position.y = player.getPosition().y + 640
                    battery.position.x = player.getPosition().x - 140
                }
             }
          })

          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer!, forMode: .default)
       }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let player = self.player, let xAcc = self.xAcc {
            player.move(withDirection: CGVector(dx: CGFloat(xAcc*1000),
                                                dy: CGFloat(1000)))
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
        if let player = self.player {
            if let n = self.ground?.copy() as! SKNode? {
                n.position.x = CGFloat.random(in: -500...500)
                n.position.y = CGFloat.random(in: player.getPosition().y + 400...player.getPosition().y + 800)
                n.alpha = 0.0
                n.run(SKAction.fadeIn(withDuration: 0.2))
                n.run(SKAction.applyImpulse(CGVector(dx: 1, dy: 1), duration: 0.1))
                n.physicsBody?.usesPreciseCollisionDetection = true

                if(counter%4 == 0) { self.addChild(n) }
            }
            if let n = self.target?.copy() as! SKNode? {
                n.position.x = CGFloat.random(in: -500...500)
                n.position.y = CGFloat.random(in: player.getPosition().y+400...player.getPosition().y+800)
                n.alpha = 0.0
                n.run(SKAction.fadeIn(withDuration: 0.5))
                n.run(SKAction.applyImpulse(CGVector(dx: 1, dy: 1), duration: 0.1))
                n.physicsBody?.usesPreciseCollisionDetection = true

                if(counter%3 == 0) { self.addChild(n) }
            }
            counter += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
            //let location = t.location(in: self)
            //let touchedNodes = nodes(at: location)
            //if(touchedNodes.first!.isEqual(to: restartButton!)) {restartPosition()}
        }
        
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
