//
//  TableViewController.swift
//  Meme
//
//  Created by George McMullen on 5/27/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Outlet for the table view object
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
        // Reload the table view object (so that we show new items)
        tableViewOutlet.reloadData()
    }
    
    // Return the number of cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Directly access the object to get the array count
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes.count
    }
    
    // Populate the cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Create a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! UITableViewCell
        // Get the meme object from the array using the selected row
        let meme = (UIApplication.sharedApplication().delegate as! AppDelegate).memes[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = meme.TopText
        cell.detailTextLabel?.text = meme.BottomText
        cell.imageView?.image = meme.MemeImage
        // Hide the text messages if they are the default text
        if (meme.TopText ==  TextDelegate().initalTextMessage) {
            cell.textLabel?.text = nil
        }
        if (meme.BottomText ==  TextDelegate().initalTextMessage) {
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
    
    // Get the selected cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Create the detail controller
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        // Set the meme object within the controller
        detailController.meme = (UIApplication.sharedApplication().delegate as! AppDelegate).memes[indexPath.row]
        // Push the new controller on the stack
        navigationController!.pushViewController(detailController, animated: true)
    }
}
