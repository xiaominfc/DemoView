//
//  UtilsExtension.swift
//  DemoView
//
//  Created by xiaominfc on 2018/6/7.
//  Copyright © 2018 xiaominfc. All rights reserved.
//

import UIKit


extension UIColor {
    convenience init(hex: String) {
        var hexText = hex;
        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hexText = hex.substring(from: index)
        }
        let len = hexText.lengthOfBytes(using: String.Encoding.utf8)
        var alpha:CGFloat = 1.0;

        if (len == 8) {
            let index = hexText.index(hexText.startIndex, offsetBy: 2)
            let alphaScanner = Scanner(string: hexText.substring(to: index))
            var alphaValue: UInt64 = 1;
            alphaScanner.scanHexInt64(&alphaValue)
            alpha = CGFloat(alphaValue) / 0xff
        }
        let scanner = Scanner(string: hexText)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: alpha
        )
    }
}


extension UIImage {
    
    func resized(newSize:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x:0, y:0, width :newSize.width, height:newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}


extension UITableView {
    func instanceCell(identifier :String) -> UITableViewCell {
        if let cell = self.dequeueReusableCell(withIdentifier:identifier) {
            return cell
        }
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        if identifier.hasSuffix(".xml") {
            let doc = XMLDoc.parseFile(file: identifier);
            cell.layoutAndInit(node: doc.rootNode!)
        }
        return cell
    }
}

extension UIViewController {
    convenience init(layout:String) {
        self.init()
        setContentView(layout: layout)
    }
    func setContentView(layout:String) {
        let doc = XMLDoc.parseFile(file: layout)
        self.view.layoutAndInit(node: doc.rootNode!)
    }
}




