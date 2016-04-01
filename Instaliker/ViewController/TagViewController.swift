//
//  TagViewController.swift
//  Instaliker
//
//  Created by tochiba on 2016/03/28.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import UIKit

class TagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var instaPhoto: InstaPhoto?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.instaPhoto == nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.instaPhoto?.tags.count {
            return count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagCell", forIndexPath: indexPath)
        if let t = self.instaPhoto?.tags[indexPath.row] {
            cell.textLabel?.text = "#" + t
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let t = self.instaPhoto?.tags[indexPath.row] {
            OAuthManager.sharedInstance.likeRequest(t)
        }
    }
}