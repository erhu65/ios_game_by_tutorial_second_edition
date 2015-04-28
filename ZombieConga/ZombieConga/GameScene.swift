/*
 * Copyright (c) 2013-2014 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
  let zombieAnimation: SKAction
    
   let catCollisionSound: SKAction = SKAction.playSoundFileNamed( "hitCat.wav", waitForCompletion: false)
   let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed( "hitCatLady.wav", waitForCompletion: false)
    
    
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0 // 1
    let playableHeight = size.width / maxAspectRatio // 2
    let playableMargin = (size.height-playableHeight)/2.0 // 3
    playableRect = CGRect(x: 0, y: playableMargin, 
                          width: size.width,
                          height: playableHeight) // 4
    
    // 1
    var textures:[SKTexture] = []
    // 2
    for i in 1...4 {
        textures.append(SKTexture(imageNamed: "zombie\(i)")) }
    // 3
    textures.append(textures[2])
    textures.append(textures[1])
    // 4
    zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
    
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
    backgroundColor = SKColor.whiteColor()
  
    let background = SKSpriteNode(imageNamed: "background1")
    background.position = CGPoint(x: size.width/2, y: size.height/2)
    background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
    //background.zRotation = CGFloat(M_PI) / 8
    background.zPosition = -1
    addChild(background)
  
    let mySize = background.size
    println("Size: \(mySize)")
    
    zombie.position = CGPoint(x: 400, y: 400)
    addChild(zombie)
    //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        
    //zombie.setScale(2.0) // SKNode method
    debugDrawPlayableArea()
    //spawnEnemy()
    runAction(SKAction.repeatActionForever( SKAction.sequence([SKAction.runBlock(spawnEnemy),
        SKAction.waitForDuration(2.0)])))
    
    runAction(SKAction.repeatActionForever( SKAction.sequence([SKAction.runBlock(spawnCat),
        SKAction.waitForDuration(1.0)])))
        
  }
  
  override func update(currentTime: NSTimeInterval) {
  
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
    //println("\(dt*1000) milliseconds since last update")

    if let lastTouch = lastTouchLocation {
      let diff = lastTouch - zombie.position
      if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
        zombie.position = lastTouchLocation!
        velocity = CGPointZero
        stopZombieAnimation()
      } else {
        moveSprite(zombie, velocity: velocity)
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
      }
    }
    
    boundsCheckZombie()
    //checkCollisions()
  }
    
    override func didEvaluateActions() {
        checkCollisions()
    }

  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    println("Amount to move: \(amountToMove)")
    sprite.position += amountToMove
  }

  func moveZombieToward(location: CGPoint) {
    startZombieAnimation()
    let offset = location - zombie.position
    let direction = offset.normalized()
    velocity = direction * zombieMovePointsPerSec
  }

  func sceneTouched(touchLocation:CGPoint) {
    lastTouchLocation = touchLocation
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
    let bottomLeft = CGPoint(x: 0, 
                       y: CGRectGetMinY(playableRect))
    let topRight = CGPoint(x: size.width,
                       y: CGRectGetMaxY(playableRect))

    
    if zombie.position.x <= bottomLeft.x {
      zombie.position.x = bottomLeft.x
      velocity.x = -velocity.x
    }
    if zombie.position.x >= topRight.x {
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    if zombie.position.y <= bottomLeft.y {
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    if zombie.position.y >= topRight.y {
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    } 
  }

  func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    // Your code here!
    let shortest = shortestAngleBetween(sprite.zRotation, velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    sprite.zRotation += shortest.sign() * amountToRotate
  }

    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2,max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    
    }

    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(
            SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat");
        cat.name = "cat"
        cat.position = CGPoint(
        x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)),
        y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
            
        // 2
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        let wait = SKAction.waitForDuration(10.0)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let wiggleWait = SKAction.repeatAction(fullWiggle, count: 10)
        
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
            cat.removeFromParent()
            runAction(catCollisionSound)
            //runAction(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false))
    }
    func zombieHitEnemy(enemy: SKSpriteNode) {
            enemy.removeFromParent()
            //runAction(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: true))
            runAction(enemyCollisionSound)
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy)
        }
    }
        
}
