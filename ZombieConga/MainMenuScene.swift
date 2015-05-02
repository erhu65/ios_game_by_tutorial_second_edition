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

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
 
  override func didMoveToView(view: SKView) {
    
    let background = SKSpriteNode(imageNamed:"MainMenu")
    background.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
    self.addChild(background)
  
  }
  
  func sceneTapped() {
    let myScene = GameScene(size:self.size)
    myScene.scaleMode = scaleMode
    let reveal = SKTransition.doorwayWithDuration(1.5)
    self.view?.presentScene(myScene, transition: reveal)
  }

  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    sceneTapped()
  }

}