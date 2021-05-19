//
//  Model.swift
//  jump
//
//  Created by Shannah Santucci on 13.05.21.
//

import Foundation
import SpriteKit
import GameplayKit
import CoreMotion

class Element {
    var graphic: SKSpriteNode?
    var scene: GameScene?
    var name: String?
    
    init(gameScene: GameScene, withName name: String, size: CGFloat, initPosition: CGPoint) {
        self.graphic = SKSpriteNode(imageNamed: name)
        self.scene = gameScene
        self.name = name
        
        if let graphic = self.graphic, let scene = self.scene {
            graphic.size.height *= size
            graphic.size.width *= size
            graphic.physicsBody = SKPhysicsBody(texture: graphic.texture!, size: graphic.size)
            graphic.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            graphic.physicsBody?.allowsRotation = false
            graphic.physicsBody?.affectedByGravity = false
            graphic.physicsBody?.pinned = true
            graphic.physicsBody?.isDynamic = true
            graphic.physicsBody?.mass = (graphic.size.height+graphic.size.width)/2
            graphic.position = initPosition
            print("\(name) loaded successfully")
            scene.addChild(graphic)
        } else {print("error loading \(name)")}
    }
    func centerScene(starEffect: SKEmitterNode) {
        if let scene = self.scene {
            var x = -(self.getPosition().x/scene.size.width)
            if(x > 0.5) { x = 0.5 }
            else if (x < -0.5) { x = -0.5 }
            
            let y = -(self.getPosition().y/scene.size.height)
            scene.anchorPoint.y = y+0.2 //offset
            scene.anchorPoint.x = x+0.5
            
            scene.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: (y/30)+0.48, blue: (y/30)+1, alpha: 1))
            
            starEffect.position.x = self.getPosition().x
            starEffect.position.y = self.getPosition().y + 500
            starEffect.particleBirthRate = -y/30
            starEffect.particleZPosition = -10
        }
    }
    func move (withDirection direction: CGVector) {
        self.graphic?.physicsBody?.velocity = direction
    }
    func getPosition() -> CGPoint {
        if let position = self.graphic?.position {
            return position
        }
        print("no graphic found -> no position")
        return CGPoint(x: 0, y: 0)
    }
    func generateNew(altitude: CGFloat) {
        if let n = self.graphic?.copy() as! SKSpriteNode?, let scene = self.scene{
            n.position.x = CGFloat.random(in: -300...300)
            n.position.y = altitude
            n.alpha = 0.0
            n.run(SKAction.fadeIn(withDuration: 0.2))
            n.run(SKAction.applyImpulse(CGVector(dx: 1, dy: 1), duration: 0.1))
            n.physicsBody?.usesPreciseCollisionDetection = true

            scene.addChild(n)
        }
    }
}

class Player : Element {
    var score = 0
    var life = 100
    var tap = 0
    var maxAltitude = CGFloat(-500);
    
    override init(gameScene: GameScene, withName name: String, size: CGFloat, initPosition: CGPoint) {
        super.init(gameScene: gameScene, withName: name, size: size, initPosition: initPosition)
        
        if let graphic = self.graphic {
            graphic.physicsBody?.affectedByGravity = true
            graphic.physicsBody?.allowsRotation = true
            graphic.physicsBody?.pinned = false
        } else {print("error loading \(name) components")}
    }
    
    override func move(withDirection direction: CGVector) {
        tap+=1
        var affectedDirection = direction
        affectedDirection.dy -= CGFloat(tap)
        print(affectedDirection.dy)
        super.move(withDirection: affectedDirection)
        self.graphic?.run(SKAction.playSoundFileNamed("slimeSplash.mp3", waitForCompletion: false))
    }
    func explodeContactedBodies(type target: Element) {
        if let bodies = self.graphic?.physicsBody?.allContactedBodies() {
            
            for body: SKPhysicsBody in bodies {
                //print(body.node?.name ?? "no name")
                if (body.node?.name == target.name) {
                    body.node?.removeFromParent()
                    updateScore(offset: 1)
                    bumb()
                }
            }
        }
    }
    func bumb() {
        if let action = SKAction(named: "Pulse"), let effect = SKEmitterNode(fileNamed: "bump.sks") {
            self.graphic?.run(action)
            effect.position = self.getPosition()
            effect.numParticlesToEmit = 100-tap
            effect.targetNode = self.scene
            self.scene?.addChild(effect)
        } else {
            print("Pulse or bump failed to load")
        }
    }
    func getMaxAltitude() -> CGFloat {
        let altitude = self.getPosition().y.rounded()
        if(altitude > maxAltitude) {
            maxAltitude = altitude
        }
        return maxAltitude
    }
    func updateScore(offset: Int) {
        score += offset
        //print("Score updates: \(score)")
    }

}
