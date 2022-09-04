//
//  LoanViewController.swift
//  MyFinanceCalculator
//  Uow User Name: w1912434
//  Created by Ransi on 2022-07-24.
//

import UIKit
import Foundation
import CoreData

class LoanViewController: UIViewController, UITextFieldDelegate{
    
    //outlets
    @IBOutlet weak var presentValueField: UITextField!
    @IBOutlet weak var futureValueField: UITextField!
    @IBOutlet weak var interestField: UITextField!
    @IBOutlet weak var paymentsPerYearField: UITextField!
    @IBOutlet weak var compoundsPerYearField: UITextField!
    @IBOutlet weak var paymentField: UITextField!
    @IBOutlet weak var loanCalcButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    
    
    // variables
    let defaults = UserDefaults.standard
    let commonFunctions = CommonFunctions()
    var presentValue: Double = 0
    var futureValue: Double = 0
    var interest: Double = 0
    var paymentsPerYear: Double = 0
    var compoundsPerYear: Double = 0
    var payment: Double = 0
    var loanData : LoanDataSet?
    var context: NSManagedObjectContext? {
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setUpUI()
        viewStoredData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let controllerName : String = "Loan"
        let destinationVC = segue.destination as! AmortizedDataController
        destinationVC.controllerName = controllerName
    }
    
    
    //Hide the keyboard
    func hideKeyboardWhenTappedAround() {
            let tapGesture = UITapGestureRecognizer(target: self,
                             action: #selector(hideKeyboard))
            view.addGestureRecognizer(tapGesture)
        }
    
    @objc func hideKeyboard() {
            view.endEditing(true)
        }
    
    
    // Clear All
    @IBAction func onClearAll(_ sender: Any) {
        self.clearLoanData(sender: clearAllButton)
    }
    
    @objc func clearLoanData(sender: UIButton)
    {
        clearEachValue(field: presentValueField)
        clearEachValue(field: futureValueField)
        clearEachValue(field: interestField)
        clearEachValue(field: paymentsPerYearField)
        clearEachValue(field: compoundsPerYearField)
        clearEachValue(field: paymentField)

    }
    
    func clearEachValue(field: UITextField)
    {
        field.text=""
        field.clear()
        defaults.set("", forKey: field.customTag!)
    }
    
    @IBAction func onLoanCalculate(_ sender: Any) {
        prepareValues()
        validate()
    }
    
    func setUpUI()
    {
        initTextField(field: presentValueField, key: "LPV")
        initTextField(field: futureValueField, key: "LFV")
        initTextField(field: interestField, key: "LI")
        initTextField(field: paymentField, key: "LP")
        initTextField(field: paymentsPerYearField, key: "LPY")
        initTextField(field: compoundsPerYearField, key: "LCY")
        
        loanCalcButton.layer.cornerRadius = 18

    }
    
    func initTextField(field: UITextField, key: String)
    {
        // set text field delegate in the extension file - UITextFields
        field.setDelegate()
        
        // set customTag in the extension file - UITextFields
        field.customTag = key
        
        // on item change we store the data in userdefaults
        field.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)

        // restore data from userdefaults
        field.text = defaults.string(forKey: key)
    }
    
    // getting the values of textfields and formatting
    func prepareValues()
    {
        presentValue = prepareEachValue(field: presentValueField)
        futureValue = prepareEachValue(field: futureValueField)
        interest = prepareEachValue(field: interestField)
        paymentsPerYear = prepareEachValue(field: paymentsPerYearField)
        compoundsPerYear = prepareEachValue(field: compoundsPerYearField)
        payment = prepareEachValue(field: paymentField)
       
    }

    func prepareEachValue(field: UITextField) -> Double
    {

        if let value = Double(field.text!) {
            field.tag = 1
            let formattedVal  = commonFunctions.getFormattedDecimalDouble(value: value)
            field.text = commonFunctions.getFormattedDecimalString(value: formattedVal)
            field.clear()
            return formattedVal
        } else {
            // tag is zero when there is no value
            field.tag = 0
            return 0
        }
    }
    
    func validate()
    {
        // add all the empty text fields to an array to show textfields in red
        var emptyTF = [UITextField] ()
        
        // store calculation method in a variable
        var functionToPerform : (() -> ())?

        // we need to perform the calculation on empty field
        if(presentValueField.tag == 0)
        {
            emptyTF.append(presentValueField)
            functionToPerform = calculatePresentValue
        }
        if(futureValueField.tag == 0)
        {
            emptyTF.append(futureValueField)
            functionToPerform = calculateFutureValue
        }
        if(interestField.tag == 0)
        {
            emptyTF.append(interestField)
            functionToPerform = calculateInterest
        }
        if(paymentsPerYearField.tag == 0)
        {
            emptyTF.append(paymentsPerYearField)
            functionToPerform = calculateNoOfPayment
        }
        if(compoundsPerYearField.tag == 0)
        {
            emptyTF.append(compoundsPerYearField)
        }
        
        
        // all fields are filled no empty fields. so display an alert
        if(emptyTF.count == 0)
        {
            displayAlert()
        }
        
        // found exaclty one empty field to perform our operation
        else if(emptyTF.count == 1)
        {
            interest = interest/100 //0.50

            //calculate future value based on PMT
            if(futureValue == 0)
            {
               calculateFutureValue()
            }
            else
            {
                if functionToPerform != nil
                {
                    // we need the payment value only when calculating future value, therefore clear payment value
                    paymentField.text = "0"
                    payment = prepareEachValue(field: paymentField)
                    
                    functionToPerform!()
                }
            }
            
            storeCalculatedData()
        }
        else
        {
            // show red text fields with animation
            emptyTF.forEach {tf in
                tf.errorDetected()
            }
        }
        
    }
    
    // calculations
    func calculatePresentValue()
     {
         let a =  compoundsPerYear * paymentsPerYear
         let b =   1 + (interest/compoundsPerYear)
         presentValue = futureValue / pow(b,a)
         presentValueField.text = commonFunctions.getFormattedDecimalString(value: presentValue)
         presentValueField.answerDetected()
     }
    
    func calculateInterest()
    {
        let a =  1 / (compoundsPerYear * paymentsPerYear)
        let b =  futureValue / presentValue
        interest = (pow(b,a) - 1) * compoundsPerYear * 100
        interestField.text = commonFunctions.getFormattedDecimalString(value: interest)
        interestField.answerDetected()
    }
    
    func calculateNoOfPayment()
    {
        let a =  log(futureValue / presentValue)
        let b =   log(1 + (interest/compoundsPerYear)) * compoundsPerYear
        paymentsPerYear = a/b
        paymentsPerYearField.text = commonFunctions.getFormattedDecimalString(value: paymentsPerYear)
        paymentsPerYearField.answerDetected()
    }
    
    func calculateFutureValue()
    {
        let a = compoundsPerYear * paymentsPerYear
        let b =  1 + (interest/compoundsPerYear)
        futureValue = pow(b,a) * presentValue
        
        futureValue += calculateFutureValueofSeriesBegining(a: a, b: b)
        
        paymentField.text = commonFunctions.getFormattedDecimalString(value: payment)
        futureValueField.text = commonFunctions.getFormattedDecimalString(value: futureValue)
        futureValueField.answerDetected()

    }
    
    func calculateFutureValueofSeriesEnd(a: Double, b: Double) -> Double
    {
        let answer: Double = payment * ((pow(b,a) - 1)/(interest/compoundsPerYear))
        return answer
    }
    
    func calculateFutureValueofSeriesBegining(a: Double, b: Double) -> Double
    {
        let answer: Double = calculateFutureValueofSeriesEnd(a: a, b: b) * b
        return answer
    }
    
    func calculatePayment()
    {
        interest = interest/100
        
        let a =  compoundsPerYear * paymentsPerYear
        let b =   1 + (interest/compoundsPerYear)
        let c = ((pow(b,a) - 1)/(interest/compoundsPerYear))
        
        let futureValueOfSeries: Double = futureValue - (pow(b,a) * presentValue)
        var finalAnswer: Double = 0

    
        finalAnswer = futureValueOfSeries / (c * b)
        
        paymentField.text = commonFunctions.getFormattedDecimalString(value: finalAnswer)
        paymentField.answerDetected()
    }
 
    func displayAlert()
    {
         let alert = UIAlertController(title: "Alert", message: "Please leave one of the values blank to perform the calculation", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default))
         self.present(alert, animated: true, completion: nil)
    }
    

    
    @objc func textFieldDidChange(sender: UITextField)
    {
        defaults.set(sender.text, forKey: sender.customTag!)
    }
    
    // saving old calculations
    func storeCalculatedData()
    {

        let id = String(NSDate().timeIntervalSince1970)

        _ = LoanDataSet.init(presentValue: presentValue,
                             futureValue: futureValue,
                             interest: interest,
                             paymentsPerYear: paymentsPerYear,
                             compoundsPerYear: compoundsPerYear,
                             payment: payment,
                             id: id,
                             insertIntoManagedObjectContext: self.context)
       
        do
        {
                try self.context?.save()
        }
        catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // View Stored data
    func viewStoredData()
    {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"LoanDataSet")
        do
        {
            let loanData = try self.context?.fetch(request) as! [LoanDataSet]
            if(loanData.count > 0 ){

                loanData.forEach {loanDataObj in

                     print("------------Loan--------------")
                     print("Id",loanDataObj.id ?? "")
                     print("Present Value",loanDataObj.presentValue)
                     print("Future Value",loanDataObj.futureValue)
                     print("Interest Value",loanDataObj.interest)
                     print("Compounds Per Year",loanDataObj.compoundsPerYear)
                     print("Payments Per Year",loanDataObj.paymentsPerYear)
                     print("Payment",loanDataObj.payment)
                    
                }


            }
            else
            {
                print("No results found")
            }
        }
        catch
        {
            print("Error in fetching items")
        }
    }
}
