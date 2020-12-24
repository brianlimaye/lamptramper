//
//  GameViewController.swift
//  lamptramper
//
//  Created by Brian Limaye on 12/19/20.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        if let view = self.view as! SKView? {
            
            let scene = HomeScene(size: view.frame.size)
            scene.scaleMode = .aspectFill
            scene.size = self.view.bounds.size
            view.presentScene(scene)
                        
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
    }
}
