//
//  BankingDataContextPlugin.swift
//  Vanilla
//
//  Created by Alex on 7/12/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import FlybitsContextSDK

protocol DictionaryConvertible {
    func toDictionary() -> [String: Any]
}

public class BankingDataContextPlugin: NSObject, ContextPlugin, DictionaryConvertible {

    public var pluginID: String = "ctx.rgabanking.banking"
    public var refreshTime: Int32 = 15
    public var timeUnit: TimeUnit = .seconds
    
    // Initialize proprietary custom data
    public var accountBalance: Double?
    public var segmentation: String?
    public var creditCard: String?
    
    public init(accountBalance: Double?, segmentation: String?, creditCard: String?) {
        self.accountBalance = accountBalance
        self.segmentation = segmentation
        self.creditCard = creditCard
        super.init()
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let accountBalance = accountBalance {
            dictionary["accountBalance"] = accountBalance
        }
        if let segmentation = segmentation {
            dictionary["segmentation"] = segmentation
        }
        if let creditCard = creditCard {
            dictionary["creditCard"] = creditCard
        }
        return dictionary
    }
    
    public func refreshData(completion: @escaping (Any?, NSError?) -> ()) {
        
        // Build context data for rules evaluation
        let customData = toDictionary()
        
        completion(customData, nil)
    }
    
    public static func ==(lhs: BankingDataContextPlugin, rhs: BankingDataContextPlugin) -> Bool {
        
        if lhs.accountBalance == rhs.accountBalance && lhs.segmentation == rhs.segmentation && lhs.creditCard == rhs.creditCard {
            return true
        }
        return false
    }
}
