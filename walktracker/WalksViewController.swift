//
//  WalksViewController.swift
//  walktracker
//
//  Created by Kevin VanderLugt on 1/23/15.
//  Copyright (c) 2015 Alpine Pipeline. All rights reserved.
//

import UIKit
import Foundation

class WalksViewController: UIViewController, UIToolbarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height

        self.tableView.contentInset = UIEdgeInsetsMake(toolbar.frame.size.height + statusBarHeight,0,0,0);
        
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        if let allWalks = WalkStore.sharedInstance.allWalks() {
            let walk = allWalks[indexPath.row] as Walk
            cell.textLabel?.text = dateFormatter.stringFromDate(walk.startTimestamp)
        }
        else {
            cell.textLabel?.text = "We need more walks!"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let allWalks = WalkStore.sharedInstance.allWalks() {
            return allWalks.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let allWalks = WalkStore.sharedInstance.allWalks() {
            let walk = allWalks[indexPath.row] as Walk
            WalkStore.sharedInstance.currentWalk = walk
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}