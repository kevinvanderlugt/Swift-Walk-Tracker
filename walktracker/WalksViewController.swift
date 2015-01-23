//
//  WalksViewController.swift
//  walktracker
//
//  Created by Kevin VanderLugt on 1/23/15.
//  Copyright (c) 2015 Alpine Pipeline. All rights reserved.
//

import UIKit
import Foundation

class WalksViewController: UIViewController, UIToolbarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        // Probably should also get the toolbar height just in case
        self.tableView.contentInset = UIEdgeInsetsMake(44 + statusBarHeight,0,0,0);
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}