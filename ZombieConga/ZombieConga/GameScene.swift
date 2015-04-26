//
//  GameScene.swift
//  ZombieConga
//
//  Created by peter on 4/26/15.
//  Copyright (c) 2015 peter. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.grayColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.zRotation = CGFloat(M_PI) / 8
        background.zPosition = -1
        addChild(background)
        let mySize = background.size
        println("Size: \(mySize)")
        
    }
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
