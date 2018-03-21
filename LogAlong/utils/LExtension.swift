//
//  LExtension.swift
//  LogAlong
//
//  Created by Michael Gao on 12/3/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LA {
    static func valueAsCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSNumber)!
    }

    static func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }

    static func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBytes {
            $0.baseAddress!.load(as: T.self)
        }
    }

    static func ymd(date: Date) -> (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date) - 1
        let day = calendar.component(.day, from: date)
        return (year, month, day)
    }

    static func ymd() -> (year: Int, month: Int, day: Int) {
        return ymd(date: Date())
    }

    static func ymd(milliseconds: Int64) -> (year: Int, month: Int, day: Int) {
        let date = Date(milliseconds: milliseconds)
        return ymd(date: date)
    }

    static func nextYM(year: Int, month: Int) -> (year: Int, month: Int) {
        var m = month + 1
        var y = year
        if (m > 11) {
            y += 1
            m = 0
        }
        return (y, m)
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    subscript (bounds: PartialRangeUpTo<Int>) -> String {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[startIndex..<end])
    }

    subscript (bounds: PartialRangeThrough<Int>) -> String {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[startIndex...end])
    }

    subscript (bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        return String(self[start..<endIndex])
    }

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    func indexOf(_ input: String,
                 options: String.CompareOptions = .literal) -> String.Index? {
        return self.range(of: input, options: options)?.lowerBound
    }

    func lastIndexOf(_ string: String) -> Int? {
        guard let index = range(of: string, options: .backwards) else { return nil }
        return self.distance(from: self.startIndex, to: index.lowerBound)
    }
}

extension UIColor {
    public convenience init(hex: UInt32) {
        let r, g, b: CGFloat
        var a: CGFloat

        a = CGFloat((hex & 0xff000000) >> 24) / 255
        r = CGFloat((hex & 0x00ff0000) >> 16) / 255
        g = CGFloat((hex & 0x0000ff00) >> 8) / 255
        b = CGFloat(hex & 0x000000ff) / 255

        if a == 0 {
            a = 1.0
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Date {
    var currentTimeMillis: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }

    init (year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        var comp = DateComponents()
        comp.year = year
        comp.month = month + 1
        comp.day = day
        comp.hour = 0
        comp.minute = 0
        comp.second = 0
        self = calendar.date(from: comp)!
    }
}

extension UIView {
    func setSize(w: CGFloat, h: CGFloat) {
        if #available(iOS 11.0, *) {
            self.widthAnchor.constraint(equalToConstant: w).isActive = true
            self.heightAnchor.constraint(equalToConstant: h).isActive = true
        } else {
            self.frame = CGRect(x: 0, y: 0, width: w, height: h)
        }
    }
}

extension UIImage {
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height

        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }

        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }

    func image(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}


extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }

        if let tab = self as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }

        if self.presentedViewController == nil {
            return self
        }

        if let navigation = self.presentedViewController as? UINavigationController {
            if let visibleController = navigation.visibleViewController {
                return visibleController.topMostViewController()
            }
        }

        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

extension DispatchQueue {
    static func userInteractive(delay: Double = 0.0, job: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            job?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

    static func userInitiate(delay: Double = 0.0, job: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            job?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

    static func utility(delay: Double = 0.0, job: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            job?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

    static func background(delay: Double = 0.0, job: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            job?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
