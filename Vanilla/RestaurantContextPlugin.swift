//
//  RestaurantDataContextPlugin.swift
//  Vanilla
//
//  Created by Alex on 7/12/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import FlybitsContextSDK

// ProprietaryDataProvider allows to create and send proprietary custom context data for evaluating context rules.
public class RestaurantDataContextPlugin: NSObject, ContextPlugin {
    public var pluginID: String = "ctx.rgarestaurant.restaurant"
    public var refreshTime: Int32 = 15
    public var timeUnit: TimeUnit = .seconds
    
    // Initialize proprietary custom data
    public var dietary: String
    public var price: Double
    public var calorie: Double
    
    public init(dietary: String = "", price: Double, calorie: Double = -Double.greatestFiniteMagnitude) {
        self.dietary = dietary
        self.price = price
        self.calorie = calorie
        super.init()
    }
    
    public func refreshData(completion: @escaping (Any?, NSError?) -> Void) {
        
        // Build context data for rules evaluation
        var customData = [String: Any]()
        if dietary != "" {
            customData["dietary"] = dietary
        }
        if price > 0 {
            customData["price"] = price
        }
        if calorie > 0 {
            customData["calorie"] = calorie
        }
        
        completion(customData, nil)
    }
    
    public static func ==(lhs: RestaurantDataContextPlugin, rhs: RestaurantDataContextPlugin) -> Bool {
        
        if lhs.dietary == rhs.dietary && lhs.price == rhs.price && lhs.calorie == rhs.calorie {
            return true
        }
        return false
    }
}
