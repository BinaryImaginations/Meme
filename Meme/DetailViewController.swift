//
//  DetailViewController.swift
//  Meme
//
//  Created by George McMullen on 5/27/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit

class DetailViewController : UIViewController {
    // We only need an image to display
    @IBOutlet weak var imageView: UIImageView!
    
    // Meme object to hold the selected meme
    var meme: AppDelegate.Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true  // Hide the tab bar controller
        // Set the image to the meme
        imageView!.image = meme.MemeImage      // Set the view's image
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false  // Display the tab bar controller
    }
}
