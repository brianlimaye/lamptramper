//
//  GameScene.swift
//  lamptramper
//
//  Created by Brian Limaye on 12/19/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct ColliderType {
        
        static let lamp: UInt32 = 0
        static let posI: UInt32 = 1
        static let negI: UInt32 = 2
    }
    
    private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    var background: SKSpriteNode = SKSpriteNode()
    var platform: SKSpriteNode = SKSpriteNode()
    var lampSprite: SKSpriteNode = SKSpriteNode()
    var pixelHand: SKSpriteNode = SKSpriteNode()
    var tintedLamp: SKSpriteNode = SKSpriteNode()
    var tapText: SKLabelNode = SKLabelNode()
    var countdownText: SKLabelNode = SKLabelNode()
    var scoreDisplay: SKLabelNode = SKLabelNode()
    var ISprites: [SKSpriteNode] = [SKSpriteNode]()
    var currentTexture: SKSpriteNode = SKSpriteNode()
    var textureSize: CGSize = CGSize()
    var initialSize: CGSize = CGSize()
    var currentScore: Int = 0
    var currentJumpCount: Int = 0
    var hasReturned: Bool = true
    var isLanding: Bool = false
    
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
        
        currentScore = 0
        currentJumpCount = 0
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
        
        let action = SKAction.customAction(withDuration: 0.1, actionBlock: { (node: SKNode!, elapsedTime: CGFloat) -> Void in
            self.lampSprite.xScale *= -1
        })
        
        let jumpSequencer = SKAction.sequence([lampJumpAnimation, moveJumpAnimation, lampLandAnimation, moveLandAnimation])
        let shiftSequencer = SKAction.sequence([rightShift, action, leftShift, action])
        
        let lampAnimRepeater = SKAction.repeatForever(jumpSequencer)
        lampShift = SKAction.repeatForever(shiftSequencer)
        
        lampSprite.position = CGPoint(x: -self.frame.size.width / 2.5, y: startingYPos)
        lampSprite.size = CGSize(width: lampSprite.size.width * (self.frame.size.width * 0.00025), height: lampSprite.size.height * (self.frame.size.width * 0.00025))
        lampSprite.name = "lamp"
        
        lampSprite.physicsBody = SKPhysicsBody(circleOfRadius: lampSprite.size.width / 3.5)
        lampSprite.physicsBody?.affectedByGravity = false
        lampSprite.physicsBody?.categoryBitMask = ColliderType.lamp
        lampSprite.physicsBody?.contactTestBitMask = ColliderType.posI | ColliderType.negI
        lampSprite.physicsBody?.collisionBitMask = ColliderType.posI | ColliderType.negI
        lampSprite.physicsBody?.isDynamic = true
        
        lampSprite.zPosition = 3
        lampSprite.xScale = -1
        
        lampAnimation = lampAnimRepeater
        lampSprite.run(lampAnimRepeater, withKey: "lampanimation")
        //lampSprite.run(shiftRepeater)
        
        self.addChild(lampSprite)
    }
    
    @objc private func jumpLamp() -> Void {
        
        var startingYPos: CGFloat = 0
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
            startingYPos = -self.frame.size.height / 5.25
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            startingYPos = -self.frame.size.height / 4.5
        }
        
        if((currentJumpCount >= 1) && (!hasReturned)) {
            
            hasReturned = true
            let returnAnim = SKAction.moveTo(y: startingYPos, duration: 0.5)
            lampSprite.run(returnAnim, completion: resetJumpCount)
            return
        }
        
        if(currentJumpCount < 1) {
                        
            //lampSprite.removeAction(forKey: "lampanimation")
            let jumpAnim = SKAction.moveTo(y: lampSprite.position.y + (self.frame.size.height / 3), duration: 0.15)
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
        highScoreText.text = "Best: " + String(currentScore)
        highScoreText.position = CGPoint(x: (scoreHolder.position.x + scoreHolder.frame.width) / 3.57, y: (scoreHolder.position.y - scoreHolder.frame.height) / 5.75)
        
        scoreText.zPosition = 6
        highScoreText.zPosition = 6
        
        let replayButton: SKSpriteNode = SKSpriteNode(imageNamed: "gameoverreplay")
        replayButton.name = "replay"
        replayButton.size = CGSize(width: replayButton.size.width * (self.frame.size.width * 0.000375), height: replayButton.size.height * (self.frame.size.width * 0.000375))
        replayButton.position = CGPoint(x: -highScoreText.position.x * 0.85, y: highScoreText.position.y / 1.5)
        replayButton.isUserInteractionEnabled = false
        
        replayButton.zPosition = 6
        
        let boardButton: SKSpriteNode = SKSpriteNode(imageNamed: "gameoverboard")
        boardButton.name = "leaderboard"
        boardButton.size = CGSize(width: boardButton.size.width * (self.frame.size.width * 0.000275), height: boardButton.size.height * (self.frame.size.width * 0.000275))
        boardButton.position = CGPoint(x: replayButton.position.x / 1.5, y: highScoreText.position.y * 5)
        boardButton.isUserInteractionEnabled = false
        
        boardButton.zPosition = 6
        
        let replayText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        replayText.fontSize = self.frame.size.width * 0.0275
        replayText.fontColor = .white
        replayText.name = "replaytext"
        replayText.text = "Replay"
        
        let boardText = SKLabelNode(fontNamed: "HABESHAPIXELS-Bold")
        boardText.fontSize = self.frame.size.width * 0.0225
        boardText.fontColor = .white
        boardText.name = "boardtext"
        boardText.text = "Leaderboard"
        
        replayText.zPosition = 7
        boardText.zPosition = 7
        
        replayButton.addChild(replayText)
        boardButton.addChild(boardText)
        
        replayText.position = CGPoint(x: 0, y: replayButton.size.height / 9)
        boardText.position = CGPoint(x: -replayButton.size.width / 6.5, y: replayButton.size.height / 2.25)
        
        self.addChild(replayButton)
        self.addChild(boardButton)
        
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
        
        self.addChild(scoreDisplay)
    }
    
    private func drawLetterI() {
        
        print("drawing letter I...")
                
        var IPos: CGFloat = 0
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
            IPos = -self.frame.size.height / 3.25
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad) {
            
            IPos = -self.frame.size.height / 4.5
        }
        
        if(currentScore < 50) {
            
            currentTexture = SKSpriteNode(texture: ISprites[0].texture)
        }
        else {
            let random: Int = Int.random(in: 0 ..< ISprites.count)
            currentTexture = SKSpriteNode(texture: ISprites[random].texture)
        }
        
        currentTexture.size = CGSize(width: currentTexture.size.width * (self.frame.size.width * 0.0004), height: currentTexture.size.height * (self.frame.size.width * 0.0004))
        textureSize = currentTexture.size
        
        currentTexture.position.x = CGFloat.random(in: -self.frame.size.width / 3 ... self.frame.size.width / 3)
        currentTexture.position.y = IPos
        currentTexture.name = "badI"
        currentTexture.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        currentTexture.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: currentTexture.size.width * 0.85, height: currentTexture.size.height), center: CGPoint(x: 0, y: 22))
        currentTexture.physicsBody?.affectedByGravity = false
        currentTexture.physicsBody?.categoryBitMask = ColliderType.negI
        currentTexture.physicsBody?.collisionBitMask = ColliderType.lamp
        currentTexture.physicsBody?.contactTestBitMask = ColliderType.lamp
        currentTexture.physicsBody?.isDynamic = false
        
        currentTexture.zPosition = 5
        
        print(currentTexture.size.height)
        
        let fillerNode: SKSpriteNode = SKSpriteNode(imageNamed: "letteri")
        fillerNode.name = "goodI"
        fillerNode.size = CGSize(width: fillerNode.size.width * (self.frame.size.width * 0.0001), height: fillerNode.size.height * (self.frame.size.width * 0.0001))
        fillerNode.position.x = currentTexture.position.x
        fillerNode.position.y = currentTexture.position.y + (4 * fillerNode.size.height)
        fillerNode.alpha = 0.0
        
        fillerNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: currentTexture.size.width * 0.5, height: currentTexture.size.height / 6), center: CGPoint(x: 0, y: -5))
        fillerNode.physicsBody?.affectedByGravity = false
        fillerNode.physicsBody?.categoryBitMask = ColliderType.posI
        fillerNode.physicsBody?.collisionBitMask = ColliderType.lamp
        fillerNode.physicsBody?.contactTestBitMask = ColliderType.lamp
        fillerNode.physicsBody?.isDynamic = false
        
        fillerNode.zPosition = 5
        
        self.addChild(fillerNode)
        self.addChild(currentTexture)
    }
    
    private func startGame() {
        
        lampSprite.run(lampShift)
        initScore()
        drawLetterI()
    }
    private func makeLampTangible() {
        
        lampSprite.physicsBody?.isDynamic = true
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
        if((node?.name == "leaderboard") || (node?.name == "boardtext")) {
            
            print("leaderboard...")
        }
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
            performDieAnimation()
        }
                
        else if(((nodeA?.name == "lamp") && (nodeB?.name == "goodI")) || ((nodeA?.name == "goodI") && (nodeB?.name == "lamp")))
        {
            lampSprite.physicsBody?.isDynamic = false
            currentTexture.physicsBody?.isDynamic = false
            let resizeI = SKAction.resize(toHeight: 0, duration: 0.25)
            let fillerAction = SKAction.resize(toWidth: lampSprite.size.width, duration: 3)
            currentScore += 1
            scoreDisplay.text = String(currentScore)
            
            currentTexture.run(resizeI)
            currentTexture.run(fillerAction, completion: makeLampTangible)
        }
    }
}
