//
//  FPost.swift
//  iForageTest
//
//  Created by Connor A Lynch on 25/11/2021.
//

import CloudKit
import Foundation
import UIKit

struct Post: Identifiable {
    
    let record: CKRecord
    
    init(record: CKRecord){
        self.record = record
        self.id = record.recordID
        self.title = record[Post.kTitle] as? String ?? ""
        self.caption = record[Post.kCaption] as? String ?? ""
        self.coordinate = record[Post.kCoordinate] as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
        self.image = record[Post.kImage] as? CKAsset
    }
    
    let id: CKRecord.ID
    
    let title: String
    let caption: String
    let coordinate: CLLocation
    let image: CKAsset!
}

extension Post {
    static let kTitle = "title"
    static let kCaption = "caption"
    static let kCoordinate = "coordinate"
    static let kImage = "image"
    static let kUserID = "userID"
}
