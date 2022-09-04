//
//  AmortizedData.swift
//  MyFinanceCalculator
//
//  Created by Ransi on 2022-07-25.
//

class AmortizedData
{
    var no: String
    var year: String
    var futureVal: String
    var payment: String
    var interest: String

    init(no: String, year: String, futureVal: String, payment: String, interest: String) {
        self.no = no
        self.year = year
        self.futureVal = futureVal
        self.payment = payment
        self.interest = interest

    }
}
