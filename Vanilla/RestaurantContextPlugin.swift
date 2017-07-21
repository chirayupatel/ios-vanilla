//
//  RestaurantDataContextPlugin.swift
//  Vanilla
//
//  Created by Alex on 7/12/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import FlybitsContextSDK

// ProprietaryDataProvider allows to create and send proprietary custom context data for evaluating context rules.
public class RestaurantDataContextPlugin: NSObject, ContextPlugin, DictionaryConvertible {
    public var pluginID: String = "ctx.rgarestaurant.restaurant"
    public var refreshTime: Int32 = 15
    public var timeUnit: TimeUnit = .seconds
    
    // Initialize proprietary custom data
    public var dietary: String?
    public var price: Double?
    public var calorie: Double?
    
    public init(dietary: String?, price: Double?, calorie: Double? = -Double.greatestFiniteMagnitude) {
        self.dietary = dietary
        self.price = price
        self.calorie = calorie
        super.init()
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let dietary = dietary {
            dictionary["dietary"] = dietary
        }
        if let price = price {
            dictionary["price"] = price
        }
        if let calorie = calorie {
            dictionary["calorie"] = calorie
        }
        return dictionary
    }
    
    public func refreshData(completion: @escaping (Any?, NSError?) -> ()) {
        
        // Build context data for rules evaluation
        let customData = toDictionary()
        
        completion(customData, nil)
    }
    
    public static func ==(lhs: RestaurantDataContextPlugin, rhs: RestaurantDataContextPlugin) -> Bool {
        
        if lhs.dietary == rhs.dietary && lhs.price == rhs.price && lhs.calorie == rhs.calorie {
            return true
        }
        return false
    }
}
