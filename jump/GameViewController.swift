//
//  GameViewController.swift
//  test
//
//  Created by Shannah Santucci on 12.05.21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    private var sceneNode: GameScene?
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("GameViewController loaded") 
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    @IBAction func restart(_ sender: Any) {
        sceneNode?.delete(self)
        viewDidLoad()
    }
    
    @IBAction func pause(_ sender: Any) {
        guard let menuVC = storyboard?.instantiateViewController(identifier: "MenuVC") as? MenuViewController else {
            print("cannot instantiate")
            return
        }
        menuVC.modalPresentationStyle = .fullScreen
        menuVC.modalTransitionStyle = .crossDissolve
        present(menuVC, animated: true)
    }
}
