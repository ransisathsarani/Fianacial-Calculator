//
//  MortgageDataSet+CoreDataClass.swift
//  MyFinanceCalculator
//
//  Created by Ransi on 2022-07-28.
//
//

import Foundation
import CoreData

@objc(MortgageDataSet)
public class MortgageDataSet: NSManagedObject {
    convenience init(loanAmount: Double, interest: Double,payment: Double, years: Double, id:String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        
        self.init(context: context)
        
        self.loanAmount = loanAmount
        self.interest = interest
        self.payment = payment
        self.years = years
        self.id = id
    }

}
