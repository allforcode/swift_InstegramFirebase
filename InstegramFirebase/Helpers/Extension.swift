//
//  Extension.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 4/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

extension Database {
    static func fetchUserWithUID(_ uid: String, completion: @escaping ( User ) -> Void){
        
        let userRef = Database.database().reference().child(DBChild.users.rawValue).child(uid)
        userRef.observeSingleEvent(of: .value, with: { ( snapshot ) in
            guard let userDic = snapshot.value as? [String : Any] else  { return }
            let user = User(uid: uid, dictionary: userDic)
            completion(user)
        }) { ( error ) in
            print("Failed to fetch user", error)
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
}

extension UIView {
    func anchor(topAnchor: NSLayoutYAxisAnchor?, bottomAnchor: NSLayoutYAxisAnchor?, leftAnchor: NSLayoutXAxisAnchor?, rightAnchor: NSLayoutXAxisAnchor?) {
        self.anchor(topAnchor: topAnchor, paddingTop: 0, bottomAnchor: bottomAnchor, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 0, rightAnchor: rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    func anchor(topAnchor: NSLayoutYAxisAnchor? ,paddingTop: CGFloat, bottomAnchor: NSLayoutYAxisAnchor?, paddingBottom: CGFloat, leftAnchor: NSLayoutXAxisAnchor?, paddingLeft: CGFloat, rightAnchor: NSLayoutXAxisAnchor?, paddingRight: CGFloat, widthConstant: CGFloat, heightConstant: CGFloat, centerXAnchor: NSLayoutXAxisAnchor?, paddingCenterX: CGFloat, centerYAnchor: NSLayoutYAxisAnchor?, paddingCenterY: CGFloat, widthAnchor: NSLayoutDimension?, widthMultiplier: CGFloat, heightAnchor: NSLayoutDimension?, heightMultiplier: CGFloat){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = topAnchor {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = leftAnchor {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottomAnchor {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = rightAnchor {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if let width = widthAnchor {
            self.widthAnchor.constraint(equalTo: width, multiplier: widthMultiplier).isActive = true
        }
        
        if let height = heightAnchor {
            self.heightAnchor.constraint(equalTo: height, multiplier: heightMultiplier).isActive = true
        }
        
        if let centerX = centerXAnchor {
            self.centerXAnchor.constraint(equalTo: centerX, constant: paddingCenterX).isActive = true
        }
        
        if let centerY = centerYAnchor {
            self.centerYAnchor.constraint(equalTo: centerY, constant: paddingCenterY).isActive = true
        }
        
        if widthConstant != 0 {
            self.widthAnchor.constraint(equalToConstant: widthConstant).isActive = true
        }
        
        if heightConstant != 0 {
            self.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        }
    }
}

extension UIColor {
    static func rgb(_ rgb: CGFloat) -> UIColor {
        return self.rgb(red: rgb, green: rgb, blue: rgb)
    }
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let lighterBlue = rgb(red: 149, green: 204, blue: 244)
    static let darkerBlue = rgb(red: 17, green: 154, blue: 237)
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}
