//
//  GameScene.swift
//  Detritus
//
//  Created by Wesley Espinoza on 11/5/19.
//  Copyright © 2019 HazeWritesCode. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PlayerSceneState {
    case jumping, idle, running, boosting
}
enum GameStates {
    case MainMenu, Active, Paused, GameOver
}

struct PhysicsCategory {
    static let None:      UInt32 = 0
    static let Player:      UInt32 = 0b1
    static let Trash:    UInt32 = 0b10
    static let Blade:    UInt32 = 0b100
    static let Ground: UInt32 = 0b1000
}


class MainGameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var playerWalkingFrames: [SKTexture] = []
    var trashSpawer: SKNode!
    var blade: SKNode!
    var ground: SKNode!
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 75
    var spawnTimer: CFTimeInterval = 0
    let moveSpeed = 25
    var gameState: GameStates = .MainMenu
    
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.contactDelegate = self
        setupNodes()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
    }
    
    func setupNodes(){
        
        player = self.childNode(withName: "player") as? SKSpriteNode
        player.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 55, height: 130))
        player.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Blade
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        player.zPosition = 20
        player.physicsBody?.mass = 0.25
        
        
        trashSpawer = self.childNode(withName: "trash")
        ground = self.childNode(withName: "ground")
        blade = self.childNode(withName: "blade")
        
        
        
        blade.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 200, height: 200))
        blade.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Trash
        blade.physicsBody?.categoryBitMask = PhysicsCategory.Blade
        blade.physicsBody?.isDynamic = true
        blade.physicsBody?.affectedByGravity = false
        blade.physicsBody?.allowsRotation = true
        animateBlade()
        blade.zPosition = 10
        
        
        ground.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 850, height: 350))
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.allowsRotation = false
        ground.zPosition = 9
    }
    
    func updateTrash() {
        
        if gameState == .Active{
            spawnTimer+=fixedDelta
            /* Time to add a new obstacle? */
            if spawnTimer >= 1.3 {
                /* Create a new obstacle by copying the source obstacle */
                let newTrash = trashSpawer.copy() as! SKNode
                
                newTrash.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: 75, height: 75))
                newTrash.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Player
                newTrash.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Blade | PhysicsCategory.Player
                newTrash.physicsBody?.categoryBitMask = PhysicsCategory.Trash
                newTrash.physicsBody?.isDynamic = true
                newTrash.physicsBody?.affectedByGravity = true
                newTrash.physicsBody?.allowsRotation = true
                newTrash.zPosition = 15
                self.addChild(newTrash)
                /* Generate new obstacle position, start just outside screen and with a random y value */
                let randomPosition = CGPoint(x: CGFloat.random(in: 5..<(scene?.size.width)!), y: trashSpawer.position.y)
                /* Convert new node position back to scene space */
                newTrash.position = self.convert(randomPosition, to: self)
                // Reset spawn timer
                spawnTimer = 0
            }
        }
    }
    
    
    func animateBlade(){
        let spinAnimation = SKAction.repeatForever(SKAction.rotate(byAngle: 25, duration: 1))
        blade.run(spinAnimation)
    }
    
    
    
}
