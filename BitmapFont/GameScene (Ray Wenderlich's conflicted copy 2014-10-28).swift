//
//  GameScene.swift
//  BitmapFont
//
//  Created by Mike Daley on 08/07/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

  var bitmapFont: SSBitmapFont!
  
  override func didMoveToView(view: SKView) {
    /* Setup your scene here */

    // Get the path to the font to be used
    let path = NSBundle.mainBundle().pathForResource("RetroFont", ofType: "skf")
    let url = NSURL.fileURLWithPath(path!)
    
    // Create a new SSBitmapFont instance using the supplied font path
    var error: NSError?
    bitmapFont = SSBitmapFont(file: url, error: &error)

    // If everything worked then create the label
    if !(error != nil) {
      let bitmapFontLabelNode = bitmapFont.nodeFromString("Hello\nWorld!!")
      bitmapFontLabelNode.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 100)
      bitmapFontLabelNode.horizontalAlignmentMode = .Center
      bitmapFontLabelNode.verticalAlignmentMode = .Bottom
      bitmapFontLabelNode.showOutline = true
      
      println("\(bitmapFontLabelNode)")
      
      self.addChild(bitmapFontLabelNode)
    }
    
    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
    myLabel.text = "Hello, World!";
    myLabel.fontSize = 65;
    myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
    
    self.addChild(myLabel)
  }
    
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    /* Called when a touch begins */
    
    for touch: AnyObject in touches {
        let location = touch.locationInNode(self)
        
        let sprite = SKSpriteNode(imageNamed:"Spaceship")
        
        sprite.xScale = 0.5
        sprite.yScale = 0.5
        sprite.position = location
        
        let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        
        sprite.runAction(SKAction.repeatActionForever(action))
        
        self.addChild(sprite)
    }
  }
 
  override func update(currentTime: CFTimeInterval) {
      /* Called before each frame is rendered */
  }
}
