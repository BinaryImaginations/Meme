//
//  MemeViewController.swift
//  Meme
//
//  Created by George McMullen on 5/22/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    // Variables
    // Text fields
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    let textDelegate = TextDelegate()
    // Pick toolbar
    @IBOutlet weak var pickToolbar: UIToolbar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    // Save/Cancel toolbar
    @IBOutlet weak var saveCancelToolBar: UIToolbar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    // Constants
    // Text attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3             // Need negative number for solid fill
    ]
    var viewRaised: Bool = false                    // Flag to determine if view has been raised to accomidate keyboard
    var currentMeme: AppDelegate.Meme!              // Current meme image being processed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the delegates for the top and bottom text fields
        topText.delegate = textDelegate
        bottomText.delegate = textDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Subscribe to the keyboard notifications
        subscribeToKeyboardNotifications()
        // Setup the text and toolbars
        // NOTE:  If the image picker image is nil, then items will be initialized
        setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Enable/disable the camera button
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    // Unsubscribe for notifications
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Unsubscribe from keyboard notificaitons
        unsubscribeFromKeyboardNotifications()
    }
    
    // Capture if a user touches outside the text area
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        // Close the keyboard when a touch happens outside the control
        view.endEditing(true)
    }
    
    // User wants to pick an image from the album
    @IBAction func pickAnImageFromAlbum (sender: AnyObject) {
        // Create an image picker controller
        let imagePicker = UIImagePickerController()
        // Assign the delegate to this class
        imagePicker.delegate = self
        // Set the source type to photolibrary
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        // Activate it
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    // User selected the cancel button
    @IBAction func cancelButton(sender: AnyObject) {
        // Dismiss the view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User wants to capture a picture from the camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        // Create an image picker controller
        let imagePicker = UIImagePickerController()
        // Assign the delegate to this class
        imagePicker.delegate = self
        // Set the source type to camera
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        // Activate it
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // User wants to save and share this Meme
    @IBAction func shareMeme(sender: AnyObject) {
        //Create the meme
        currentMeme = AppDelegate.Meme( TopText: topText.text, BottomText: bottomText.text, Image:
            imagePickerView.image!, MemeImage:  generateMemedImage())
        let activityController = UIActivityViewController(activityItems: [currentMeme.MemeImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = saveMemeAfterSharing
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    func saveMemeAfterSharing(activity: String!, completed: Bool, items: [AnyObject]!, error: NSError!) {
        if completed {
            // Save the current meme into the global memes object
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(currentMeme)
            // Dismiss the view controller
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Initial view setup
    func setup() {
        // Setup the default text attributes
        setupInitialText(topText)
        setupInitialText(bottomText)
        // Setup the toolbar background to semi translucent
        setupInitialToolbar(pickToolbar)
        setupInitialToolbar(saveCancelToolBar)
        // If we have an image, then we can display the save button
        saveButton.enabled = !(imagePickerView.image == nil)
    }
    
    // Image was selected
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        // Try and get the selected image from the image picker controller
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // We have an immage:
            // Set the aspect ratio
            imagePickerView.contentMode = UIViewContentMode.ScaleAspectFill
            // Assign the image to our image view object
            imagePickerView.image = image
        }
        // Dismiss the view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User canceled from within the image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Manage notifications from Keyboard
    func subscribeToKeyboardNotifications() {
        // Intercept and redirct the keyboard will show message
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:" , name: UIKeyboardWillShowNotification, object: nil)
        // Intercetp and redirect the keyboard will hid message
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:" , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe from keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        // Restore the keyboard will show message to original observer
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        // Restore the keyboard will hide message to the original observer
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    // Method to handle when the keyboard is displayed
    func keyboardWillShow(notification: NSNotification) {
        // If the bottom text is the first responder...
        if bottomText.isFirstResponder() {
            //NOTE:  The keyboard can grow if the user switches to emotes
            // If the view is already raised, lower it before we raise it again
            if viewRaised {
                // Return the screen to the starting position (0)
                view.frame.origin.y = 0
                viewRaised = false
            }
            // Scroll the view frame up by the size of the keyboard
            view.frame.origin.y -= getKeyboardHeight(notification)
            viewRaised = true
        }
    }
    
    // Method to handle when the keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        // If the bottom text is the first repsonder...
        if bottomText.isFirstResponder() {
            // Return the screen to the starting position (0)
            view.frame.origin.y = 0
            viewRaised = false
        }
    }
    
    // Calculate the current keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        // Calculate the height of the keyboard so we can scroll the screen if needed
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Generate a Meme from the current screen image
    // NOTE:  This method hides the toolbars and text if user hasn't entered in
    //        a text value
    func generateMemedImage() -> UIImage {
        
        // Hide the toolbar
        pickToolbar.hidden = true
        saveCancelToolBar.hidden = true
        // If the top or bottom text is set to the default, then hide it for the Meme image
        topText.hidden = (topText.text ==  TextDelegate().initalTextMessage)
        bottomText.hidden = (bottomText.text ==  TextDelegate().initalTextMessage)
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the text fields (we may have hidden them above
        topText.hidden = false
        bottomText.hidden = false
        // Show the toolbar
        saveCancelToolBar.hidden = false
        pickToolbar.hidden = false
        
        return memedImage
    }
    
    
    // Initial text field setup
    func setupInitialText(textfield: UITextField) {
        // If the image is nil, then we need to setup the initial text
        if (imagePickerView.image == nil) {
            // Initial text should have lowercase in it since users can only enter
            // in uppercase so we know this is unique
            textfield.text = TextDelegate().initalTextMessage
        }
        // Set the initial state to hidden
        textfield.hidden = (imagePickerView.image == nil)
        // Assign the default text attributes
        textfield.defaultTextAttributes = memeTextAttributes
        // Set additional attributes
        textfield.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        textfield.textAlignment = NSTextAlignment.Center
    }
    
    // Initial toolbar setup
    func setupInitialToolbar(toolbar: UIToolbar) {
        // Set the initial attributes for our toolbars
        toolbar.translucent = true
        toolbar.alpha = 0.8
    }
    
}

