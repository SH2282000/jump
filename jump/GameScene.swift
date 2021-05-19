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
    
    private var spinnyNode : SKShapeNode?
    private var label : SKLabelNode?
    private var starEffect: SKEmitterNode?
    private var player: Player?
    private var target: Element?
    private var ground: Element?
    private var obstacleAltitude: [CGFloat] = []

    private var timer: Timer?
    private var xAcc: Double?
    private var yAcc: Double?
    private var zAcc: Double?
    private var counter = 0
    

    let motion = CMMotionManager()
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        
        self.player = Player(gameScene: self, withName: "sausage", size: 0.15, initPosition: CGPoint(x: 0, y: -300))
        self.target = Element(gameScene: self, withName: "coin", size: 0.1, initPosition: CGPoint(x: 0, y: 200))
        self.ground = Element(gameScene: self, withName: "ground", size: 0.3, initPosition: CGPoint(x: 0, y: -360))
        self.obstacleAltitude.append((self.ground?.getPosition().y.rounded())!)
        self.obstacleAltitude.append((self.target?.getPosition().y.rounded())!)
        
        self.label = SKLabelNode(fontNamed: "Chalkduster")
        if let label = self.label {
            label.text = "X Position"
            label.fontSize = 55
            label.fontColor = SKColor.white
            self.addChild(label)
        }
        self.starEffect = SKEmitterNode(fileNamed: "starSky.sks")
        if let starEffect = self.starEffect {
            starEffect.targetNode = self
            self.addChild(starEffect)
        }
        
        // Create shape node to use during touch interaction
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

                if let player = self.player, let target = self.target, let label = self.label, let ground = self.ground, let starEffect = self.starEffect {
                    player.centerScene(starEffect: starEffect)
                    player.explodeContactedBodies(type: target)
                    //self.xAcc! >= 0 ? player.run(SKAction.scaleX(to: 0.09, duration: 0.1)) : player.run(SKAction.scaleX(to: -0.09, duration: 0.1))
                    
                    //create the map
                    var i = CGFloat(0)
                    while(i < player.getMaxAltitude()+500) {
                        if(!self.obstacleAltitude.contains(i)) {
                            ground.generateNew(altitude: i)
                            self.obstacleAltitude.append(i)
                        }
                        i += 400
                    }
                    //update label position on player position
                    label.text = "y: \(Int(player.getPosition().y.rounded()))"
                    label.position = CGPoint(x: player.getPosition().x, y: player.getPosition().y+200)
                }
             }
          })

          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer!, forMode: .default)
       }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let player = self.player, let xAcc = self.xAcc {
            let direction = CGVector(dx: CGFloat(xAcc*1000), dy: CGFloat(600))
            player.move(withDirection: direction)
            player.bumb()
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
        /*if let player = self.player {
            if let n = self.ground?.graphic?.copy() as! SKNode? {
                n.position.x = CGFloat.random(in: -500...500)
                n.position.y = CGFloat.random(in: player.getPosition().y + 400...player.getPosition().y + 800)
                n.alpha = 0.0
                n.run(SKAction.fadeIn(withDuration: 0.2))
                n.run(SKAction.applyImpulse(CGVector(dx: 1, dy: 1), duration: 0.1))
                n.physicsBody?.usesPreciseCollisionDetection = true

                if(counter%4 == 0) { self.addChild(n) }
            }
            if let n = self.target?.graphic?.copy() as! SKNode? {
                n.position.x = CGFloat.random(in: -500...500)
                n.position.y = CGFloat.random(in: player.getPosition().y+400...player.getPosition().y+800)
                n.alpha = 0.0
                n.run(SKAction.fadeIn(withDuration: 0.5))
                n.run(SKAction.applyImpulse(CGVector(dx: 1, dy: 1), duration: 0.1))
                n.physicsBody?.usesPreciseCollisionDetection = true

                if(counter%3 == 0) { self.addChild(n) }
            }
            counter += 1
        }*/
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
