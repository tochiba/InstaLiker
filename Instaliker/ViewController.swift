//
//  ViewController.swift
//  Instaliker
//
//  Created by 千葉 俊輝 on 2016/03/27.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController {

    let Instagram =
    [
        "consumerKey": "XXXXXXXXXXX",
        "consumerSecret": "XXXXXXXXXXX"
    ]
    let services = Services()
    let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let FileManager: NSFileManager = NSFileManager.defaultManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initConf()
        // init now
        get_url_handler()
        
        doAuthService("Instagram")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initConf() {
        initConfOld()
        print("Load configuration from \n\(self.confPath)")
        
        // Load config from model file
//        if let path = NSBundle.mainBundle().pathForResource("Services", ofType: "plist") {
//            services.loadFromFile(path)
//            
//            if !FileManager.fileExistsAtPath(confPath) {
//                do {
//                    try FileManager.copyItemAtPath(path, toPath: confPath)
//                }catch {
//                    print("Failed to copy empty conf to\(confPath)")
//                }
//            }
//        }
//        services.loadFromFile(confPath)
    }
    
    func initConfOld() { // TODO Must be removed later
        services["Instagram"] = Instagram
    }
    
    var confPath: String {
        let appPath = "\(DocumentDirectory)/.oauth/"
        if !FileManager.fileExistsAtPath(appPath) {
            do {
                try FileManager.createDirectoryAtPath(appPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
                print("Failed to create \(appPath)")
            }
        }
        return "\(appPath)Services.plist"
    }
    
    func doAuthService(service: String) {
        
        guard var parameters = services[service] else {
            showAlertView("Miss configuration", message: "\(service) not configured")
            return
        }
        
        if Services.parametersEmpty(parameters) { // no value to set
            let message = "\(service) seems to have not weel configured. \nPlease fill consumer key and secret into configuration file \(self.confPath)"
            print(message)
            showAlertView("Miss configuration", message: message)
            // TODO here ask for parameters instead
        }
        
        parameters["name"] = service
        doOAuthInstagram(parameters)
        print("\(service) not implemented")
        
    }
    
    func doOAuthInstagram(serviceParameters: [String:String]){
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
        oauthswift.authorize_url_handler = get_url_handler()
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/instagram")!, scope: "likes+comments", state:state, success: {
            credential, response, parameters in
            
            self.showTokenAlert(serviceParameters["name"], credential: credential)
            self.testInstagram(oauthswift)
            
            }, failure: { error in
                print(error.localizedDescription)
        })
        
    }
    func testInstagram(oauthswift: OAuth2Swift) {
        let url :String = "https://api.instagram.com/v1/users/1574083/?access_token=\(oauthswift.client.credential.oauth_token)"
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        oauthswift.client.get(url, parameters: parameters,
            success: {
                data, response in
                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                print(jsonDict)
                
            }, failure: { error in
                print(error)
        })
    }

    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauth_token)"
        if !credential.oauth_token_secret.isEmpty {
            message += "\n\noauth_toke_secret:\(credential.oauth_token_secret)"
        }
        self.showAlertView(name ?? "Service", message: message)
        
        if let service = name {
            services.updateService(service, dico: ["authentified":"1"])
            // TODO refresh graphic
        }
    }
    
    func showAlertView(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: create an optionnal internal web view to handle connection
    func createWebViewController() -> WebViewController {
        let controller = WebViewController()
        return controller
    }

    func get_url_handler() -> OAuthSwiftURLHandlerType {
        // Create a WebViewController with default behaviour from OAuthWebViewController
        let url_handler = createWebViewController()
        return url_handler
    }
}

