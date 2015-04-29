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

/*
 
 Challenge 1 answers:
 
 1) followPath(duration:)
 2) fadeAlphaTo(duration:)
 3) Explanation follows:
 
 Custom actions allow you to easily make a node do soemthing over time that there isn't already an action for. The ActionsCatalog demonstrates three kinds of custom actions: making a node blink, jump, or follow a sin wave.
 
 Custom actions give you a node to work with, and how much time has elapsed. Your job is to update something on the node, based on the percentage of how much time has elapsed vs. the passed in duration.
 
 As an example, here's an explanation of the blink action demo in ActionsCatalog:
 
 1) Divide the duration by the number of blinks the desired in that time period. Call that a "slice" of time. In each slice, the node should be visible for half the time, and invisible for the other half. That is what will make the node appear to blink.
 
 2) The modulus operator (%) works with fractions as well as integers in Swift. It basically returns the remainder of the first parameter (elapsedTime) after being divided by the second parameter (slice). So in this example, it gives you the amount of time that has elapsed in this "slice" calculated ealrier.
 
 3) The hidden property on a node controls whether it is rendered or not. If the remainder calculated above is in the second half of the slice, it should be hidden (invisible). Otherwise it will be visible. Hence, the blink effect!

Note that you can also accomplish a blink effect with a combination of hide() and unhide() actions, as you see in HideScene. 

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
  let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "hitCat.wav", waitForCompletion: false)
  let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
    "hitCatLady.wav", waitForCompletion: false)
  var invincible = false
  let catMovePointsPerSec:CGFloat = 480.0
    var lives = 5
    var gameOver = false
    
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height-playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin, 
                          width: size.width,
                          height: playableHeight)
    // 1
    var textures:[SKTexture] = []
    // 2
    for i in 1...4 {
      textures.append(SKTexture(imageNamed: "zombie\(i)"))
    }
    // 3
    textures.append(textures[2])
    textures.append(textures[1])

    // 4
    zombieAnimation = SKAction.repeatActionForever(
      SKAction.animateWithTextures(textures, timePerFrame: 0.1))
    
    super.init(size: size)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
    background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    background.zPosition = -1
    addChild(background)
    
    zombie.position = CGPoint(x: 400, y: 400)
    zombie.zPosition = 100
    //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
    addChild(zombie)
    runAction(SKAction.repeatActionForever(
      SKAction.sequence([SKAction.runBlock(spawnEnemy),
                         SKAction.waitForDuration(2.0)])))
    runAction(SKAction.repeatActionForever(
      SKAction.sequence([SKAction.runBlock(spawnCat),
                         SKAction.waitForDuration(1.0)])))
  
    //debugDrawPlayableArea()
  }
  
  override func update(currentTime: NSTimeInterval) {
  
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime

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
    moveTrain()
    if lives <= 0 && !gameOver {
        gameOver = true
        println("You lose!")
        // 1
        let gameOverScene = GameOverScene(size: size, won: false)
        gameOverScene.scaleMode = scaleMode
        // 2
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        // 3
        view?.presentScene(gameOverScene, transition: reveal)
        
    }
  
  }

  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
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
    let shortest = shortestAngleBetween(sprite.zRotation, velocity.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
    sprite.zRotation += shortest.sign() * amountToRotate
  }

  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    enemy.position = CGPoint(
      x: size.width + enemy.size.width/2, 
      y: CGFloat.random(
        min: CGRectGetMinY(playableRect) + enemy.size.height/2, 
        max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
    addChild(enemy)
    
    let actionMove = 
      SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
    let actionRemove = SKAction.removeFromParent()
    enemy.runAction(SKAction.sequence([actionMove, actionRemove]))

  }

  func startZombieAnimation() {
    if zombie.actionForKey("animation") == nil {
      zombie.runAction(
        SKAction.repeatActionForever(zombieAnimation), 
        withKey: "animation")
    }
  }

  func stopZombieAnimation() {
    zombie.removeActionForKey("animation")
  }

  func spawnCat() {
    // 1
    let cat = SKSpriteNode(imageNamed: "cat")
    cat.name = "cat"
    cat.position = CGPoint(
      x: CGFloat.random(min: CGRectGetMinX(playableRect), 
                        max: CGRectGetMaxX(playableRect)), 
      y: CGFloat.random(min: CGRectGetMinY(playableRect), 
                        max: CGRectGetMaxY(playableRect)))
    cat.setScale(0)
    addChild(cat)
    // 2
    let appear = SKAction.scaleTo(1.0, duration: 0.5)

    cat.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
    let rightWiggle = leftWiggle.reversedAction()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
    let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
    let scaleDown = scaleUp.reversedAction()
    let fullScale = SKAction.sequence(
      [scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeatAction(group, count: 10)

    let disappear = SKAction.scaleTo(0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [appear, groupWait, disappear, removeFromParent]
    cat.runAction(SKAction.sequence(actions))
  }

  func zombieHitCat(cat: SKSpriteNode) {
    runAction(catCollisionSound)
    
    cat.name = "train"
    cat.removeAllActions()
    cat.setScale(1.0)
    cat.zRotation = 0
    
    let turnGreen = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
    cat.runAction(turnGreen)
  }

  func zombieHitEnemy(enemy: SKSpriteNode) {
    runAction(enemyCollisionSound)
    loseCats()
    lives--
    
    
    invincible = true
    
    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customActionWithDuration(duration) { node, elapsedTime in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime) % slice
      node.hidden = remainder > slice / 2
    }
    let setHidden = SKAction.runBlock() {
      self.zombie.hidden = false
      self.invincible = false
    }
    zombie.runAction(SKAction.sequence([blinkAction, setHidden]))
    
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
    
    if invincible {
      return
    }
   
    var hitEnemies: [SKSpriteNode] = []
    enumerateChildNodesWithName("enemy") { node, _ in
      let enemy = node as! SKSpriteNode
      if CGRectIntersectsRect(
        CGRectInset(node.frame, 20, 20), self.zombie.frame) {
        hitEnemies.append(enemy)
      }
    }
    for enemy in hitEnemies {
      zombieHitEnemy(enemy)
    }
  }

  override func didEvaluateActions()  {
    checkCollisions()
  }

  func moveTrain() {
    var targetPosition = zombie.position
    var trainCount = 0
    
    enumerateChildNodesWithName("train") { node, stop in
        trainCount++
      if !node.hasActions() {
        
        let actionDuration = 0.3
        let offset = targetPosition - node.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * self.catMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
        node.runAction(moveAction)
      }
      targetPosition = node.position
    }
    
    if trainCount >= 1 && !gameOver {
        gameOver = true
        println("You win!")
        
        // 1
        let gameOverScene = GameOverScene(size: size, won: true)
        gameOverScene.scaleMode = scaleMode
        // 2
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        // 3
        view?.presentScene(gameOverScene, transition: reveal)
   
    }
    
  }
    func loseCats() {
        // 1
        var loseCount = 0
        enumerateChildNodesWithName("train") { node, stop in
            // 2
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            // 3
            node.name = ""
            node.runAction(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotateByAngle(π*4, duration: 1.0),
                        SKAction.moveTo(randomSpot, duration: 1.0),
                        SKAction.scaleTo(0, duration: 1.0)
                        ]),
                    SKAction.removeFromParent()
                    ]))
            // 4
            loseCount++
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }
}
