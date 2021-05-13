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
    var score = 0
    var life = 100
    
    init(gameScene: GameScene, withName name: String, size: CGSize) {
        self.graphic = SKSpriteNode(imageNamed: name)
        self.scene = gameScene
        
        if let graphic = self.graphic, let scene = self.scene {
            graphic.physicsBody = SKPhysicsBody(texture: graphic.texture!, size: size)
            graphic.size = size
            graphic.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            graphic.physicsBody?.allowsRotation = true
            graphic.physicsBody?.affectedByGravity = true
            graphic.physicsBody?.isDynamic = true
            graphic.physicsBody?.mass = 30
            graphic.position = CGPoint(x: 0, y: -340)
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
    func getPosition() -> CGPoint {
        if let position = self.graphic?.position {
            return position
        }
        print("no graphic found -> no position")
        return CGPoint(x: 0, y: 0)
    }
    func explodeContactedBodies(target: SKPhysicsBody) {
        if let bodies = self.graphic?.physicsBody?.allContactedBodies() {
            for body: SKPhysicsBody in bodies {
                if (body.isEqual(target)) {
                    body.node?.removeFromParent()
                    updateScore(offset: 1)
                }
            }
        }
    }
    func updateScore(offset: Int) {
        score += offset
        print("Score updates: \(score)")
    }
}
