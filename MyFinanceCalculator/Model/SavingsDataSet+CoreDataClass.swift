//
//  SavingsDataSet+CoreDataClass.swift
//  MyFinanceCalculator
//
//  Created by Ransi on 2022-07-25.
//
//

import Foundation
import CoreData

@objc(SavingsDataSet)
public class SavingsDataSet: NSManagedObject {
    
    convenience init(pv: Double, fv: Double, interest: Double, noOfPayments: Double, noOfCompounds: Double,payment: Double, pmtMadeAt: Int16, id:String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        
        self.init(context: context)
        
        self.presentValue = pv
        self.futureValue = fv
        self.interest = interest
        self.paymentsPerYear = noOfPayments
        self.payment = payment
        self.compoundsPerYear = noOfCompounds
        self.paymentMadeAt = pmtMadeAt
        self.id = id
    }

}
