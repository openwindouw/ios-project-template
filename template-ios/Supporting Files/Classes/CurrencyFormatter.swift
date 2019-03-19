//
//  .swift
//  Pods
//
//  Created by Henrique Morbin on 27/03/17.
//
//

import Foundation

public class CurrencyFormatter {
    
    public enum Separator: String {
        case none = ""
        case dot = "."
        case comma = ","
        case space = " "
    }
    
    public enum Prefix: String {
        case none = ""
        case dollar = "U$ "
        case real = "R$ "
    }
    
    //public let doubleValue: Double
    public var decimalSeparator = Separator.dot
    public var thousandSeparator = Separator.comma
    public var prefix = Prefix.none
    public var prefixAttributes: [NSAttributedString.Key : Any]?
    public var integersAttributes: [NSAttributedString.Key : Any]?
    public var decimalsAttributes: [NSAttributedString.Key : Any]?
    
    public init() {}
    
    // MARK: Integer Representation
    
    fileprivate func integerPart(from doubleValue: Double) -> Int64 {
        let numberOfPlaces = 2.0
        let multiplier = pow(10.0, numberOfPlaces)
        let rounded = round(doubleValue * multiplier) / multiplier
        
        return Int64(rounded)
    }
    
    // MARK: Decimal Representation
    
    fileprivate func decimalPart(from doubleValue: Double) -> Int64 {
        let numberOfPlace1s = 3.0
        let multiplier1 = pow(10.0, numberOfPlace1s)
        let rounded1 = round(doubleValue * multiplier1) / multiplier1
        return Int64((rounded1 * multiplier1).rounded()) - (integerPart(from: doubleValue) * Int64(multiplier1))
    }
    
    // MARK: Attributed String
    
    public func attributedString(from doubleValue: Double) -> NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = thousandSeparator.rawValue
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        
        var integerText = formatter.string(from: NSNumber(value: integerPart(from: doubleValue))) ?? "0"
        if integerText == "0" && doubleValue < 0.0 {
            integerText = "-0"
        }
        let moduleDoubleValue = doubleValue < 0.0 ? doubleValue * -1.0 : doubleValue
        var decimalText = String(format: "%03d", decimalPart(from: moduleDoubleValue))
        decimalText.remove(at: decimalText.index(before: decimalText.endIndex))
        decimalText = decimalText.replacingOccurrences(of: "-", with: "")
        
        let attrText = NSMutableAttributedString()
        attrText.append(NSAttributedString(string: prefix.rawValue, attributes: prefixAttributes))
        attrText.append(NSAttributedString(string: integerText, attributes: integersAttributes))
        attrText.append(NSAttributedString(string: decimalSeparator.rawValue, attributes: decimalsAttributes))
        attrText.append(NSAttributedString(string: decimalText, attributes: decimalsAttributes))
        
        return attrText
    }
    
    public func attributedString(from textValue: String) -> NSAttributedString {
        let doubleValue = double(from: textValue)
        return attributedString(from: doubleValue)
    }
    
    // MARK: String
    
    public func string(from doubleValue: Double) -> String {
        return attributedString(from: doubleValue).string
    }
    
    public func string(from textValue: String) -> String {
        let doubleValue = double(from: textValue)
        return attributedString(from: doubleValue).string
    }

    // MARK: Double Representation
    
    public func double(from textValue: String) -> Double {
        let cleannedText = textValue.cleanned
        let doubleValue = (Double(cleannedText) ?? 0)/100
        return doubleValue
    }

}

fileprivate extension String {
    var cleanned: String {
        let cleanned = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if contains("-") {
            return "-\(cleanned)"
        } else {
            return cleanned
        }
    }
}

