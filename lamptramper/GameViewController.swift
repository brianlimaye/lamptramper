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
import GoogleMobileAds

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate {
    
    //var bannerView: GADBannerView!
        
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
            //view.showsPhysics = true
        }
        
        /*
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-1088916107432693/7160005808"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
 */
        
        mainViewController = self
        authPlayer()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
            
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bottomLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
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
