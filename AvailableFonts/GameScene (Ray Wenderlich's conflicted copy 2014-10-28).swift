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
 
import UIKit
import SpriteKit

class GameScene: SKScene {
  
  var familyIdx: Int = 0
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(size: CGSize) {
    super.init(size: size)
    showCurrentFamily()
  }
  
  func showCurrentFamily() {
    // 1
    removeAllChildren()

    // 2
    let familyName = UIFont.familyNames()[familyIdx] as String
    println("Family: \(familyName)")

    // 3
    let fontNames = 
      UIFont.fontNamesForFamilyName(familyName) as [String]
        
    // 4
    for (idx, fontName) in enumerate(fontNames) {
      let label = SKLabelNode(fontNamed: fontName)
      label.text = fontName
      label.position = CGPoint(
        x: size.width / 2,
        y: (size.height * (CGFloat(idx+1))) /
          (CGFloat(fontNames.count)+1))
      label.fontSize = 25
      label.verticalAlignmentMode = .Center
      addChild(label)
    }

  }
  
  override func touchesBegan(touches: NSSet,
                             withEvent event: UIEvent) {
    familyIdx++
    if familyIdx >= UIFont.familyNames().count {
      familyIdx = 0
    }
    showCurrentFamily()
  } 
}
