//
//  SavingsDataSet+CoreDataProperties.swift
//  MyFinanceCalculator
//
//  Created by Ransi on 2022-07-25.
//
//

import Foundation
import CoreData


extension SavingsDataSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavingsDataSet> {
        return NSFetchRequest<SavingsDataSet>(entityName: "SavingsDataSet")
    }

    @NSManaged public var paymentsPerYear: Double
    @NSManaged public var presentValue: Double
    @NSManaged public var compoundsPerYear: Double
    @NSManaged public var futureValue: Double
    @NSManaged public var id: String?
    @NSManaged public var interest: Double
    @NSManaged public var payment: Double
    @NSManaged public var paymentMadeAt: Int16

}

extension SavingsDataSet : Identifiable {

}
