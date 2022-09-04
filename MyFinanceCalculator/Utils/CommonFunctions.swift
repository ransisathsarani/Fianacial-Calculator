//
//  CommonFunctions.swift
//  MyFinanceCalculator
//  Uow User Name: w1912434
//  Created by Ransi on 2022-07-24.
//

import Foundation
import UIKit

class CommonFunctions
{
    func getFormattedDecimalDouble(value: Double) -> Double
    {
        return (value * 100).rounded() / 100
    }
    
    func getFormattedDecimalString(value: Double) -> String
    {
        return String(format: "%.02f", value)
    }
}

