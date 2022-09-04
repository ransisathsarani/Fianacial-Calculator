//
//  AmortizedDataController.swift
//  MyFinanceCalculator
//  Uow User Name: w1912434
//  Created by Ransi on 2022-07-25.
//

import UIKit
import Foundation
import CoreData

class AmortizedDataController: UITableViewController {
    
    //variables
    var controllerName: String = ""
    var data = [AmortizedData]()
    var context: NSManagedObjectContext? {
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if controllerName == "Saving" {
            self.fetchSavingsData()
        } else if controllerName == "Loan"{
            self.fetchLoanData()
        }else if controllerName == "Mortgage" {
            self.fetchMortgageData()
        }
        
//        prepareDummyData()

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataIdentifier", for: indexPath) as! AmortizedDataView

        if(indexPath.row == 0)
        {
            cell.no.text = NSLocalizedString("no", comment: "")
            cell.year.text = NSLocalizedString("year", comment: "")
            cell.futureVal.text = NSLocalizedString("futureValue", comment: "")
            cell.interest.text = NSLocalizedString("interest", comment: "")
            cell.payment.text = NSLocalizedString("payment", comment: "")

            cell.backgroundColor = UIColor.lightGray
        }
        else
        {
            let index = indexPath.row - 1
            cell.no.text = data[index].no
            cell.year.text = data[index].year
            cell.futureVal.text = data[index].futureVal
            cell.interest.text = data[index].interest
            cell.payment.text = data[index].payment
        }

        return cell
    }
        
    //Fetch Saving Data
    func fetchSavingsData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"SavingsDataSet")
        do
        {
            let sortById = NSSortDescriptor(key: "id", ascending: false)
                        request.sortDescriptors = [sortById]
            
            let savingData = try self.context?.fetch(request) as! [SavingsDataSet]
            
            if(savingData.count > 0 && data.count < 13){

                savingData.forEach {savingDataObj in
                    
                    data.append(AmortizedData(
                    no: savingDataObj.id ?? "",
                    year: String(savingDataObj.paymentsPerYear),
                    futureVal: String(savingDataObj.futureValue),
                    payment: String(savingDataObj.payment),
                    interest: String(savingDataObj.interest)
                    ))

                }

            }
            else
            {
                print("No results found")
            }
            
//            var start = data.count
//            if data.count == 0{
//                start = 1
//            }
//            for i in start...12 {
//                data.append(AmortizedData(no: String(i), year: "1", futureVal: "1000.00", payment: "200.00", interest: "10.34%"))
//            }
        }
        catch
        {
            print("Error in fetching items")
        }
    }
    
    // Fetch Loan Data
    func fetchLoanData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"LoanDataSet")
        do
        {
            let sortById = NSSortDescriptor(key: "id", ascending: false)
                        request.sortDescriptors = [sortById]
            
            let savingData = try self.context?.fetch(request) as! [LoanDataSet]
            
            if(savingData.count > 0 && data.count < 13){

                savingData.forEach {savingDataObj in
                    
                    data.append(AmortizedData(
                    no: savingDataObj.id ?? "",
                    year: String(savingDataObj.paymentsPerYear),
                    futureVal: String(savingDataObj.futureValue),
                    payment: String(savingDataObj.payment),
                    interest: String(savingDataObj.interest)
                    ))

                }

            }
            else
            {
                print("No results found")
            }
            
            var start = data.count
            if data.count == 0{
                start = 1
            }
            for i in start...12 {
                data.append(AmortizedData(no: String(i), year: "1", futureVal: "1000.00", payment: "200.00", interest: "10.34%"))
            }
        }
        catch
        {
            print("Error in fetching items")
        }
    }
    
    
    // Fetch Mortgage Data
    func fetchMortgageData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"MortgageDataSet")
        do
        {
            let sortById = NSSortDescriptor(key: "id", ascending: false)
                        request.sortDescriptors = [sortById]
            
            let savingData = try self.context?.fetch(request) as! [MortgageDataSet]
            
            if(savingData.count > 0 && data.count < 13){

                savingData.forEach {savingDataObj in
                    
                    data.append(AmortizedData(
                    no: savingDataObj.id ?? "",
                    year: String(savingDataObj.years),
                    futureVal: String(savingDataObj.loanAmount),
                    payment: String(savingDataObj.payment),
                    interest: String(savingDataObj.interest)
                    ))

                }

            }
            else
            {
                print("No results found")
            }
            
            var start = data.count
            if data.count == 0{
                start = 1
            }
            for i in start...12 {
                data.append(AmortizedData(no: String(i), year: "1", futureVal: "1000.00", payment: "200.00", interest: "10.34%"))
            }
        }
        catch
        {
            print("Error in fetching items")
        }
    }
    
    
    //please ignore the dummy data
   func prepareDummyData()
   {
       for i in 1...12 {
           data.append(AmortizedData(no: String(i), year: "1", futureVal: "1000.00", payment: "200.00", interest: "10.34%"))
       }
   }
    
 
}
