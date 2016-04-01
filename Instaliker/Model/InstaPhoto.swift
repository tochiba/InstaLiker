//
//  InstaPhoto.swift
//  Instaliker
//
//  Created by tochiba on 2016/03/28.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation

class InstaPhoto {
    var id: String = ""
    var link: String = ""
    var imageUrl: String = ""
    var likes: String = ""
    var tags: [String] = []
    var location: Location?
}

class Location {
    var id: Int = 0
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var name: String = ""
}