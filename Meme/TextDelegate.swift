//
//  TextDelegate.swift
//  Meme
//
//  Created by George McMullen on 5/22/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import Foundation
import UIKit

class TextDelegate : NSObject, UITextFieldDelegate {
    internal let initalTextMessage: String = "Enter text..."
    
    override init() {
        super.init()
    }
    
    // Editing has begun within a text field
    func textFieldDidBeginEditing(textField: UITextField) {
        // If the current text equals the default text, clear it
        // NOTE:  We use lowercase text in out default message and only allow uppercase so that we
        // can tell if this is the default text
        if (textField.text ==  initalTextMessage) {
            // Clear the text
            textField.text = ""
        }
    }
    
    // Text field received an input (character)
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // If we have a string passed (not a backspace) and that string isn't uppercase
        if count(string) > 0 && string != string.uppercaseString {
            // Add the uppercase value to the existing string
            textField.text = textField.text + string.uppercaseString
            // Don't let the value be added since we already added it to the existing string
            return false
        }
        // String is either uppercase or a backspace
        return true
    }
    
    // User pressed a 'return' from within a text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Exit the edit file on a 'return' keyp press
        textField.resignFirstResponder()
        return true
    }
}