//
//  OAuthManager.swift
//  Instaliker
//
//  Created by tochiba on 2016/03/28.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire
import SwiftyJSON

protocol OAuthManagerRefreshDelegate: class {
    func didFinishLoadData()
}

class OAuthManager: NSObject {
    
    static let sharedInstance = OAuthManager()
    var delegate: OAuthManagerRefreshDelegate?
    
    private let Instagram = [
        "consumerKey": "XXXXX",
        "consumerSecret": "XXXXX"]
    
    private let services = Services()
    private var credential: OAuthSwiftCredential?
    private var photos: [InstaPhoto] = []
    
    override init() {
        super.init()
        initConf()
        getUrlHandler()
    }
    
    private func initConf() {
        services["Instagram"] = Instagram
    }
    
    private func createWebViewController() -> WebViewController {
        let controller = WebViewController()
        return controller
    }
    
    private func getUrlHandler() -> OAuthSwiftURLHandlerType {
        // Create a WebViewController with default behaviour from OAuthWebViewController
        let url_handler = createWebViewController()
        return url_handler
    }
    
    func request(delegate: OAuthManagerRefreshDelegate?) {
        self.delegate = delegate
        if let cre = self.credential {
            // https://api.instagram.com/v1/users/self/media/recent/?access_token=
            
            Alamofire.request(.GET, "https://api.instagram.com/v1/users/self/media/recent/?access_token=\(cre.oauth_token)&count=50")
                .responseJSON { response in
                    guard let object = response.result.value else {
                        return
                    }
                    
                    let json = JSON(object)
                    let array = json["data"].arrayValue
                    var photoList: [InstaPhoto] = []
                    for p in array {
                        if p["type"].stringValue == "image" {
                            let i = InstaPhoto()
                            i.id = p["caption"]["id"].stringValue
                            i.link = p["link"].stringValue
                            i.imageUrl = p["images"]["standard_resolution"]["url"].stringValue
                            i.likes = p["likes"]["count"].stringValue
                            if let t = p["tags"].arrayObject as? [String] {
                                i.tags = t
                            }
                            
                            if let l = p["location"].dictionaryObject {
                                if let id = l["id"] as? Int {
                                    let loc = Location()
                                    loc.id = id
                                    loc.name = p["location"]["name"].stringValue
                                    loc.latitude = p["location"]["latitude"].numberValue.doubleValue
                                    loc.longitude = p["location"]["longitude"].numberValue.doubleValue
                                    
                                    i.location = loc
                                }
                            }
                            
                            photoList.append(i)
                        }
                    }
                    self.photos = photoList
                    self.delegate?.didFinishLoadData()
            }
            
        }
        else {
            doAuthService()
        }
        
        self.delegate?.didFinishLoadData()
    }
    
    func getMyTimeLine() -> [InstaPhoto] {
        return self.photos
    }
    
    func likeRequest(tag: String) {
        if let cre = self.credential {
            // https://api.instagram.com/v1/tags/{tag-name}/media/recent?access_token=ACCESS-TOKEN
            
            Alamofire.request(.GET, "https://api.instagram.com/v1/tags/\(tag)/media/recent?access_token=\(cre.oauth_token)&count=50")
                .responseJSON { response in
                    guard let object = response.result.value else {
                        return
                    }
                    
                    let json = JSON(object)
                    print(json)
                    
                    let array = json["data"].arrayValue
                    for m in array {
                        print(m)
                        
                    }
            }
            
        }
        else {
            doAuthService()
        }
    }
    
    func doAuthService() {
        if self.credential != nil {
            return
        }
        
        let service = "Instagram"
        guard var parameters = services[service] else {
            return
        }
        
        if Services.parametersEmpty(parameters) { // no value to set
            // TODO here ask for parameters instead
        }
        
        parameters["name"] = service
        doOAuthInstagram(parameters)
    }
    
    private func doOAuthInstagram(serviceParameters: [String:String]){
        let oauthswift = OAuth2Swift(
            consumerKey:    serviceParameters["consumerKey"]!,
            consumerSecret: serviceParameters["consumerSecret"]!,
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
            // or
            // accessTokenUrl: "https://api.instagram.com/oauth/access_token",
            // responseType:   "code"
        )
        
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorize_url_handler = getUrlHandler()
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/instagram")!, scope: "likes", state:state, success: {
            credential, response, parameters in
            
            self.credential = credential
            
            }, failure: { error in
                //print(error.localizedDescription)
                self.doAuthService()
        })
        
    }
    
    func testInstagram(oauthswift: OAuth2Swift) {
        let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(oauthswift.client.credential.oauth_token)"
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        oauthswift.client.get(url, parameters: parameters,
            success: {
                data, response in
            }, failure: { error in
                print(error)
        })
    }
    
}