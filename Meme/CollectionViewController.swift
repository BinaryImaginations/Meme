//
//  CollectionViewController.swift
//  Meme
//
//  Created by George McMullen on 5/27/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import Foundation

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource {
    
    // Outlet for the collection view object
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
        // Reload the collection view object (so that we can show new items)
        collectionViewOutlet.reloadData()
    }
    
    // Return the number of cells
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Directly access the object to get the array cound
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes.count
    }
    
    // Populate the cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Create the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        // Get the meme object from the array using the selected row
        let meme = (UIApplication.sharedApplication().delegate as! AppDelegate).memes[indexPath.row]
        
        // Set the image for the column cell
        cell.imageForCell?.image = meme.MemeImage

        return cell
    }
    
    // Get the selected cell
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
        // Create teh detail controller
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        // Set the meme object within the controller
        detailController.meme = (UIApplication.sharedApplication().delegate as! AppDelegate).memes[indexPath.row]
        // Push the new controller on the stack
        navigationController!.pushViewController(detailController, animated: true)
    }
}
