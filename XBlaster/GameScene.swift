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

  let playerLayerNode = SKNode()
  let hudLayerNode = SKNode()
  let playableRect: CGRect
  let hudHeight: CGFloat = 90
  let scoreLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
  var scoreFlashAction: SKAction!
  let healthBarString: NSString = "===================="
  let playerHealthLabel = SKLabelNode(fontNamed: "Arial")
  var playerShip: PlayerShip!
  var deltaPoint = CGPointZero
  var previousTouchLocation = CGPointZero
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(size: CGSize) {
    // Calculate playable margin
    let maxAspectRatio: CGFloat = 16.0/9.0 // iPhone 5"
    let maxAspectRatioWidth = size.height / maxAspectRatio
    let playableMargin = (size.width - maxAspectRatioWidth) / 2.0
    playableRect = CGRect(x: playableMargin, y: 0,
      width: maxAspectRatioWidth,
      height: size.height - hudHeight)
    
    super.init(size: size)
    
//    setupSceneLayers()
//    setUpUI()
//    setupEntities()
  }
    
    override func didMoveToView(view: SKView) {
        let myLabel = SKLabelNode(fontNamed:"Edit Undo Line BRK")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 40
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame),
        y:CGRectGetMidY(self.frame))
        myLabel.horizontalAlignmentMode = .Left
        self.addChild(myLabel)
    }
  
  func setupSceneLayers() {
    playerLayerNode.zPosition = 50
    hudLayerNode.zPosition = 100
      
    addChild(playerLayerNode)
    addChild(hudLayerNode)
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
    playerHealthLabel.horizontalAlignmentMode = .Left
    playerHealthLabel.verticalAlignmentMode = .Top
    playerHealthLabel.position = CGPoint(
      x: CGRectGetMinX(playableRect),
      y: size.height - CGFloat(hudHeight) + 
    playerHealthLabel.frame.size.height)
    hudLayerNode.addChild(playerHealthLabel)

  }

  func setupEntities() {
    playerShip = PlayerShip(
      entityPosition: CGPoint(x: size.width / 2, y: 100))
    playerLayerNode.addChild(playerShip)
  }

  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    
    let touch = touches.first as! UITouch
    let currentPoint = touch.locationInNode(self)
    previousTouchLocation = 
      touch.previousLocationInNode(self)
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
//    // 1
//    var newPoint:CGPoint = playerShip.position + deltaPoint
//    // 2
//    newPoint.x.clamp(
//      CGRectGetMinX(playableRect), CGRectGetMaxX(playableRect))
//    newPoint.y.clamp(
//      CGRectGetMinY(playableRect),CGRectGetMaxY(playableRect))
//    // 3
//    playerShip.position = newPoint
//    deltaPoint = CGPointZero
  }

}
