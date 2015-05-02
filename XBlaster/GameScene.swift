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

// The update method uses the GameState to work out what should be done during each update
// loop
enum GameState {
  case GameRunning
  case GameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {

  let playerLayerNode = SKNode()
  let hudLayerNode = SKNode()
  let bulletLayerNode = SKNode()
  var enemyLayerNode = SKNode()
  let playableRect: CGRect
  let hudHeight: CGFloat = 90
  let scoreLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
  var scoreFlashAction: SKAction!
  let healthBarString: NSString = "===================="
  let playerHealthLabel = SKLabelNode(fontNamed: "Arial")
  var playerShip: PlayerShip!
  var deltaPoint = CGPointZero
  var previousTouchLocation = CGPointZero
  var bulletInterval: NSTimeInterval = 0
  var lastUpdateTime: NSTimeInterval = 0
  var dt: NSTimeInterval = 0
  var score = 0
  var gameState = GameState.GameOver

  let gameOverLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
  let tapScreenPulseAction = SKAction.repeatActionForever(SKAction.sequence([
    SKAction.fadeOutWithDuration(1),
    SKAction.fadeInWithDuration(1)
    ]))
  let tapScreenLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")

  override init(size: CGSize) {
    // Calculate playable margin
    let maxAspectRatio: CGFloat = 16.0/9.0 // iPhone 5"
    let maxAspectRatioWidth = size.height / maxAspectRatio
    let playableMargin = (size.width - maxAspectRatioWidth) / 2.0
    playableRect = CGRect(x: playableMargin, y: 0,
      width: maxAspectRatioWidth,
      height: size.height - hudHeight)
    
    super.init(size: size)
    
    // Setup the initial game state
    gameState = .GameRunning
    
    setupSceneLayers()
    setUpUI()
    setupEntities()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToView(view: SKView) {
    physicsWorld.gravity = CGVectorMake(0, 0)
    physicsWorld.contactDelegate = self
  }
  
  func setupSceneLayers() {
    playerLayerNode.zPosition = 50
    hudLayerNode.zPosition = 100
    bulletLayerNode.zPosition = 25
    enemyLayerNode.zPosition = 35
    
    addChild(playerLayerNode)
    addChild(hudLayerNode)
    addChild(bulletLayerNode)
    addChild(enemyLayerNode)
  }
  
  func setUpUI() {
    let backgroundSize =
      CGSize(width: size.width, height:hudHeight)
    let backgroundColor = SKColor.blackColor()
    let hudBarBackground = 
      SKSpriteNode(color: backgroundColor, size: backgroundSize)
    hudBarBackground.position = 
      CGPoint(x:0, y: size.height - hudHeight)
    hudBarBackground.anchorPoint = CGPointZero
    hudLayerNode.addChild(hudBarBackground)
    
    // 1
    scoreLabel.fontSize = 50
    scoreLabel.text = "Score: 0"
    scoreLabel.name = "scoreLabel"
    // 2
    scoreLabel.verticalAlignmentMode = .Center
    // 3
    scoreLabel.position = CGPoint(
      x: size.width / 2,
      y: size.height - scoreLabel.frame.size.height + 3)
    // 4
    hudLayerNode.addChild(scoreLabel)
    
    scoreFlashAction = SKAction.sequence([
      SKAction.scaleTo(1.5, duration: 0.1),
      SKAction.scaleTo(1.0, duration: 0.1)])
    scoreLabel.runAction(
      SKAction.repeatAction(scoreFlashAction, count: 20))
    
    // 1
    let playerHealthBackgroundLabel =
      SKLabelNode(fontNamed: "Arial")
    playerHealthBackgroundLabel.name = "playerHealthBackground"
    playerHealthBackgroundLabel.fontColor = SKColor.darkGrayColor()
    playerHealthBackgroundLabel.fontSize = 50
    playerHealthBackgroundLabel.text = healthBarString as String
    playerHealthBackgroundLabel.zPosition = 0
    // 2
    playerHealthBackgroundLabel.horizontalAlignmentMode = .Left
    playerHealthBackgroundLabel.verticalAlignmentMode = .Top
    playerHealthBackgroundLabel.position = CGPoint(
      x: CGRectGetMinX(playableRect),
      y: size.height - CGFloat(hudHeight) + 
        playerHealthBackgroundLabel.frame.size.height)
    hudLayerNode.addChild(playerHealthBackgroundLabel)
    // 3
    playerHealthLabel.name = "playerHealthLabel"
    playerHealthLabel.fontColor = SKColor.greenColor()
    playerHealthLabel.fontSize = 50
    playerHealthLabel.text = 
      healthBarString.substringToIndex(20*75/100)
    playerHealthLabel.zPosition = 1
    playerHealthLabel.horizontalAlignmentMode = .Left
    playerHealthLabel.verticalAlignmentMode = .Top
    playerHealthLabel.position = CGPoint(
      x: CGRectGetMinX(playableRect),
      y: size.height - CGFloat(hudHeight) + 
    playerHealthLabel.frame.size.height)
    hudLayerNode.addChild(playerHealthLabel)
    
    gameOverLabel.name = "gameOverLabel"
    gameOverLabel.fontSize = 100
    gameOverLabel.fontColor = SKColor.whiteColor()
    gameOverLabel.horizontalAlignmentMode = .Center
    gameOverLabel.verticalAlignmentMode = .Center
    gameOverLabel.position = CGPointMake(size.width / 2,
      size.height / 2)
    gameOverLabel.text = "GAME OVER";
    
    tapScreenLabel.name = "tapScreen"
    tapScreenLabel.fontSize = 22;
    tapScreenLabel.fontColor = SKColor.whiteColor()
    tapScreenLabel.horizontalAlignmentMode = .Center
    tapScreenLabel.verticalAlignmentMode = .Center
    tapScreenLabel.position = CGPointMake(size.width / 2,
      size.height / 2 - 100)
    tapScreenLabel.text = "Tap Screen To Restart"
    
  }

  func setupEntities() {
    playerShip = PlayerShip(
      entityPosition: CGPoint(x: size.width / 2, y: 100))
    playerLayerNode.addChild(playerShip)
    
    // Add some EnemyA entities to the scene
    for _ in 0..<3 {
      let enemy = EnemyA(entityPosition: CGPointMake(
        CGFloat.random(min: playableRect.origin.x, max: playableRect.size.width),
        playableRect.size.height), playableRect: playableRect)

      // Set the initialWaypoint for the enemy to a random position within the playableRect
      let initialWaypoint = CGPointMake(CGFloat.random(min: playableRect.origin.x, max: playableRect.size.width),
      CGFloat.random(min: 0, max: playableRect.size.height))
      enemy.aiSteering.updateWaypoint(initialWaypoint)
      enemyLayerNode.addChild(enemy)
    }

    for _ in 0..<3 {
      let enemy = EnemyB(entityPosition: CGPointMake(
        CGFloat.random(min: playableRect.origin.x, max: playableRect.size.width),
        playableRect.size.height), playableRect: playableRect)
      let initialWaypoint = CGPointMake(CGFloat.random(min: playableRect.origin.x, max: playableRect.width),
        CGFloat.random(min: playableRect.height / 2, max: playableRect.height))
      enemy.aiSteering.updateWaypoint(initialWaypoint)
      enemyLayerNode.addChild(enemy)
    }
  }
  
  func increaseScoreBy(increment: Int) {
    score += increment
    scoreLabel.text = "Score: \(score)"
    scoreLabel.removeAllActions()
    scoreLabel.runAction(scoreFlashAction)
  }
  
  func restartGame() {
    // Reset the state of the game
    gameState = .GameRunning
    
    // Setup the entities and reset the score
    setupEntities()
    score = 0
    scoreLabel.text = "Score: 0"

    // Reset the players health and position
    playerShip.health = playerShip.maxHealth
    playerShip.position = CGPointMake(size.width / 2, 100)
    
    // Remove the game over HUD labels
    gameOverLabel.removeFromParent()
    tapScreenLabel.removeAllActions()
    tapScreenLabel.removeFromParent()
  }
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    if gameState == .GameOver {
      restartGame()
    }
  }

  override func touchesMoved(touches: Set<NSObject>,
                             withEvent event: UIEvent) {
    
    let touch = touches.first as! UITouch
    let currentPoint = touch.locationInNode(self)
    previousTouchLocation = touch.previousLocationInNode(self)
    deltaPoint = currentPoint - previousTouchLocation
  }
    
  override func touchesEnded(touches: Set<NSObject>,
                             withEvent event: UIEvent) {
    deltaPoint = CGPointZero
  }

  override func touchesCancelled(touches: Set<NSObject>, withEvent
                                 event: UIEvent) {
    deltaPoint = CGPointZero
  }

  override func update(currentTime: NSTimeInterval) {
    // 1
    var newPoint:CGPoint = playerShip.position + deltaPoint
    // 2
    newPoint.x.clamp(
      CGRectGetMinX(playableRect), CGRectGetMaxX(playableRect))
    newPoint.y.clamp(
      CGRectGetMinY(playableRect),CGRectGetMaxY(playableRect))
    // 3
    playerShip.position = newPoint
    deltaPoint = CGPointZero
    
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
    
    switch gameState {
    case (.GameRunning):
      bulletInterval += dt
      if bulletInterval > 0.15 {
        bulletInterval = 0
        
        // 1: Create Bullet
        let bullet = Bullet(entityPosition: playerShip.position)
        
        // 2: Add to scene
        bulletLayerNode.addChild(bullet)
        
        // 3: Sequence: Move up screen, remove from parent
        bullet.runAction(SKAction.sequence([
          SKAction.moveByX(0, y: size.height, duration: 1),
          SKAction.removeFromParent()
        ]))
      }
      
      // Loop through all enemy nodes and run their update method.
      // This causes them to update their position based on their currentWaypoint and position
      for node in enemyLayerNode.children {
        let enemy = node as! Enemy
        enemy.update(self.dt)
      }

      // Update the players health label to be the right length based on the players health and also
      // update the color so that the closer to 0 it gets the more red it becomes
      playerHealthLabel.fontColor = SKColor(red: CGFloat(2.0 * (1 - playerShip.health / 100)),
        green: CGFloat(2.0 * playerShip.health / 100),
        blue: 0,
        alpha: 1)

      // Calculate the length of the players health bar.
      let healthBarLength = Double(healthBarString.length) * playerShip.health / 100.0
      playerHealthLabel.text = healthBarString.substringToIndex(Int(healthBarLength))

      // If the player health reaches 0 then change the game state.
      if playerShip.health <= 0 {
        gameState = .GameOver
      }
      
    case (.GameOver):

      // When the game is over remove all the entities from the scene and add the game over labels
      if !(gameOverLabel.parent != nil) {
        bulletLayerNode.removeAllChildren()
        enemyLayerNode.removeAllChildren()
        playerShip.removeFromParent()
        hudLayerNode.addChild(gameOverLabel)
        hudLayerNode.addChild(tapScreenLabel)
        tapScreenLabel.runAction(tapScreenPulseAction)
      }
      
      // Set a random color for the game over label
      gameOverLabel.fontColor = SKColor(red: CGFloat(drand48()),
        green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
      
    default:
      println("UNKNWON GAME STATE")
    }
  
  }
  
  // This method is called by the physics engine when two physics body collide
  func didBeginContact(contact: SKPhysicsContact) {

    // Check to see if Body A is an enamy ship and if so call collided with
    if let enemyNode = contact.bodyA.node {
      if enemyNode.name == "enemy" {
          let enemy = enemyNode as! Entity
          enemy.collidedWith(contact.bodyA, contact: contact)
      }
    }
    
    // ...and now check to see if Body B is the player ship/bullet
    if let playerNode = contact.bodyB.node {
      if playerNode.name == "playerShip" || playerNode.name == "bullet" {
          let player = playerNode as! Entity
          player.collidedWith(contact.bodyA, contact: contact)
      }
    }
  }

}
