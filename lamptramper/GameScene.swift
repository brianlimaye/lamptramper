//
//  GameScene.swift
//  lamptramper
//
//  Created by Brian Limaye on 12/19/20.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct ColliderType {
        
        static let lamp: UInt32 = 0
        static let posI: UInt32 = 1
        static let negI: UInt32 = 2
    }
    
    private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    static let defaults = UserDefaults.standard
    var audioPlayer: AVAudioPlayer?
        
    var background: SKSpriteNode = SKSpriteNode()
    var platform: SKSpriteNode = SKSpriteNode()
    var lampSprite: SKSpriteNode = SKSpriteNode()
    var pixelHand: SKSpriteNode = SKSpriteNode()
    var tintedLamp: SKSpriteNode = SKSpriteNode()
    var tapText: SKLabelNode = SKLabelNode()
    var countdownText: SKLabelNode = SKLabelNode()
    var scoreDisplay: SKLabelNode = SKLabelNode()
    var bestDisplay: SKLabelNode = SKLabelNode()
    var ISprites: [SKSpriteNode] = [SKSpriteNode]()
    var currentTexture: SKSpriteNode = SKSpriteNode()
    var fillerNode: SKSpriteNode = SKSpriteNode()
    var textureSize: CGSize = CGSize()
    var initialSize: CGSize = CGSize()
    var currentScore: Int = 0
    var currentJumpCount: Int = 0
    var iterationCount: Int = 0
    var hasReturned: Bool = true
    var isLanding: Bool = false
    var gameIsOver: Bool = false
    var currentSpeed: CGFloat = 5
    
    var lampShift: SKAction = SKAction()
    var lampAnimation: SKAction = SKAction()
    
    override func didMove(to view: SKView) {
        
        scene?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
        
        initializeTextures()
        initializeGame()
    }
    
    private func initializeGame() {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(jumpLamp))
        self.view?.addGestureRecognizer(tapGesture)
        
        drawBackground()
        drawPlatform()
        drawLamp()
        performCountdownTutorial()
    }
    
    private func resetModifiers() {
        
        iterationCount = 0
        currentScore = 0
        currentSpeed = 5.0
        currentJumpCount = 0
        gameIsOver = false
        hasReturned = true
        isLanding = false
    }
    
    private func initializeTextures() {
        
        ISprites.append(SKSpriteNode(imageNamed: "letteri"))
        ISprites.append(SKSpriteNode(imageNamed: "lavenderletteri"))
        ISprites.append(SKSpriteNode(imageNamed: "blueletteri"))
        ISprites.append(SKSpriteNode(imageNamed: "pinkletteri"))
        ISprites.append(SKSpriteNode(imageNamed: "tanletteri"))
        ISprites.append(SKSpriteNode(imageNamed: "whiteletteri"))
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
        var endingYPos: CGFloat = 0
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
            startingYPos = -self.frame.size.height / 5.25
            endingYPos = -self.frame.size.height / 12
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            startingYPos = -self.frame.size.height / 4.5
            endingYPos = -self.frame.size.height / 8
        }
        
        lampSprite = SKSpriteNode(imageNamed: "lamp1")
        
        let lampFrames1: [SKTexture] = [SKTexture(imageNamed: "lamp1"), SKTexture(imageNamed: "lamp2"), SKTexture(imageNamed: "lamp3"), SKTexture(imageNamed: "lamp4"), SKTexture(imageNamed: "lamp5")]
        
        let lampFrame2: [SKTexture] = [SKTexture(imageNamed: "lamp6")]
        
        let lampJumpAnimation = SKAction.animate(with: lampFrames1, timePerFrame: 0.05)
        let moveJumpAnimation = SKAction.moveTo(y: endingYPos, duration: 0.17)
        let lampLandAnimation = SKAction.animate(with: lampFrame2, timePerFrame: 0.05)
        let moveLandAnimation = SKAction.moveTo(y: startingYPos, duration: 0.17)
        
        let rightShift = SKAction.moveTo(x: self.frame.size.width / 2.25, duration: 5)
        let leftShift = SKAction.moveTo(x: -self.frame.size.width / 2.25, duration: 5)
        
        let action = SKAction.customAction(withDuration: 0.1, actionBlock: { (node: SKNode!, elapsedTime: CGFloat) -> Void in
            self.lampSprite.xScale *= -1
        })
        
        let jumpSequencer = SKAction.sequence([lampJumpAnimation, moveJumpAnimation, lampLandAnimation, moveLandAnimation])
        let shiftSequencer = SKAction.sequence([rightShift, action, leftShift, action])
        
        let lampAnimRepeater = SKAction.repeatForever(jumpSequencer)
        lampShift = SKAction.repeat(shiftSequencer, count: 1)
        
        lampSprite.position = CGPoint(x: -self.frame.size.width / 2.5, y: startingYPos)
        lampSprite.size = CGSize(width: lampSprite.size.width * (self.frame.size.width * 0.00025), height: lampSprite.size.height * (self.frame.size.width * 0.00025))
        lampSprite.name = "lamp"
        
        lampSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: lampSprite.size.width / 2, height: lampSprite.size.height))
        lampSprite.physicsBody?.affectedByGravity = false
        lampSprite.physicsBody?.categoryBitMask = ColliderType.lamp
        lampSprite.physicsBody?.contactTestBitMask = ColliderType.posI | ColliderType.negI
        lampSprite.physicsBody?.collisionBitMask = ColliderType.posI | ColliderType.negI
        lampSprite.physicsBody?.isDynamic = false
        
        lampSprite.zPosition = 3
        lampSprite.xScale = -1
        
        lampAnimation = lampAnimRepeater
        lampSprite.run(lampAnimRepeater, withKey: "lampanimation")
        //lampSprite.run(shiftRepeater)
        
        self.addChild(lampSprite)
    }
    
    @objc private func jumpLamp() -> Void {
        
        var startingYPos: CGFloat = 0
        var highYPos: CGFloat = 0
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
            startingYPos = -self.frame.size.height / 5.25
            highYPos = startingYPos + (self.frame.size.height / 3)
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            startingYPos = -self.frame.size.height / 4.5
            highYPos = startingYPos + (self.frame.size.height / 4.5)
        }
        
        if((currentJumpCount >= 1) && (!hasReturned)) {
            
            hasReturned = true
            let returnAnim = SKAction.moveTo(y: startingYPos, duration: 0.5)
            lampSprite.run(returnAnim, completion: resetJumpCount)
            return
        }
        
        if(currentJumpCount < 1) {
                        
            //lampSprite.removeAction(forKey: "lampanimation")
            let jumpAnim = SKAction.moveTo(y: highYPos, duration: 0.15)
            let landAnim = SKAction.moveTo(y: startingYPos, duration: 0.37)
            
            let jumpSeq = SKAction.sequence([jumpAnim, landAnim])
            
            let jumpRepeater = SKAction.repeat(jumpSeq, count: 1)
            
            lampSprite.run(jumpRepeater, completion: resumeAnimation)
            currentJumpCount += 1
        }
    }
    
    private func resetJumpCount() -> Void {
        
        hasReturned = true
        currentJumpCount = 0
    }
    
    private func resumeAnimation() {
        
        lampSprite.run(lampAnimation, withKey: "lampanimation")
        currentJumpCount = 0
        hasReturned = true
    }
    
    private func performCountdownTutorial() -> Void {
        
        pixelHand = SKSpriteNode(imageNamed: "pixel-hand")
        pixelHand.size = CGSize(width: pixelHand.size.width * (self.frame.size.width * 0.00013), height: pixelHand.size.height * (self.frame.size.width * 0.00013))
        
        pixelHand.position = CGPoint(x: lampSprite.position.x, y: lampSprite.position.y + 110)
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            pixelHand.size.width *= 1.1
            pixelHand.size.height *= 1.1
            pixelHand.position.y = lampSprite.position.y + 245
        }
        
        pixelHand.zPosition = 5
        
        tintedLamp = SKSpriteNode(imageNamed: "lamp5")
        tintedLamp.alpha = 0.5
        tintedLamp.size = CGSize(width: lampSprite.size.width, height: lampSprite.size.height)
        tintedLamp.position = CGPoint(x: lampSprite.position.x + 85, y: lampSprite.position.y + 75)
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            tintedLamp.position.x = lampSprite.position.x + 150
            tintedLamp.position.y = lampSprite.position.y + 150
        }
        
        tintedLamp.xScale = -1
        tintedLamp.zPosition = 5
        
        
        tapText = SKLabelNode(fontNamed: "KarmaticArcade")
        tapText.fontColor = .white
        tapText.fontSize = self.frame.size.width * 0.03
        tapText.text = "Tap!"
        tapText.position = CGPoint(x: lampSprite.position.x, y: lampSprite.position.y + 150)
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            tapText.position.y = lampSprite.position.y + 300
        }
        
        tapText.zPosition = 5
        
        countdownText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        countdownText.fontSize = self.frame.size.width * 0.05
        countdownText.text = "Get Ready!"
        countdownText.position = CGPoint(x: 0, y: self.frame.size.height / 12)
        
        countdownText.zPosition = 5
        
        self.addChild(countdownText)
        self.addChild(tapText)
        self.addChild(tintedLamp)
        self.addChild(pixelHand)
        
        //Filler Action
        
        let fillerAction = SKAction.resize(toWidth: tintedLamp.size.width, duration: 3)
        
        let fillerRepeater = SKAction.repeat(fillerAction, count: 1)
        
        tintedLamp.run(fillerRepeater, completion: showGoMessage)
    }
    
    private func performDieAnimation() {
        
        view?.gestureRecognizers?.removeAll()
        lampSprite.removeAllActions()
        
        let rotation = SKAction.rotate(byAngle: CGFloat.pi, duration: 0.25)
        let xShift = SKAction.move(to: CGPoint(x: -self.frame.size.width, y: self.frame.size.height), duration: 0.75)
        
        let rotationRepeater = SKAction.repeat(rotation, count: 1)
        let xShiftRepeater = SKAction.repeat(xShift, count: 1)
        
        lampSprite.run(rotationRepeater)
        lampSprite.run(xShiftRepeater, completion: showEndingScreen)
    }
    
    private func showEndingScreen() {
        
        scoreDisplay.removeFromParent()
        bestDisplay.removeFromParent()
        currentTexture.removeFromParent()
        lampSprite.removeFromParent()
        
        background.alpha = 0.5
        
        let gameOverText = SKLabelNode(fontNamed: "MinercraftoryRegular")
        gameOverText.fontSize = self.frame.size.width * 0.04
        gameOverText.position = CGPoint(x: 0, y: self.frame.size.height / 5.5)
        gameOverText.fontColor = .red
        gameOverText.text = "Game Over!"
        
        gameOverText.zPosition = 5
        
        let scoreHolder = SKShapeNode(rect: CGRect(x: -self.frame.size.width / 4.75, y: -self.frame.size.height / 3.75, width: self.frame.size.width * 0.4, height: self.frame.size.height * 0.4), cornerRadius: 10)
        scoreHolder.fillColor = UIColor.black
        scoreHolder.alpha = 0.55
        scoreHolder.strokeColor = .white
                
        scoreHolder.zPosition = 5
        
        let scoreText: SKLabelNode = SKLabelNode(fontNamed: "MinercraftoryRegular")
        scoreText.fontColor = .white
        scoreText.fontSize = self.frame.size.width * 0.0225
        scoreText.text = "Score: " + String(currentScore)
        scoreText.position = CGPoint(x: (scoreHolder.position.x + scoreHolder.frame.width) / 4, y: (scoreHolder.position.y - scoreHolder.frame.height) / 18)
        
        let highScoreText: SKLabelNode = SKLabelNode(fontNamed: "MinercraftoryRegular")
        highScoreText.fontSize = self.frame.size.width * 0.0225
        highScoreText.fontColor = .white
        highScoreText.text = "Best: " + String(savedData.highScore)
        highScoreText.position = CGPoint(x: (scoreHolder.position.x + scoreHolder.frame.width) / 3.55, y: (scoreHolder.position.y - scoreHolder.frame.height) / 5.75)
        
        scoreText.zPosition = 6
        highScoreText.zPosition = 6
        
        let replayButton: SKSpriteNode = SKSpriteNode(imageNamed: "gameoverreplay")
        replayButton.name = "replay"
        replayButton.size = CGSize(width: replayButton.size.width * (self.frame.size.width * 0.00035), height: replayButton.size.height * (self.frame.size.width * 0.00035))
        replayButton.position = CGPoint(x: -highScoreText.position.x * 0.85, y: highScoreText.position.y / 1.5)
        replayButton.isUserInteractionEnabled = false
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            replayButton.size = CGSize(width: replayButton.size.width * (self.frame.size.width * 0.0008), height: replayButton.size.height * (self.frame.size.width * 0.0008))
            replayButton.position = CGPoint(x: -highScoreText.position.x * 0.85, y: highScoreText.position.y / 1.5)
        }
        
        replayButton.zPosition = 6
        
        let shareButton: SKSpriteNode = SKSpriteNode(imageNamed: "tanpixelbutton")
        shareButton.name = "share"
        shareButton.size = CGSize(width: shareButton.size.width * (self.frame.size.width * 0.00035), height: shareButton.size.height * (self.frame.size.width * 0.00035))
        shareButton.position = CGPoint(x: replayButton.position.x, y: -self.frame.size.height / 4.25)
        shareButton.isUserInteractionEnabled = false
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            shareButton.size = CGSize(width: shareButton.size.width * (self.frame.size.width * 0.0008), height: shareButton.size.height * (self.frame.size.width * 0.0008))
            shareButton.position.y = -self.frame.size.height / 4.5
        }
        
        shareButton.zPosition = 6
        
        let replayText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        replayText.fontSize = self.frame.size.width * 0.0275
        replayText.fontColor = .white
        replayText.name = "replaytext"
        replayText.text = "Replay"
        
        let shareText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        shareText.fontSize = self.frame.size.width * 0.0275
        shareText.fontColor = .white
        shareText.name = "sharetext"
        shareText.text = "Share"
        
        replayText.zPosition = 7
        shareText.zPosition = 7
        
        replayButton.addChild(replayText)
        shareButton.addChild(shareText)
        
        replayText.position = CGPoint(x: 0, y: replayButton.size.height / 9)
        shareText.position = CGPoint(x: 0, y: replayButton.size.height / 9)
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            replayText.fontSize = self.frame.size.width * 0.0275
            shareText.fontSize = self.frame.size.width * 0.0275
            
            replayText.position = CGPoint(x: 0, y: replayButton.size.height / 9)
            shareText.position = CGPoint(x: 0, y: replayButton.size.height / 9)
        }
        
        self.addChild(replayButton)
        self.addChild(shareButton)
        
        self.addChild(highScoreText)
        self.addChild(scoreText)
        
        self.addChild(scoreHolder)
        self.addChild(gameOverText)
        
        highScoreText.position.y = -scoreHolder.frame.height / 2
        //highScoreText.position.x *= 1.2
        
    }
    
    private func showGoMessage() {
        
        countdownText.removeFromParent()
        pixelHand.removeFromParent()
        tintedLamp.removeFromParent()
        tapText.removeFromParent()
        
        let goText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        goText.fontSize = self.frame.size.width * 0.05
        goText.text = "Go!"
        goText.position = CGPoint(x: 0, y: self.frame.size.height / 12)
        
        goText.zPosition = 6
        
        self.addChild(goText)
        
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        
        goText.run(fadeOut, completion: startGame)
    }
    
    private func initScore() {
        
        scoreDisplay = SKLabelNode(fontNamed: "BitPap")
        scoreDisplay.fontColor = .black
        scoreDisplay.alpha = 0.5
        scoreDisplay.fontSize = self.frame.size.width * 0.15
        scoreDisplay.text = String(currentScore)
        scoreDisplay.position = CGPoint(x: 0, y: 0)
        
        scoreDisplay.zPosition = 5
        
        bestDisplay = SKLabelNode(fontNamed: "BitPap")
        bestDisplay.fontColor = .black
        bestDisplay.alpha = 0.5
        bestDisplay.fontSize = self.frame.size.width * 0.03
        bestDisplay.text = "Best: " + String(savedData.highScore)
        bestDisplay.position.x = scoreDisplay.position.x + 2
        bestDisplay.position.y = scoreDisplay.position.y - (self.frame.size.width / 24)
        
        bestDisplay.zPosition = 5
        
        self.addChild(scoreDisplay)
        self.addChild(bestDisplay)
    }
    
    private func drawLetterI() {
                        
        var IPos: CGFloat = 0
        var badYPos: CGFloat = 0
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
            IPos = -self.frame.size.height / 3.25
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            IPos = -self.frame.size.height / 3.25
        }
        
        if(currentScore < 20) {
            
            currentTexture = SKSpriteNode(texture: ISprites[0].texture)
        }
        else {
            let random: Int = Int.random(in: 0 ..< ISprites.count)
            currentTexture = SKSpriteNode(texture: ISprites[random].texture)
        }
        
        currentTexture.size = CGSize(width: currentTexture.size.width * (self.frame.size.width * 0.0004), height: currentTexture.size.height * (self.frame.size.width * 0.0004))
        textureSize = currentTexture.size
        badYPos = 22
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            currentTexture.size = CGSize(width: currentTexture.size.width * (self.frame.size.width * 0.0009), height: currentTexture.size.height * (self.frame.size.width * 0.0009))
            textureSize = currentTexture.size
            badYPos = 30
        }
        
        currentTexture.position.x = CGFloat.random(in: -self.frame.size.width / 15 ... self.frame.size.width / 15)
        currentTexture.position.y = IPos
        currentTexture.name = "badI"
        currentTexture.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        currentTexture.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: currentTexture.size.width * 0.85, height: currentTexture.size.height), center: CGPoint(x: 0, y: badYPos))
        currentTexture.physicsBody?.affectedByGravity = false
        currentTexture.physicsBody?.categoryBitMask = ColliderType.negI
        currentTexture.physicsBody?.collisionBitMask = ColliderType.lamp
        currentTexture.physicsBody?.contactTestBitMask = ColliderType.lamp
        currentTexture.physicsBody?.isDynamic = true
        
        currentTexture.zPosition = 5
                
        fillerNode = SKSpriteNode(imageNamed: "letteri")
        fillerNode.name = "goodI"
        fillerNode.size = CGSize(width: fillerNode.size.width * (self.frame.size.width * 0.0001), height: fillerNode.size.height * (self.frame.size.width * 0.0001))
        fillerNode.position.x = currentTexture.position.x
        fillerNode.position.y = currentTexture.position.y + (4 * fillerNode.size.height)
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            fillerNode.position.y = currentTexture.position.y + (4.5 * fillerNode.size.height)
        }
        fillerNode.alpha = 0.0
        
        fillerNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: currentTexture.size.width * 0.55, height: currentTexture.size.height / 6), center: CGPoint(x: 0, y: 0))
        fillerNode.physicsBody?.affectedByGravity = false
        fillerNode.physicsBody?.categoryBitMask = ColliderType.posI
        fillerNode.physicsBody?.collisionBitMask = ColliderType.lamp
        fillerNode.physicsBody?.contactTestBitMask = ColliderType.lamp
        fillerNode.physicsBody?.isDynamic = true
        
        fillerNode.zPosition = 5
        
        self.addChild(fillerNode)
        self.addChild(currentTexture)
    }
    
    private func startGame() {
        
        moveRight()
        initScore()
    }
    
    private func moveLeft() {
        
        if(currentTexture.size.height == 0) {
            
            drawLetterI()
        }
        else {
            performDieAnimation()
        }
        
        if(currentSpeed > 1.75) {
            
            currentSpeed *= 0.97
        }
        else {
            currentSpeed = 1.75
        }
    
        iterationCount += 1
        
        lampSprite.xScale = 1
        
        let rightShift = SKAction.moveTo(x: -self.frame.size.width / 2.25, duration: TimeInterval(currentSpeed))
        
        let shiftRepeater = SKAction.repeat(rightShift, count: 1)
        
        lampSprite.run(shiftRepeater, completion: moveRight)
    }
    
    private func moveRight() {
        
        if(currentTexture.size.height == textureSize.height) {
            
            if(iterationCount == 0) {
                
                drawLetterI()
            }
            else {
                
                performDieAnimation()
            }
        }
        else {
            drawLetterI()
        }
        
        if(currentSpeed > 1.75) {
            
            currentSpeed *= 0.97
        }
        else {
            currentSpeed = 1.75
        }
        
        lampSprite.xScale = -1
        
        let leftShift = SKAction.moveTo(x: self.frame.size.width / 2.25, duration: TimeInterval(currentSpeed))
                
        let shiftRepeater = SKAction.repeat(leftShift, count: 1)
        
        lampSprite.run(shiftRepeater, completion: moveLeft)
    }
    
    private func makeLampTangible() {
        
        if(currentScore > savedData.highScore) {
            
            savedData.highScore = currentScore
            GameScene.defaults.setValue(currentScore, forKey: "highscore")
        }
        
        currentTexture.removeFromParent()
        fillerNode.removeFromParent()
        
        lampSprite.physicsBody?.isDynamic = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
        
        let location = touch.previousLocation(in: self)
        let node = self.nodes(at: location).first
        
        if((node?.name == "replay") || (node?.name == "replaytext"))
        {
            resetModifiers()
            cleanUp()
            initializeGame()
        }
        if((node?.name == "share") || (node?.name == "sharetext")) {
            
            shareApp()
        }
      }
    }
    
    private func shareApp() {
        
        let message = "I just scored " + String(currentScore) + " points in this app, Lamp Tramper! You should check it out!"
        
        if let urlStr = NSURL(string: "https://apps.apple.com/us/app/lamp-tramper/id1543774316") {
            let objectsToShare = [message, urlStr] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popup = activityVC.popoverPresentationController {
                    popup.sourceView = self.view
                    popup.sourceRect = CGRect(x: (self.view?.frame.size.width)! / 2, y: (self.view?.frame.size.height)! / 4, width: 0, height: 0)
                }
            }

            mainViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func playSmushSound() {
        
        let smushSounds: [String] = ["smush1", "smush2", "smush3"]
        let rand = Int.random(in: 0 ..< smushSounds.count)
        let url = Bundle.main.url(forResource: smushSounds[rand], withExtension: "mp3")!

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = audioPlayer else { return }

            player.prepareToPlay()
            player.play()

        } catch let error as NSError {
            print(error.description)
        }
    }
    

    func cleanUp() {
        
        for child in self.children {
            
            child.removeAllActions()
            child.removeFromParent()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        if(((nodeA?.name == "lamp") && (nodeB?.name == "badI")) || ((nodeA?.name == "badI") && (nodeB?.name == "lamp")))
        {
            gameIsOver = true
            fillerNode.removeFromParent()
            performDieAnimation()
        }
                
        else if(((nodeA?.name == "lamp") && (nodeB?.name == "goodI")) || ((nodeA?.name == "goodI") && (nodeB?.name == "lamp")))
        {
            if(gameIsOver) {
                
                return
            }
            
            playSmushSound()
            lampSprite.physicsBody?.isDynamic = false
            currentTexture.physicsBody?.isDynamic = false
            let resizeI = SKAction.resize(toHeight: 0, duration: 0.25)
            let fillerAction = SKAction.resize(toWidth: lampSprite.size.width, duration: 0.5)
            currentScore += 1
            scoreDisplay.text = String(currentScore)
            
            if(currentScore > savedData.highScore) {
                
                bestDisplay.text = "Best: " + String(currentScore)
                
                if((mainViewController?.authPlayer()) != nil) {
                    mainViewController?.saveHighscore(number: currentScore)
                }
            }
            
            currentTexture.run(resizeI)
            currentTexture.run(fillerAction, completion: makeLampTangible)
        }
    }
}
