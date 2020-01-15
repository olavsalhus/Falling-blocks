//
//  GameViewController.swift
//  Blocks falling
//
//  Created by Olav Salhus on 05/01/2020.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    let scene : GameScene = SKScene(fileNamed: "GameScene") as! GameScene
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            scene.scaleMode = .aspectFit
            
            // Present the scene
            view.presentScene(scene)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
