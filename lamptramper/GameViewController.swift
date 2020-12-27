//
//  GameViewController.swift
//  lamptramper
//
//  Created by Brian Limaye on 12/19/20.
//

import UIKit
import GameKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
        
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
            view.showsPhysics = true
        }
        
        mainViewController = self
        
        authPlayer()
    }

    
    func authPlayer(){
            
        let localPlayer = GKLocalPlayer.local
            
            localPlayer.authenticateHandler = {
                (view, error) in
                
                if view != nil {
                    
                    self.present(view!, animated: true, completion: nil)
                }
                else {
                    
                    print(GKLocalPlayer.local.isAuthenticated)
                }
            }
        }
        
        
        func saveHighscore(number : Int){
            
            if GKLocalPlayer.local.isAuthenticated {
                
                let scoreReporter = GKScore(leaderboardIdentifier: "com.ishiba.lamptramper.HighScores")
                
                scoreReporter.value = Int64(number)
                
                let scoreArray : [GKScore] = [scoreReporter]
                
                GKScore.report(scoreArray, withCompletionHandler: nil)
            }
        }
        
        func showLeaderBoard(){
            let viewController = self.view.window?.rootViewController
            let gcvc = GKGameCenterViewController()
            
            gcvc.gameCenterDelegate = self
            
            viewController?.present(gcvc, animated: true, completion: nil)
        }
        
        
       func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true, completion: nil)
            
        }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
    }
}
