//
//  GameScene.swift
//  Detritus
//
//  Created by Wesley Espinoza on 11/5/19.
//  Copyright © 2019 HazeWritesCode. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

enum PlayerSceneState {
    case jumping, running
}

enum GameStates {
    case MainMenu, Active, Paused, GameOver
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Obstacle: UInt32 = 0b10
    static let Ground: UInt32 = 0b100
    static let Coin: UInt32 = 0b1000
    static let Barrier: UInt32 = 0b0000
}


class MainGameScene: SKScene, SKPhysicsContactDelegate {
    var player: Player = Player()
    var ground: SKNode!
    var scrollLayer: SKNode!
    var coinSpawner: SKSpriteNode!
    var coinLabel: SKLabelNode!
    var obstacleSpawner: SKSpriteNode!
    var boundBarrier: SKNode!
    var playButton: ButtonNode!
    var changeButtonOne: ButtonNode!
    var changeButtonTwo: ButtonNode!
    var changeButtonThree: ButtonNode!
    var changeButtonFour: ButtonNode!
    var upgradeButton: ButtonNode!
    var airBAnimatedAtlas = SKTextureAtlas(named: "AirBarrier")
    var airBAnimFrames: [SKTexture] = []
    var waterBAnimatedAtlas = SKTextureAtlas(named: "WaterBarrier")
    var waterBAnimFrames: [SKTexture] = []
    var fireBAnimatedAtlas = SKTextureAtlas(named: "FireBarrier")
    var fireBAnimFrames: [SKTexture] = []
    var earthBAnimatedAtlas = SKTextureAtlas(named: "EarthBarrier")
    var earthBAnimFrames: [SKTexture] = []
    var coinAnimatedAtlas = SKTextureAtlas(named: "Coin")
    var coinAnimFrames: [SKTexture] = []
    let moveSpeed = 25
    var gameState: GameStates = .MainMenu
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var spawnerFixedDelta: Double = 1
    var scrollSpeed: CGFloat = 25
    var spawnTimer: CFTimeInterval = 0
    let colorArr: [UIColor] = [.systemTeal, .systemBlue, .systemGreen, .systemRed]
    var scoreLabel: SKLabelNode!
    var highScorelabel: SKLabelNode!
    let userDefault = UserDefaults.standard
    var highScore: Int = 0
    let generator = UIImpactFeedbackGenerator(style: .light)
    var coins: Int = 0 {
        didSet{
            self.userDefault.set(self.coins, forKey: "Coins")
            self.coinLabel.text = "\(self.coins)"
        }
    }
    var currentScore = 0{
        didSet{
            scoreLabel.text = "\(self.currentScore)"
        }
    }
    
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.contactDelegate = self
        setupNodes()
        if userDefault.checkIfKey(key: "HighScore") {
            highScorelabel.text = "Highscore: \(userDefault.integer(forKey: "HighScore"))"
        } else {
            userDefault.set(0, forKey: "HighScore")
        }
        
        if userDefault.checkIfKey(key: "Coins"){
            coins = userDefault.integer(forKey: "Coins")
        } else {
            userDefault.set(0, forKey: "Coins")
            coins = 0
        }
        
        
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        generator.prepare()
        player.animatePlayer()
        animateCoin()
    }
    
    func animateCoin(){
        self.coinSpawner.run(SKAction.repeatForever(
        SKAction.animate(with: coinAnimFrames,
                         timePerFrame: 0.1,
                         resize: false,
                         restore: true)),
             withKey:"coinFrames")
    }
    
    
    func setupNodes(){
        createBarrierAnimFrames()
        
        physicsWorld.contactDelegate = self
        
        let playerNode: Player = self.childNode(withName: "player") as! Player
        //make the declared variable equal to somePlayer
        player = playerNode
        player.healthIndicator = self.childNode(withName: "hearts") as? SKSpriteNode
        player.playerLvlLabel = self.childNode(withName: "playerLvlLabel") as? SKLabelNode
        player.initBody()

        
        coinLabel = self.childNode(withName: "coinLabel") as? SKLabelNode
        coinSpawner = self.childNode(withName: "coin") as? SKSpriteNode
        upgradeButton = self.childNode(withName: "upgradeButton") as? ButtonNode
        upgradeButton.selectedHandler = {
            switch self.player.currentElement {
            case .Water:
                if self.player.waterLvl < 10 {
                    if self.coins > 0 {
                        self.player.waterLvl += 1
                        self.coins -= 1
                    }
                    
                }
            case .Earth:
                if self.player.earthLvl < 10 {
                    if self.coins > 0{
                        self.player.earthLvl += 1
                        self.coins -= 1
                    }
                    
                }
            case .Fire:
                if self.player.fireLvl < 10 {
                    if self.coins > 0 {
                        self.player.fireLvl += 1
                        self.coins -= 1
                    }
                    
                }
            case .Air:
                if self.player.airLvl < 10 {
                    if self.coins > 0 {
                        self.player.airLvl += 1
                        self.coins -= 1
                    }
                }
            }
        }
        
        boundBarrier = self.childNode(withName: "boundBarrier")
        boundBarrier.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 4, height: 655))
        boundBarrier.physicsBody?.categoryBitMask = PhysicsCategory.Barrier
        boundBarrier.physicsBody?.isDynamic = false
        boundBarrier.physicsBody?.affectedByGravity = false
        boundBarrier.physicsBody?.allowsRotation = false
        boundBarrier.zPosition = 9
        
        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        highScorelabel = self.childNode(withName: "highScoreLabel") as? SKLabelNode
        playButton = self.childNode(withName: "playButton") as? ButtonNode
        playButton.selectedHandler = {
            self.playButton.isHidden = true
            self.gameState = .Active
            self.currentScore = 0
            self.player.currentHealth = self.player.maxHealth
            self.player.animatePlayer()
            self.player.playerLvlLabel.isHidden = true
            self.upgradeButton.isHidden = true
            self.highScorelabel.isHidden = true
            self.coinSpawner.isHidden = true
            self.coinLabel.isHidden = true
            self.hapticFeedBack()
        }
        
        changeButtonOne = self.childNode(withName: "changeButtonOne") as? ButtonNode
        changeButtonOne.selectedHandler = {
            self.player.currentChar = 0
            self.hapticFeedBack()
        }
        changeButtonTwo = self.childNode(withName: "changeButtonTwo") as? ButtonNode
        changeButtonTwo.selectedHandler = {
            self.player.currentChar = 1
            self.hapticFeedBack()
        }
        changeButtonThree = self.childNode(withName: "changeButtonThree") as? ButtonNode
        changeButtonThree.selectedHandler = {
            self.player.currentChar = 2
            self.hapticFeedBack()
        }
        changeButtonFour = self.childNode(withName: "changeButtonFour") as? ButtonNode
        changeButtonFour.selectedHandler = {
            self.player.currentChar = 3
           self.hapticFeedBack()
        }
        
        
        ground = self.childNode(withName: "ground")
        ground.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 430, height: 2))
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.allowsRotation = false
        ground.zPosition = 9
        
        
        for elements in player.charArr {
            if changeButtonOne.hasSet == false {
                changeButtonOne.color = elements.color
                changeButtonOne.hasSet = true
                continue
            }
            if changeButtonTwo.hasSet == false {
                changeButtonTwo.color = elements.color
                changeButtonTwo.hasSet = true
                continue
            }
            if changeButtonThree.hasSet == false {
                changeButtonThree.color = elements.color
                changeButtonThree.hasSet = true
                continue
            }
            if changeButtonFour.hasSet == false {
                changeButtonFour.color = elements.color
                changeButtonFour.hasSet = true
                continue
            }
        }
        
        
        obstacleSpawner = self.childNode(withName: "obstacleSpawner") as? SKSpriteNode
    }
    
    func hapticFeedBack(){
        generator.impactOccurred()
    }
    
    
    func createBarrierAnimFrames(){
        var airTempArr: [SKTexture] = []
        var fireTempArr: [SKTexture] = []
        var earthTempArr: [SKTexture] = []
        var waterTempArr: [SKTexture] = []
        var coinTempArr: [SKTexture] = []
        
        for i in 0...airBAnimatedAtlas.textureNames.count - 1 {
            let textureName = "AirBarrier-\(i)"
            airTempArr.append(airBAnimatedAtlas.textureNamed(textureName))
        }
        
        for i in 0...fireBAnimatedAtlas.textureNames.count - 1 {
            let textureName = "FireBarrier-\(i)"
            fireTempArr.append(fireBAnimatedAtlas.textureNamed(textureName))
        }
        
        for i in 0...earthBAnimatedAtlas.textureNames.count - 1 {
            let textureName = "EarthBarrier-\(i)"
            earthTempArr.append(earthBAnimatedAtlas.textureNamed(textureName))
        }
        
        for i in 0...waterBAnimatedAtlas.textureNames.count - 1 {
            let textureName = "WaterBarrier-\(i)"
            waterTempArr.append(waterBAnimatedAtlas.textureNamed(textureName))
        }
        for i in 0...coinAnimatedAtlas.textureNames.count - 1 {
            let textureName = "coin-\(i)"
            coinTempArr.append(coinAnimatedAtlas.textureNamed(textureName))
        }
        
        coinAnimFrames = coinTempArr
        airBAnimFrames = airTempArr
        waterBAnimFrames = waterTempArr
        fireBAnimFrames = fireTempArr
        earthBAnimFrames = earthTempArr
    }
    
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyB.categoryBitMask == PhysicsCategory.Obstacle && bodyA.categoryBitMask == PhysicsCategory.Player{
            let obstacle = bodyB.node as! SKSpriteNode
            let player = bodyA.node as! Player
            if obstacle.color != player.color{
                player.currentHealth -= 1
                if player.currentHealth == 0{
                    gameOver()
                }
            } else {
                self.currentScore += 1
            }
        }
        
        if bodyB.categoryBitMask == PhysicsCategory.Coin && bodyA.categoryBitMask == PhysicsCategory.Player{
            bodyB.node?.removeFromParent()
            self.coins += 1
            } else if bodyA.categoryBitMask == PhysicsCategory.Coin && bodyB.categoryBitMask == PhysicsCategory.Player{
                bodyA.node?.removeFromParent()
            self.coins += 1
            }
        
        
        if bodyA.categoryBitMask == PhysicsCategory.Barrier {
            bodyB.node?.removeFromParent()
        }
        
        if bodyB.categoryBitMask == PhysicsCategory.Barrier{
            bodyA.node?.removeFromParent()
        }
    }
    
    func gameOver(){
        self.gameState = .GameOver
        for child in self.children{
            if child.name == "Obstacle"{
                child.removeFromParent()
            }
        }
        if userDefault.checkIfKey(key: "HighScore"){
            if currentScore > userDefault.integer(forKey: "HighScore"){
                userDefault.set(currentScore, forKey: "HighScore")
                highScore = currentScore
                highScorelabel.text = "Highscore: \(String(describing: highScore))"
            }
        }

        
        self.player.playerLvlLabel.isHidden = false
        self.upgradeButton.isHidden = false
        self.playButton.isHidden = false
        self.highScorelabel.isHidden = false
        self.coinSpawner.isHidden = false
        self.coinLabel.isHidden = false
    }
    
    
    func updateObtacle() {
        
        if gameState == .Active{
            /* Time to add a new obstacle? */
            
            if spawnTimer >= spawnerFixedDelta {
                /* Create a new obstacle by copying the source obstacle */
                
                let randomNumber = Int.random(in: 0...420)
                if randomNumber == 42 {
                    let newCoin = coinSpawner.copy() as! SKSpriteNode
                    newCoin.isHidden = false
                    newCoin.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 28.5, height: 33))
                    newCoin.physicsBody?.affectedByGravity = true
                    newCoin.physicsBody?.isDynamic = true
                    newCoin.physicsBody?.allowsRotation = true
                    newCoin.physicsBody?.categoryBitMask = PhysicsCategory.Coin
                    newCoin.physicsBody?.contactTestBitMask = PhysicsCategory.Player
                    newCoin.physicsBody?.collisionBitMask = PhysicsCategory.Ground
                    
                    self.addChild(newCoin)
                    newCoin.run(SKAction.repeatForever(SKAction.applyImpulse(CGVector(dx: -25, dy: 0), duration: 0.1)))
                }
                let newObstacle = obstacleSpawner.copy() as! SKSpriteNode
                let color = colorArr.randomElement()!
                newObstacle.color = color
                newObstacle.physicsBody?.affectedByGravity = false
                newObstacle.physicsBody?.isDynamic = true
                newObstacle.physicsBody?.allowsRotation = false
                newObstacle.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
                newObstacle.physicsBody?.contactTestBitMask = PhysicsCategory.Player
                newObstacle.physicsBody?.collisionBitMask = PhysicsCategory.None
                newObstacle.name = "Obstacle"
                self.addChild(newObstacle)
                switch color {
                case .systemBlue:
                    newObstacle.run(SKAction.repeatForever(
                        SKAction.animate(with: waterBAnimFrames,
                                         timePerFrame: 0.1,
                                         resize: false,
                                         restore: true)),
                                    withKey:"animFrames")
                case .systemTeal:
                    newObstacle.run(SKAction.repeatForever(
                        SKAction.animate(with: airBAnimFrames,
                                         timePerFrame: 0.1,
                                         resize: false,
                                         restore: true)),
                                    withKey:"animFrames")
                case .systemGreen:
                    newObstacle.run(SKAction.repeatForever(
                        SKAction.animate(with: earthBAnimFrames,
                                         timePerFrame: 0.1,
                                         resize: false,
                                         restore: true)),
                                    withKey:"animFrames")
                case .systemRed:
                    newObstacle.run(SKAction.repeatForever(
                        SKAction.animate(with: fireBAnimFrames,
                                         timePerFrame: 0.1,
                                         resize: false,
                                         restore: true)),
                                    withKey:"animFrames")
                default:
                    print("No Color config")
                }
                /* Generate new obstacle position, start just outside screen and with a random y value */
                let randomPosition = obstacleSpawner.position
                newObstacle.run(SKAction.repeatForever(SKAction.moveBy(x: -10, y: 0, duration: 0.1)))
                
                /* Convert new node position back to scene space */
                newObstacle.position = self.convert(randomPosition, to: self)
                // Reset spawn timer
                spawnTimer = Double.random(in: 0...0.4)
            }
            spawnTimer+=fixedDelta
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateObtacle()
        
    }
    
    
}
