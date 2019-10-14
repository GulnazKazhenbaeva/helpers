//
//  AppLangWorker.swift
//  arm_rbk
//
//  Created by Kazhenbayeva Gulnaz on 1/30/19.
//  Copyright © 2019 --. All rights reserved.
//

import UIKit

let kAppleLanguages = "AppleLanguages"

enum Lang: String {
    case kz = "kk"
    case ru = "ru"
    case en = "en"
    
    var code: String {
        switch self {
        case .ru:
            return "ru-ru"
        case .en:
            return "en-en"
        case .kz:
            return "kk-kz"
        }
    }
    
    var name: String {
        switch self {
        case .ru:
            return "Русский"
        case .en:
            return "English"
        case .kz:
            return "Қазақша"
        }
    }
}


class AppLangWorker {

    func getCurrentLang() -> Lang? {
        if let savedLang = UserDefaults.standard.value(forKey: kAppleLanguages) as? [String] {
            if let firstLang = savedLang.first {
                if let lang = Lang.init(rawValue: firstLang) {
                    return lang
                }
            }
        }
        return nil
    }
    
    func setCurrentLang(_ lang: Lang?) {
        guard let lang = lang else {
            return
        }
        
        var langArray = [Lang.en, Lang.ru, Lang.kz]
        if lang == Lang.ru {
            langArray = [Lang.ru, Lang.kz, Lang.en]
        } else if lang == Lang.kz  {
            langArray = [Lang.kz, Lang.en, Lang.ru]
        }
        let languges = langArray.map({
            $0.rawValue
        })
        UserDefaults.standard.setValue(languges, forKey: kAppleLanguages)
        Bundle.setLanguage(lang.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static func getDateCount(_ daysCount: Int) -> String {
        if AppLangWorker().getCurrentLang() == .ru {
            if (daysCount == 11 || daysCount == 12 || daysCount == 13 || daysCount == 14) {
                return "дней";
            }
            else if (daysCount % 10 == 1) {
                return "день";
            }
            else if (daysCount % 10 == 2 || daysCount % 10 == 3 || daysCount % 10 == 4) {
                return "дня";
            }
            else {
                return "дней";
            }
        } else {
            return "day".localized
        }
    }
    
    static func getMonthCount(_ monthCount: Int) -> String {
        if AppLangWorker().getCurrentLang() == .ru {
            if (monthCount == 11 || monthCount == 12 || monthCount == 13 || monthCount == 14) {
                return "месяцев"
            }
            else if (monthCount % 10 == 1) {
                return "месяц"
            }
            else if (monthCount % 10 == 2 || monthCount % 10 == 3 || monthCount % 10 == 4) {
                return  "месяца"
            }
            else {
                return "месяцев"
            }
        } else {
            return "month".localized;
        }
    }
    
    static func getYearCount(_ yearCount: Int) -> String {
        if AppLangWorker().getCurrentLang() == .ru {
            if (yearCount == 11 || yearCount == 12 || yearCount == 13 || yearCount == 14) {
                return "лет"
            }
            else if (yearCount % 10 == 1) {
                return "год"
            }
            else if (yearCount % 10 == 2 || yearCount % 10 == 3 || yearCount % 10 == 4) {
                return  "года"
            }
            else {
                return "лет"
            }

        } else {
            return "year".localized;
        }
    }
}
