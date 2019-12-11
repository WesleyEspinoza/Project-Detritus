//
//  ButtonNode.swift
//  Detritus
//
//  Created by Wesley Espinoza on 11/5/19.
//  Copyright © 2019 HazeWritesCode. All rights reserved.
//

import Foundation
import SpriteKit

enum ButtonNodeStates {
    case Active, Selected, Hidden
}

class ButtonNode: SKSpriteNode {
    
    public var hasSet: Bool = false
    
    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }
    
    /* Button state management */
    var state: ButtonNodeStates = .Active {
        didSet {
            switch state {
            case .Active:
                /* Enable touch */
                self.isUserInteractionEnabled = true
                
                /* Visible */
                self.alpha = 1
                break
            case .Selected:
                /* Semi transparent */
                self.alpha = 0.7
                break
            case .Hidden:
                /* Disable touch */
                self.isUserInteractionEnabled = false
                
                /* Hide */
                self.alpha = 0
                break
            }
        }
    }
    
    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required init?(coder aDecoder: NSCoder) {
        
        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)
        
        /* Enable touch on button node */
        self.isUserInteractionEnabled = true
    }
    
    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .Selected
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedHandler()
        state = .Active
    }
    
}

