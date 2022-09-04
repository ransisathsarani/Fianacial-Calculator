//
//  LoanDataSet+CoreDataClass.swift
//  MyFinanceCalculator
//
//  Created by Ransi on 2022-07-28.
//
//

import Foundation
import CoreData

@objc(LoanDataSet)
public class LoanDataSet: NSManagedObject {
    convenience init(presentValue: Double, futureValue: Double, interest: Double, paymentsPerYear: Double, compoundsPerYear: Double,payment: Double, id:String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        
        self.init(context: context)
        
        self.presentValue = presentValue
        self.futureValue = futureValue
        self.interest = interest
        self.paymentsPerYear = paymentsPerYear
        self.payment = payment
        self.compoundsPerYear = compoundsPerYear
        self.id = id
    }

}
