//
//  SavingsViewController.swift
//  MyFinanceCalculator
//  Uow User Name: w1912434
//  Created by Ransi on 2022-07-16.
//

import UIKit
import Foundation
import CoreData

class SavingsViewController: UIViewController, UITextFieldDelegate{
    
    //outlets
    @IBOutlet weak var presentValueField: UITextField!
    @IBOutlet weak var futureValueField: UITextField!
    @IBOutlet weak var interestField: UITextField!
    @IBOutlet weak var paymentsPerYearField: UITextField!
    @IBOutlet weak var compoundsPerYearField: UITextField!
    @IBOutlet weak var paymentField: UITextField!
    @IBOutlet weak var plusMinusSeg: UISegmentedControl!
    @IBOutlet weak var paymentMadeAtSeg: UISegmentedControl!
    @IBOutlet weak var savingsCalcButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    
    
    // variables
    let defaults = UserDefaults.standard
    let commonFunctions = CommonFunctions()
    var noOfPayments: Double = 0
    var futureValue: Double = 0
    var presentValue: Double = 0
    var interestRate: Double = 0
    var payment: Double = 0
    var noOfCompounds: Double = 0
    var isPMTEnd: Bool = true
    var savingsData : SavingsDataSet?
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
        
        let controllerName : String = "Saving"
        let destinationVC = segue.destination as! AmortizedDataController
        destinationVC.controllerName = controllerName
    }
    
    // Hide the keyboard
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
        self.clearSavings(sender: clearAllButton)
    }
    
    @objc func clearSavings(sender: UIButton)
    {
        clearEachValue(field: presentValueField)
        clearEachValue(field: futureValueField)
        clearEachValue(field: interestField)
        clearEachValue(field: paymentField)
        clearEachValue(field: paymentsPerYearField)
        clearEachValue(field: compoundsPerYearField)
        
    }
    
    func clearEachValue(field: UITextField)
    {
        field.text=""
        field.clear()
        defaults.set("", forKey: field.customTag!)
    }
    
    
    // Calculate Button Action
    @IBAction func onCalculateSavings(_ sender: Any) {
        prepareValues()
        validate()
        
    }
    
    @IBAction func onPaymentMadeAtChange(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "LPMA")
    }
    
    // custom methods
    func setUpUI()
    {
        initTextField(field: presentValueField, key: "SPV")
        initTextField(field: futureValueField, key: "SFV")
        initTextField(field: interestField, key: "SI")
        initTextField(field: paymentField, key: "SPMT")
        initTextField(field: paymentsPerYearField, key: "SPY")
        initTextField(field: compoundsPerYearField, key: "LCY")
        
        savingsCalcButton.layer.cornerRadius = 18

        // restore data from userdefaults
        if defaults.object(forKey: "LPMA") != nil
        {
            paymentMadeAtSeg.selectedSegmentIndex = defaults.integer(forKey: "LPMA")
        }
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
        interestRate = prepareEachValue(field: interestField)
        payment = prepareEachValue(field: paymentField)
        noOfPayments = prepareEachValue(field: paymentsPerYearField)
        noOfCompounds = prepareEachValue(field: compoundsPerYearField)
        isPMTEnd = paymentMadeAtSeg.selectedSegmentIndex == 1 ? true : false
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
            interestRate = interestRate/100

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
         let a =  noOfCompounds * noOfPayments
         let b =   1 + (interestRate/noOfCompounds)
         presentValue = futureValue / pow(b,a)
         presentValueField.text = commonFunctions.getFormattedDecimalString(value: presentValue)
         presentValueField.answerDetected()
     }
    
    func calculateInterest()
    {
        let a =  1 / (noOfCompounds * noOfPayments)
        let b =  futureValue / presentValue
        interestRate = (pow(b,a) - 1) * noOfCompounds * 100
        interestField.text = commonFunctions.getFormattedDecimalString(value: interestRate)
        interestField.answerDetected()
    }
    
    func calculateNoOfPayment()
    {
        let a =  log(futureValue / presentValue)
        let b =   log(1 + (interestRate/noOfCompounds)) * noOfCompounds
        noOfPayments = a/b
        paymentsPerYearField.text = commonFunctions.getFormattedDecimalString(value: noOfPayments)
        paymentsPerYearField.answerDetected()
    }
    
    func calculateFutureValue()
    {
        let a = noOfCompounds * noOfPayments
        let b =  1 + (interestRate/noOfCompounds)
        futureValue = pow(b,a) * presentValue
        
        if(payment > 0)
        {
            if(isPMTEnd)
            {
                futureValue += calculateFutureValueofSeriesEnd(a: a, b: b)
            }
            else
            {
                futureValue += calculateFutureValueofSeriesBegining(a: a, b: b)
            }
        }
        
        paymentField.text = commonFunctions.getFormattedDecimalString(value: payment)
        futureValueField.text = commonFunctions.getFormattedDecimalString(value: futureValue)
        futureValueField.answerDetected()

    }
    

    func calculateFutureValueofSeriesEnd(a: Double, b: Double) -> Double
    {
        let answer: Double = payment * ((pow(b,a) - 1)/(interestRate/noOfCompounds))
        return answer
    }

    func calculateFutureValueofSeriesBegining(a: Double, b: Double) -> Double
    {
        let answer: Double = calculateFutureValueofSeriesEnd(a: a, b: b) * b
        return answer
    }
    
    
    func calculatePayment()
    {
        interestRate = interestRate/100
        
        let a =  noOfCompounds * noOfPayments
        let b =   1 + (interestRate/noOfCompounds)
        let c = ((pow(b,a) - 1)/(interestRate/noOfCompounds))
        
        let futureValueOfSeries: Double = futureValue - (pow(b,a) * presentValue)
        var finalAnswer: Double = 0

        if(isPMTEnd)
        {
            finalAnswer = futureValueOfSeries / c
        }
        else
        {
            finalAnswer = futureValueOfSeries / (c * b)
        }
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

        let pmtMadeAt : Int16 = Int16(paymentMadeAtSeg.selectedSegmentIndex)
        let id = String(NSDate().timeIntervalSince1970)

        _ = SavingsDataSet.init(pv: presentValue,
                               fv: futureValue,
                               interest: interestRate,
                               noOfPayments: noOfPayments,
                               noOfCompounds: noOfCompounds,
                               payment: payment,
                               pmtMadeAt: pmtMadeAt,
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"SavingsDataSet")
        do
        {
            let savingData = try self.context?.fetch(request) as! [SavingsDataSet]
            if(savingData.count > 0 ){

                savingData.forEach {savingDataObj in

                     print("-----------Savings---------------")
                     print("Id",savingDataObj.id ?? "")
                     print("Present Value",savingDataObj.presentValue)
                     print("Future Value",savingDataObj.futureValue)
                     print("Interest Value",savingDataObj.interest)
                     print("Compounds Per Year",savingDataObj.compoundsPerYear)
                     print("Payments Per Year",savingDataObj.paymentsPerYear)
                     print("Payment",savingDataObj.payment)
                     print("Payment Made At",savingDataObj.paymentMadeAt)
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
