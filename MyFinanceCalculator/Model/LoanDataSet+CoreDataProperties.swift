//
//  LoanDataSet+CoreDataProperties.swift
//  MyFinanceCalculator
//
//  Created by Ransi on 2022-07-28.
//
//

import Foundation
import CoreData


extension LoanDataSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoanDataSet> {
        return NSFetchRequest<LoanDataSet>(entityName: "LoanDataSet")
    }

    @NSManaged public var presentValue: Double
    @NSManaged public var futureValue: Double
    @NSManaged public var interest: Double
    @NSManaged public var paymentsPerYear: Double
    @NSManaged public var compoundsPerYear: Double
    @NSManaged public var payment: Double
    @NSManaged public var id: String?

}

extension LoanDataSet : Identifiable {

}
