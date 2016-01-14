//
//  Profile.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 10/31/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum userType: Int {
    case Passenger = 1
    case Driver
}



class UserProfile {
    
    static let sharedInstance = UserProfile()
    
    var image: UIImage?
    var name: String?
    var gender: String?
    var birthDay: NSDate?
    var city: City?
    var phoneNumber: String?
    var type: userType = .Passenger
    var balance: Int?
    // Driver
    var pravaPhoto: UIImage?
    var carPhoto: UIImage?
    var userID: String?
    

    
//    func updateInstanseWithJSON(userInfo: [String: JSON]) {
//        if let imageString = userInfo[UserFields.Image.rawValue]?.string {
//            if let imageData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) {
//                UserProfile.sharedInstance.image = UIImage(data: imageData)
//            }
//        }
//        
//        if let cities = LocalData.instanse.getCities() {
//            let cityID = userInfo[UserFields.City.rawValue]?.int
//            let city = cities.filter{ $0.code == cityID }.first
//            UserProfile.sharedInstance.city = city
//        }
//        
//        if let type = userInfo[UserFields.UserType.rawValue]?.int {
//            if let type1 = userType(rawValue: type) {
//                UserProfile.sharedInstance.type = type1
//            }
//        }
//        UserProfile.sharedInstance.name = userInfo[UserFields.FirstName.rawValue]?.string
//        UserProfile.sharedInstance.userID = userInfo[UserFields.Id.rawValue]?.string
//        UserProfile.sharedInstance.phoneNumber = userInfo[UserFields.PhoneNumber.rawValue]?.string
//        UserProfile.sharedInstance.balance = userInfo[UserFields.Balance.rawValue]?.int
//
//    }
    
    func getModelFromDict(userInfo: [String: JSON], shared: Bool) -> UserProfile {
        
//        if shared {
//            
//        } else {
        let profile = shared ? UserProfile.sharedInstance : UserProfile()
//        }
        
        if let imageString = userInfo[UserFields.Image.rawValue]?.string {
            if let imageData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) {
                profile.image = UIImage(data: imageData)
            }
        }
        
        if let cities = LocalData.instanse.getCities() {
            let cityID = userInfo[UserFields.City.rawValue]?.int
            let city = cities.filter{ $0.code == cityID }.first
            profile.city = city
        }
        
        if let type = userInfo[UserFields.UserType.rawValue]?.int {
            if let type1 = userType(rawValue: type) {
                profile.type = type1
            }
        }
        profile.name = userInfo[UserFields.FirstName.rawValue]?.string
        profile.userID = userInfo[UserFields.Id.rawValue]?.string
        profile.phoneNumber = userInfo[UserFields.PhoneNumber.rawValue]?.string
        profile.balance = userInfo[UserFields.Balance.rawValue]?.int
        return profile
    }
    
}

enum UserFields: String {
    case Id, FirstName, City, UserType, Image, PhoneNumber, Balance
}
