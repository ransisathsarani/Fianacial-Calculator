//
//  MortgageDataSet+CoreDataProperties.swift
//  MyFinanceCalculator
//
//  Created by Ransi on 2022-07-28.
//
//

import Foundation
import CoreData


extension MortgageDataSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MortgageDataSet> {
        return NSFetchRequest<MortgageDataSet>(entityName: "MortgageDataSet")
    }

    @NSManaged public var loanAmount: Double
    @NSManaged public var interest: Double
    @NSManaged public var payment: Double
    @NSManaged public var years: Double
    @NSManaged public var id: String?

}

extension MortgageDataSet : Identifiable {

}
