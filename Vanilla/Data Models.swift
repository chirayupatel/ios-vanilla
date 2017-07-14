//
//  TextOnlyContent.swift
//  Vanilla
//
//  Created by Alex on 7/12/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import FlybitsKernelSDK

enum ContentError: Error {
    case missingRepresentationDictionary
    case missingLocalizationsDictionary
    case missingProperty(String)
    case dataMismatch(String)
    case deserializationError(String)
}

struct Constant {
    static let textTitle = "txtTitle"
    static let textDescription = "txtDescription"
    static let imageURL = "img"
    static let localizations = "localizations"
}

class TextOnlyContent: ContentData {
    let textTitle: LocalizedObject<String>
    let textDescription: LocalizedObject<String>
    
    required init(data: Any) throws {
        guard let representation = data as? [String: Any] else {
            throw ContentError.missingRepresentationDictionary
        }
        guard let localizations = representation[Constant.localizations] as? [String: [String: Any]] else {
            throw ContentError.missingLocalizationsDictionary
        }
        self.textTitle = LocalizedObject<String>(key: Constant.textTitle, localizations: localizations)
        self.textDescription = LocalizedObject<String>(key: Constant.textDescription, localizations: localizations)
        try! super.init(data: data)
    }
}

class ImageOnlyContent: ContentData {
    let imageURL: URL
    
    required init(data: Any) throws {
        guard let representation = data as? [String: Any] else {
            throw ContentError.missingRepresentationDictionary
        }
        guard let url = URL(string: representation[Constant.imageURL] as! String) else {
            throw ContentError.dataMismatch("String to URL")
        }
        self.imageURL = url
        try! super.init(data: data)
    }
}

class MixedContent: ContentData {
    let textTitle: LocalizedObject<String>
    let textDescription: LocalizedObject<String>
    let imageURL: URL
    
    required init(data: Any) throws {
        guard let representation = data as? [String: Any] else {
            throw ContentError.missingRepresentationDictionary
        }
        guard let localizations = representation[Constant.localizations] as? [String: [String: Any]] else {
            throw ContentError.missingLocalizationsDictionary
        }
        self.textTitle = LocalizedObject<String>(key: Constant.textTitle, localizations: localizations)
        self.textDescription = LocalizedObject<String>(key: Constant.textDescription, localizations: localizations)
        
        guard let url = URL(string: representation[Constant.imageURL] as! String) else {
            throw ContentError.dataMismatch("String to URL")
        }
        self.imageURL = url
        try! super.init(data: data)
    }
}
