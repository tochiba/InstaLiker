//
//  ViewController.swift
//  Instaliker
//
//  Created by 千葉 俊輝 on 2016/03/27.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import OAuthSwift
import WebImage

class ViewController: UIViewController, OAuthManagerRefreshDelegate,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var cellSize: CGSize = CGSizeZero
    var photoList: [InstaPhoto] = []
    var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicator.hidden = false
        self.indicator.startAnimating()
        setupCellSize()
        reload()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        OAuthManager.sharedInstance.request(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func setupCellSize() {
        let space: Int = 1 //マージン
        let spaceNum: Int = 0 //スペースの数
        let cellNum: Int = 1 //セルの数
        let screenSizeWidth = UIScreen.mainScreen().bounds.size.width
        let size = (screenSizeWidth - CGFloat(space * spaceNum)) / CGFloat(cellNum)
        self.cellSize = CGSizeMake(size, 240)
    }

    private func reload() {
        if isLoading == true {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.isLoading = true
            dispatch_async(dispatch_get_main_queue(), {
                self.setupPhotoList()
                self.indicator.startAnimating()
                self.indicator.hidden = true
                self.collectionView.reloadData()
                self.isLoading = false
            })
        })
    }
    
    private func setupPhotoList() {
        self.photoList = OAuthManager.sharedInstance.getMyTimeLine()
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.photoList.count)
        return self.photoList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath)
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = nil
            if let url = NSURL(string: self.photoList[indexPath.row].imageUrl) {
                imageView.sd_setImageWithURL(url)
            }
            imageView.setNeedsLayout()
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let p = self.photoList[indexPath.row]
        self.performSegueWithIdentifier("HomeToTag", sender: p)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let i = sender as? InstaPhoto {
            if let vc = segue.destinationViewController as? TagViewController {
                vc.instaPhoto = i
            }
        }
    }
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.cellSize
    }
    
    func didFinishLoadData() {
        print(OAuthManager.sharedInstance.getMyTimeLine())
        reload()
    }
}