//
//  BankingDataContextPlugin.swift
//  Vanilla
//
//  Created by Alex on 7/12/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import FlybitsContextSDK

public class BankingDataContextPlugin: NSObject, ContextPlugin {
    public var pluginID: String = "ctx.rgabanking.banking"
    public var refreshTime: Int32 = 15
    public var timeUnit: TimeUnit = .seconds
    
    // Initialize proprietary custom data
    public var accountBalance: Double
    public var segmentation: String
    public var creditCard: String
    
    public init(accountBalance: Double, segmentation: String = "", creditCard: String = "") {
        self.accountBalance = accountBalance
        self.segmentation = segmentation
        self.creditCard = creditCard
        super.init()
    }
    
    public func refreshData(completion: @escaping (Any?, NSError?) -> Void) {
        
        // Build context data for rules evaluation
        var customData = [String: Any]()
        if accountBalance > 0 {
            customData["accountBalance"] = accountBalance
        }
        if segmentation != "" {
            customData["segmentation"] = segmentation
        }
        if creditCard != "" {
            customData["creditCard"] = creditCard
        }
        
        completion(customData, nil)
    }
    
    public static func ==(lhs: BankingDataContextPlugin, rhs: BankingDataContextPlugin) -> Bool {
        
        if lhs.accountBalance == rhs.accountBalance && lhs.segmentation == rhs.segmentation && lhs.creditCard == rhs.creditCard {
            return true
        }
        return false
    }
}
