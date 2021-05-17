//
//  MenuViewController.swift
//  jump
//
//  Created by Shannah Santucci on 16.05.21.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var titleApp: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MenuViewController loaded")
        
        self.titleApp.alpha  = 0
        self.logo.alpha = 0
        self.playButton.alpha = 0
        
        let blur = UIBlurEffect(style: .light)
        let blurEffect = UIVisualEffectView(effect: blur)
        blurEffect.frame = self.view.bounds
        self.view.addSubview(blurEffect)
        
        UIView.animate(withDuration: 1, animations: {
            self.titleApp.alpha  = 1.0
            self.logo.alpha = 1.0
            self.playButton.alpha = 1.0
            blurEffect.alpha = 0
        })
    }
    
    @IBAction func play(_ sender: Any) {
        guard let gameVC = storyboard?.instantiateViewController(identifier: "GameVC") as? GameViewController else {
            return
        }
        gameVC.modalPresentationStyle = .fullScreen
        gameVC.modalTransitionStyle = .crossDissolve
        present(gameVC, animated: true)
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait.union(.portraitUpsideDown)
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
