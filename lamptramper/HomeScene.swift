//
//  HomeScene.swift
//  lamptramper
//
//  Created by Brian Limaye on 12/20/20.
//

import SpriteKit
import GameplayKit
import StoreKit

struct savedData {
    
    static var highScore: Int = 0
}

var mainViewController: GameViewController?

class HomeScene: SKScene {
    
    var background: SKSpriteNode = SKSpriteNode()
    var mainText: SKLabelNode = SKLabelNode()
    var platform: SKSpriteNode = SKSpriteNode()
    var lampSprite: SKSpriteNode = SKSpriteNode()
    var playButton: SKSpriteNode = SKSpriteNode()
    var rateButton: SKSpriteNode = SKSpriteNode()
    var boardButton: SKSpriteNode = SKSpriteNode()
    
    var playText: SKLabelNode = SKLabelNode()
    var rateText: SKLabelNode = SKLabelNode()
    var boardText: SKLabelNode = SKLabelNode()
    
    override func didMove(to view: SKView) {

        scene?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        drawBackground()
        drawMainText()
        drawPlatform()
        drawLamp()
        drawButtons()
    }
    
    private func pullSavedData() {
        
        savedData.highScore = GameScene.defaults.integer(forKey: "highscore")
    }
    
    private func drawMainText() -> Void {
        
        mainText = SKLabelNode(fontNamed: "Thirteen-Pixel-Fonts")
        mainText.position = CGPoint(x: -25, y: self.frame.size.height / 7)
        mainText.fontSize = self.frame.size.width * 0.06
        mainText.zPosition = 2
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            mainText.fontSize = self.frame.size.width * 0.08
        }
        
        mainText.text = "LAMP TRAMPER"
        
        self.addChild(mainText)
    }
    
    private func drawButtons() {
        
        playButton = SKSpriteNode(imageNamed: "pixelbutton")
        playButton.size = CGSize(width: playButton.size.width * (self.frame.size.width * 0.0004), height: playButton.size.height * (self.frame.size.width * 0.0004))
        playButton.position = CGPoint(x: -self.frame.size.width / 8, y: -self.frame.size.height / 18)
        playButton.name = "play"
        playButton.isUserInteractionEnabled = false
        
        rateButton = SKSpriteNode(imageNamed: "yellowpixelbutton")
        rateButton.size = CGSize(width: rateButton.size.width * (self.frame.size.width * 0.0004), height: rateButton.size.height * (self.frame.size.width * 0.0004))
        rateButton.position = CGPoint(x: self.frame.size.width / 20, y: -self.frame.size.height / 18)
        rateButton.name = "rate"
        rateButton.isUserInteractionEnabled = false
        
        boardButton = SKSpriteNode(imageNamed: "redpixelbutton")
        boardButton.size = CGSize(width: boardButton.size.width * (self.frame.size.width * 0.0005), height: boardButton.size.height * (self.frame.size.width * 0.00035))
        boardButton.position = CGPoint(x: 0, y: -self.frame.size.height / 2.7)
        boardButton.name = "leaderboard"
        boardButton.isUserInteractionEnabled = false
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            boardButton.position.y = -self.frame.size.height / 3.5
        }
        
        boardButton.zPosition = 4
        playButton.zPosition = 4
        rateButton.zPosition = 4
        
        //Text
        
        playText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        playText.fontSize = self.frame.size.width * 0.04
        playText.fontColor = .white
        playText.name = "playtext"
        playText.text = "Play"
        
        rateText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        rateText.fontSize = self.frame.size.width * 0.04
        rateText.fontColor = .white
        rateText.name = "ratetext"
        rateText.text = "Rate"
        
        boardText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        boardText.fontSize = self.frame.size.width * 0.04
        boardText.fontColor = .white
        boardText.name = "boardtext"
        boardText.text = "Leaderboard"
        
        playText.zPosition = 5
        rateText.zPosition = 5
        boardText.zPosition = 5
        
        playButton.addChild(playText)
        rateButton.addChild(rateText)
        boardButton.addChild(boardText)
        
        playText.position = CGPoint(x: 0, y: playButton.size.height / 12)
        rateText.position = CGPoint(x: 0, y: rateButton.size.height / 12)
        boardText.position = CGPoint(x: -boardButton.size.width / 11, y: boardButton.size.height / 3.75)
        
        self.addChild(playButton)
        self.addChild(rateButton)
        self.addChild(boardButton)
    }
    
    private func drawBackground() -> Void {
        
        background = SKSpriteNode(imageNamed: "tramperbackg")
        
        background.size.width = (scene?.view?.frame.size.width)!
        background.size.height = (scene?.view?.frame.size.height)!
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            background.size.width *= 1.05
        }
        
        background.zPosition = 1
        
        self.addChild(background)
    }
    
    private func drawPlatform() -> Void {
        
        platform = SKSpriteNode(imageNamed: "trampergrounds")
        
        platform.position = CGPoint(x: 0, y: -self.frame.size.height / 2.5)
        
        platform.size.width = (scene?.view?.frame.size.width)!
        platform.size.height = (scene?.view?.frame.size.height)! / 5
        
        platform.zPosition = 2
        
        self.addChild(platform)
    }
    
    private func drawLamp() -> Void {
        
        var startingYPos: CGFloat = 0
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
            startingYPos = -self.frame.size.height / 5.25
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            startingYPos = -self.frame.size.height / 4.5
        }
        
        lampSprite = SKSpriteNode(imageNamed: "lamp1")
        
        let lampFrames1: [SKTexture] = [SKTexture(imageNamed: "lamp1"), SKTexture(imageNamed: "lamp2"), SKTexture(imageNamed: "lamp3"), SKTexture(imageNamed: "lamp4"), SKTexture(imageNamed: "lamp5")]
        
        let lampFrame2: [SKTexture] = [SKTexture(imageNamed: "lamp6")]
        
        let lampJumpAnimation = SKAction.animate(with: lampFrames1, timePerFrame: 0.05)
        let moveJumpAnimation = SKAction.moveTo(y: -self.frame.size.height / 12, duration: 0.17)
        let lampLandAnimation = SKAction.animate(with: lampFrame2, timePerFrame: 0.05)
        let moveLandAnimation = SKAction.moveTo(y: startingYPos, duration: 0.17)
        
        let rightShift = SKAction.moveTo(x: self.frame.size.width / 2.25, duration: 5)
        let leftShift = SKAction.moveTo(x: -self.frame.size.width / 2.25, duration: 5)
        
        let jumpSequencer = SKAction.sequence([lampJumpAnimation, moveJumpAnimation, lampLandAnimation, moveLandAnimation])
        let shiftSequencer = SKAction.sequence([rightShift, leftShift])
        
        let lampAnimRepeater = SKAction.repeatForever(jumpSequencer)
        let shiftRepeater = SKAction.repeatForever(shiftSequencer)
        
        lampSprite.position = CGPoint(x: -self.frame.size.width / 2.5, y: startingYPos)
        lampSprite.size = CGSize(width: lampSprite.size.width * (self.frame.size.width * 0.00025), height: lampSprite.size.height * (self.frame.size.width * 0.00025))
        
        lampSprite.zPosition = 3
        lampSprite.xScale = -1
        
        lampSprite.run(lampAnimRepeater)
        //lampSprite.run(shiftRepeater)
        
        self.addChild(lampSprite)
    }
    
    private func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()

        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "id1543774316") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
        
        let location = touch.previousLocation(in: self)
        let node = self.nodes(at: location).first
        
        if((node?.name == "play") || (node?.name == "playtext"))
        {
            let gameScene = GameScene(size: (view?.frame.size)!)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene)
        }
        if((node?.name == "rate") || (node?.name == "ratetext")) {
            
            rateApp()
        }
        
        if((node?.name == "leaderboard") || (node?.name == "boardtext")) {
            
            mainViewController?.showLeaderBoard()
        }
      }
   }
}
