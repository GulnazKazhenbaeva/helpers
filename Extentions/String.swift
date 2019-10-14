//
//  String+Extensions.swift
//
//  Created by Kazhenbayeva Gulnaz on 1/23/19.
//

import UIKit

extension String {
    var localized: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
    
    func textWithoutPhoneMask(_ clearCode: Bool = true) -> String {
        if self.count == 0 {
            return self
        }
        
        var result = self
        
        if clearCode {
            // remove country code 8 or +7
            if result[result.startIndex] == "8" && result.count > 10 {
                result.remove(at: result.startIndex)
            }
            result = result.replacingOccurrences(of: "+7", with: "")
            
        }
        // remove special characters
        result = result.replacingOccurrences(of: " ", with: "")
        result = result.replacingOccurrences(of: "(", with: "")
        result = result.replacingOccurrences(of: ")", with: "")
        result = result.replacingOccurrences(of: "-", with: "")
        
        var cleanResult = ""
        for c in result {
            if CharacterSet.decimalDigits.contains(String(c).unicodeScalars.first!) {
                cleanResult += String(c)
            }
        }
        return cleanResult
    }
    
    var onlyDigits: String {
         return self
                .components(separatedBy:CharacterSet.decimalDigits.inverted)
                .joined(separator: "")
    }
    
    
    func attributed(font: UIFont = AppFont.regular(),
                    color: UIColor = AppColor.title.uiColor,
                    line: Bool = false,
                    lineSpacing: CGFloat = 2) -> NSAttributedString {
        var attr: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font: font,
                                                  NSAttributedString.Key.foregroundColor: color]
        let parStyle = NSMutableParagraphStyle()
        parStyle.lineSpacing = lineSpacing
        attr[NSAttributedString.Key.paragraphStyle] = parStyle
        if line {
            attr[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.patternDot.rawValue | NSUnderlineStyle.single.rawValue
        }
        return NSAttributedString(string: self, attributes: attr)
    }
}

extension String {
    
    func toDigits() -> [Int] {
        return compactMap { Int(String($0)) }
    }
    
    func decimalDigits() -> String {
        let charset = CharacterSet.decimalDigits
        return String(self.unicodeScalars.filter(charset.contains(_:)))
    }
    
    func latinLettersAndDigits() -> String {
        let digitsCharset = CharacterSet.decimalDigits
        let latinCharset = CharacterSet.latinLetters
        return String(
            self.unicodeScalars.filter { scalar -> Bool in
                return digitsCharset.contains(scalar) || latinCharset.contains(scalar)
            }
        )
    }
    
    func inserting(separator: String, every counter: Int) -> String {
        let result = enumerated().reduce("") { char, tuple -> String in
            return tuple.offset != 0 && tuple.offset % counter == 0
                ? (char + separator + String(tuple.element))
                : (char + String(tuple.element))
        }
        return result
    }
    
    /// Format string to amount view
    public var splittedAmount: String? {
        let amountString = replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(amountString) else { return nil }
        let number = NSNumber(value: amount)
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = " "
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: number)
    }
    
    // substring by range (s = 'qwerty'; s[0..<3] will be 'qwe')
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    /// Example: 100.5200 will be formatted to "100.5"
    public var percentAmount: String? {
        let amountString = replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(amountString) else { return nil }
        let number = NSNumber(value: amount)
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = " "
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .floor
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter.string(from: number)
    }
}

extension String {
    
    func getDate() -> Date? {
        return getDate(format: .withoutTimeDot)
    }
    
    func getDate(format: DateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        if format == .month_yyyy {
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        }
        dateFormatter.dateFormat = format.rawValue
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func dateString() -> String {
        return dateString(withFormat: .withTimeDush,
                          toFormat: .month_yyyy)
    }
    
    func dateString(toFormat: DateFormat) -> String {
        return dateString(withFormat: .withoutTimeDot,
                          toFormat: toFormat)
    }
    
    func dateString(withFormat: DateFormat, toFormat: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: AppLangWorker().getLocale())
        dateFormatter.dateFormat = withFormat.rawValue
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = toFormat.rawValue
            let newSt = dateFormatter.string(from: date)
            return newSt
        }
        return self
    }
}

extension String {
    var toInt: Int {
        return Int(self.decimalDigits()) ?? 0
    }
    var toDouble: Double {
        return Double(self.decimalDigits()) ?? 0
    }
    func roundTo(places: Int) -> String {
        guard let argument = Double(self) as? CVarArg else { return self }
        let text = String(format: "%.\(places)f", argument)
        return text
    }
    var fromDoubleToInt: Int {
        return self.toDouble.toInt
    }
    var cleanLastZero: String {
        let doubleSelf = Double(self) ?? 0
        return doubleSelf.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", doubleSelf) : self
    }
    func replaceOf(texts: [String]) -> String {
        var result = self
        for i in 1...texts.count {
            result = result.replacingOccurrences(of: Text.Replace.placeholder + "\(i)", with: texts[i - 1])
        }
        return result
    }
}
