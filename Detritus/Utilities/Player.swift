//
//  Player.swift
//  Detritus
//
//  Created by Wesley Espinoza on 12/2/19.
//  Copyright © 2019 HazeWritesCode. All rights reserved.
//

import Foundation
import SpriteKit

enum playerElement: CaseIterable, CustomStringConvertible {
    case Air, Earth, Fire, Water
    var description: String  {
        switch self {
        case .Water:
            return "Water"
        case .Earth:
            return "Earth"
        case .Fire:
            return "Fire"
        case .Air:
            return "Air"
        }
    }
    
    var color: UIColor {
        switch self {
        case .Water:
            return UIColor.systemBlue
        case .Earth:
            return UIColor.systemGreen
        case .Fire:
            return UIColor.systemRed
        case .Air:
            return UIColor.systemTeal
        }
    }
}

class Player: SKSpriteNode{
    let userDefault = UserDefaults.standard
    let charArr: [playerElement] = [.Air, .Earth, .Fire, .Water].shuffled()
    var healthIndicator: SKSpriteNode!
    var playerLvlLabel: SKLabelNode!
    let maxHealth: Int = 3
    var currentHealth: Int = 3{
        didSet{
            healthIndicator.texture = SKTexture(imageNamed: "Hearts-\(self.currentHealth)")
        }
    }
    var currentChar: Int = 0 {
        didSet {
            if self.currentChar >= 4{
                self.currentChar = 0
            }
            currentElement = charArr[self.currentChar]
            changeLabelToCorrectchar(currentElement)
        }
    }
    
    var waterLvl = 1 {
        didSet{
            self.waterAnimatedAtlas = SKTextureAtlas(named: "Water\(self.waterLvl)")
            self.waterWalkingFrames = self.buildFrames(atlas: self.waterAnimatedAtlas, .Water)
            self.removeAllActions()
            self.animatePlayer()
            self.playerLvlLabel.text = "\(self.waterLvl)"
            userDefault.set(self.waterLvl, forKey: "WaterLvl")
        }
    }
    var earthLvl = 1 {
        didSet{
            self.earthAnimatedAtlas = SKTextureAtlas(named: "Earth\(self.earthLvl)")
            self.earthWalkingFrames = self.buildFrames(atlas: self.earthAnimatedAtlas, .Earth)
            self.removeAllActions()
            self.animatePlayer()
            self.playerLvlLabel.text = "\(self.earthLvl)"
            userDefault.set(self.earthLvl, forKey: "EarthLvl")
        }
    }
    var fireLvl = 1 {
        didSet{
            self.fireAnimatedAtlas = SKTextureAtlas(named: "Fire\(self.fireLvl)")
            self.fireWalkingFrames = self.buildFrames(atlas: self.fireAnimatedAtlas, .Fire)
            self.removeAllActions()
            self.animatePlayer()
            self.playerLvlLabel.text = "\(self.fireLvl)"
            userDefault.set(self.fireLvl, forKey: "FireLvl")
        }
    }
    var airLvl = 1 {
        didSet{
            self.airAnimatedAtlas = SKTextureAtlas(named: "Air\(self.airLvl)")
            self.airWalkingFrames = self.buildFrames(atlas: self.airAnimatedAtlas, .Air)
            self.removeAllActions()
            self.animatePlayer()
            self.playerLvlLabel.text = "\(self.airLvl)"
            userDefault.set(self.airLvl, forKey: "AirLvl")
        }
    }
    
    var waterAnimatedAtlas = SKTextureAtlas(named: "Water1")
    var earthAnimatedAtlas = SKTextureAtlas(named: "Earth1")
    var fireAnimatedAtlas = SKTextureAtlas(named: "Fire1")
    var airAnimatedAtlas = SKTextureAtlas(named: "Air1")
    
    private var waterWalkingFrames: [SKTexture] = []
    private var earthWalkingFrames: [SKTexture] = []
    private var fireWalkingFrames: [SKTexture] = []
    private var airWalkingFrames: [SKTexture] = []
    
    
    var currentElement: playerElement = .Air {
        didSet{
            animatePlayer()
        }
    }
    func initBody(){
        
        self.waterWalkingFrames = self.buildFrames(atlas: self.waterAnimatedAtlas, .Water)
        self.earthWalkingFrames = self.buildFrames(atlas: self.earthAnimatedAtlas, .Earth)
        self.fireWalkingFrames = self.buildFrames(atlas: self.fireAnimatedAtlas, .Fire)
        self.airWalkingFrames = self.buildFrames(atlas: self.airAnimatedAtlas, .Air)
        
        if self.userDefault.checkIfKey(key: "WaterLvl") {
            self.waterLvl = self.userDefault.integer(forKey: "WaterLvl")
        }
        if self.userDefault.checkIfKey(key: "EarthLvl") {
            self.earthLvl = self.userDefault.integer(forKey: "EarthLvl")
        }
        if self.userDefault.checkIfKey(key: "FireLvl") {
            self.fireLvl = self.userDefault.integer(forKey: "FireLvl")
        }
        if self.userDefault.checkIfKey(key: "AirLvl") {
            self.airLvl = self.userDefault.integer(forKey: "AirLvl")
        }
        
        currentChar = Int.random(in: 1...3)
        
    }
    
    
    func changeLabelToCorrectchar(_ currentElement: playerElement){
        switch currentElement {
        case .Water:
            self.playerLvlLabel.text = "\(waterLvl)"
        case .Earth:
            self.playerLvlLabel.text = "\(earthLvl)"
        case .Fire:
            self.playerLvlLabel.text = "\(fireLvl)"
        case .Air:
            self.playerLvlLabel.text = "\(airLvl)"
        }
    }
    
    func animatePlayer(){
        
        switch currentElement {
        case .Air:
            self.color = .systemTeal
            scalePlayer(airLvl)
            self.run(SKAction.repeatForever(
                SKAction.animate(with: airWalkingFrames,
                                 timePerFrame: 0.1,
                                 resize: false,
                                 restore: true)),
                     withKey:"airWalkingFrames")
        case .Earth:
            self.color = .systemGreen
            scalePlayer(1)
            self.run(SKAction.repeatForever(
                SKAction.animate(with: earthWalkingFrames,
                                 timePerFrame: 0.1,
                                 resize: false,
                                 restore: true)),
                     withKey:"earthWalkingFrames")
        case .Fire:
            self.color = .systemRed
            scalePlayer(1)
            self.run(SKAction.repeatForever(
                SKAction.animate(with: fireWalkingFrames,
                                 timePerFrame: 0.1,
                                 resize: false,
                                 restore: true)),
                     withKey:"fireWalkingFrames")
            
        case .Water:
            self.color = .systemBlue
            scalePlayer(1)
            self.run(SKAction.repeatForever(
                SKAction.animate(with: waterWalkingFrames,
                                 timePerFrame: 0.1,
                                 resize: false,
                                 restore: true)),
                     withKey:"waterWalkingFrames")
        }
        
    }
    
    func scalePlayer(_ value: Int){
        switch value {
        case 3:
            self.xScale = 1.1
            playerPhysicsBody(30)
        case 4:
            self.xScale = 1.2
            playerPhysicsBody(30)
        case 5:
            self.xScale = 1.3
            playerPhysicsBody(25)
        case 6:
            self.xScale = 1.4
            playerPhysicsBody(20)
        case 7:
            self.xScale = 1.5
            playerPhysicsBody(23)
        case 8:
            self.xScale = 1.6
            playerPhysicsBody(25)
        case 9:
            self.xScale = 1.7
            playerPhysicsBody(25)
        case 10:
            self.xScale = 1.8
            playerPhysicsBody(25)
        default:
            self.xScale = 1
            playerPhysicsBody(35)
        }
    }
    
    
    func playerPhysicsBody( _ w: Int){
        self.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: w - 15, height: 110))
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Ground
        self.physicsBody?.categoryBitMask = PhysicsCategory.Player
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.zPosition = 20
    }
    
    func buildFrames(atlas: SKTextureAtlas, _ element: playerElement) -> Array<SKTexture>{
        var walkFrames: [SKTexture] = []
        
        let numImages = atlas.textureNames.count - 1
        switch element {
        case .Air:
            for i in 0...numImages {
                let textureName = "\(element.description)\(airLvl)-\(i)"
                walkFrames.append(atlas.textureNamed(textureName))
            }
            return walkFrames
        case .Earth:
            for i in 0...numImages {
                let textureName = "\(element.description)\(earthLvl)-\(i)"
                walkFrames.append(atlas.textureNamed(textureName))
            }
            return walkFrames
        case .Fire:
            for i in 0...numImages {
                let textureName = "\(element.description)\(fireLvl)-\(i)"
                walkFrames.append(atlas.textureNamed(textureName))
            }
            return walkFrames
            
        case .Water:
            for i in 0...numImages {
                let textureName = "\(element.description)\(waterLvl)-\(i)"
                walkFrames.append(atlas.textureNamed(textureName))
            }
            return walkFrames
        }
        
    }
}
