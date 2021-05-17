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
            graphic.physicsBody?.allowsRotation = true
            graphic.physicsBody?.affectedByGravity = false
            graphic.physicsBody?.isDynamic = true
            graphic.physicsBody?.mass = (graphic.size.height+graphic.size.width)/2
            graphic.position = initPosition
            print("\(name) loaded successfully")
            scene.addChild(graphic)
        } else {print("error loading \(name)")}
    }
    func centerScene() {
        if let scene = self.scene, let graphic = self.graphic {
            scene.anchorPoint.x = -(graphic.position.x/scene.size.width)+0.5
            scene.anchorPoint.y = -(graphic.position.y/scene.size.height)+0.2
        }
    }
    func move (withDirection direction: CGVector) {
        self.graphic?.physicsBody?.velocity = direction
    }
    func bumb() {
        if let action = SKAction(named: "Pulse"), let effect = SKEmitterNode(fileNamed: "bump.sks") {
            self.graphic?.run(action)
            effect.position = self.getPosition()
            effect.numParticlesToEmit = 30
            effect.targetNode = self.scene
            self.scene?.addChild(effect)
        } else {
            print("Pulse or bump failed to load")
        }
    }
    func getPosition() -> CGPoint {
        if let position = self.graphic?.position {
            return position
        }
        print("no graphic found -> no position")
        return CGPoint(x: 0, y: 0)
    }
}

class Player : Element {
    var score = 0
    var life = 100
    
    override init(gameScene: GameScene, withName name: String, size: CGFloat, initPosition: CGPoint) {
        super.init(gameScene: gameScene, withName: name, size: size, initPosition: initPosition)
        
        if let graphic = self.graphic {
            graphic.physicsBody?.affectedByGravity = true
        } else {print("error loading \(name)")}
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
    func updateScore(offset: Int) {
        score += offset
        //print("Score updates: \(score)")
    }

}
