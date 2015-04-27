//
//  GameScene.swift
//  ZombieConga
//
//  Created by peter on 4/26/15.
//  Copyright (c) 2015 peter. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let zombie: SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPointZero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
            width: size.width,
            height: playableHeight) // 4
        super.init(size: size) // 5
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.grayColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
       // background.zRotation = CGFloat(M_PI) / 8
        //background.zPosition = -1
        addChild(background)
        let mySize = background.size
        println("Size: \(mySize)")
        
        
        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        zombie.setScale(2.0) // SKNode method
        debugDrawPlayableArea()
        
    }
    
   
    override func update(currentTime: NSTimeInterval) {
    if lastUpdateTime > 0 {
        dt = currentTime - lastUpdateTime
    } else {
        dt = 0
    }
    lastUpdateTime = currentTime
    println("\(dt*1000) milliseconds since last update")
    
    if let lastTouch = lastTouchLocation {
        let diff = lastTouch - zombie.position
        if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
            zombie.position = lastTouchLocation!
            velocity = CGPointZero
        } else {
            moveSprite(zombie, velocity: velocity)
            rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }
    }
    
    boundsCheckZombie()
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
            // 1
//            let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
//            //println("Amount to move: \(amountToMove)") // 2
//            sprite.position = CGPoint(x: sprite.position.x + amountToMove.x,y: sprite.position.y + amountToMove.y)
            let amountToMove = velocity * CGFloat(dt)
            println("Amount to move: \(amountToMove)")
            sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - zombie.position.x,y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
    }
    
    
    func sceneTouched(touchLocation:CGPoint) {
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
            let touch = touches.first as! UITouch
            let touchLocation = touch.locationInNode(self)
            sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
            let touch = touches.first as! UITouch
            let touchLocation = touch.locationInNode(self)
            sceneTouched(touchLocation)
    }
    
    func boundsCheckZombie() {
//        let bottomLeft = CGPointZero
//        let topRight = CGPoint(x: size.width, y: size.height)
         
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
                
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x }
        
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
//    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
//        sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
//    }
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
            // Your code here!
            let shortest = shortestAngleBetween(sprite.zRotation, velocity.angle)
            let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
            sprite.zRotation += shortest.sign() * amountToRotate
    }
}
