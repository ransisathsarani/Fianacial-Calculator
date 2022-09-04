//
//  MortgageViewController.swift
//  MyFinanceCalculator
//  Uow User Name: w1912434
//  Created by Ransi on 2022-07-16.
//

import UIKit
import Foundation
import CoreData

class MortgageViewController: UIViewController, UITextFieldDelegate{
    
    //outlets
    @IBOutlet weak var loanAmountField: UITextField!
    @IBOutlet weak var interestField: UITextField!
    @IBOutlet weak var paymentField: UITextField!
    @IBOutlet weak var yearsField: UITextField!
    @IBOutlet weak var mortgageCalcButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    
    // variables
    let defaults = UserDefaults.standard
    let commonFunctions = CommonFunctions()
    var loanAmount: Double = 0
    var interest: Double = 0
    var payment: Double = 0
    var years: Double = 0
    var mortgageData : MortgageDataSet?
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
        let controllerName : String = "Mortgage"
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
        self.clearMortgageData(sender: clearAllButton)
    }
    
    @objc func clearMortgageData(sender: UIButton)
    {
        clearEachValue(field: loanAmountField)
        clearEachValue(field: interestField)
        clearEachValue(field: paymentField)
        clearEachValue(field: yearsField)

    }

    func clearEachValue(field: UITextField)
    {
        field.text=""
        field.clear()
        defaults.set("", forKey: field.customTag!)
    }
    
    
    // Calculate Button Action
    @IBAction func onMortgageCalculate(_ sender: Any) {
        prepareValues()
        validate()
    }
    
    // custom methods
    func setUpUI()
    {
        initTextField(field: loanAmountField, key: "MLA")
        initTextField(field: yearsField, key: "ML")
        initTextField(field: paymentField, key: "MP")
        initTextField(field: interestField, key: "MI")
        
        mortgageCalcButton.layer.cornerRadius = 18

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
        loanAmount = prepareEachValue(field: loanAmountField)
        interest = prepareEachValue(field: interestField)
        payment = prepareEachValue(field: paymentField)
        years = prepareEachValue(field: yearsField)
        
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
        
    
    func validateTexFields() -> Int {
        var counter = 0
        if !(loanAmountField.text?.isEmpty)! {
            counter += 1
        }
        if !(interestField.text?.isEmpty)! {
            counter += 1
        }
        if !(paymentField.text?.isEmpty)! {
            counter += 1
        }
        if !(yearsField.text?.isEmpty)! {
            counter += 1
        }
        
        return counter
    }
    
    func validate()
    {
        // add all the empty text fields to an array to show textfields in red
        var emptyTF = [UITextField] ()

        // store calculation method in a variable
        var functionToPerform : (() -> ())?

        // we need to perform the calculation on empty field
        if(loanAmountField.tag == 0)
        {
            emptyTF.append(loanAmountField)
            functionToPerform = calculateLoanAmount
        }
        if(interestField.tag == 0)
        {
            emptyTF.append(interestField)
            functionToPerform = calculateInterest
        }
        if(yearsField.tag == 0)
        {
            emptyTF.append(yearsField)
            functionToPerform = calculateNoOfYears
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
            if(loanAmount == 0)
            {
                calculateLoanAmount()
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
    

    
    // calculations (a = payment, b = interest, c = years)
    func calculateLoanAmount()
     {
         let a = payment
         let b = (interest / 100.0) / 12
         let c = years
       
         loanAmount = (a / b) * (1 - (1 / pow(1 + b, c)))
         loanAmountField.text = commonFunctions.getFormattedDecimalString(value: loanAmount)
         loanAmountField.answerDetected()
     }



    func calculateInterest()
    {
        //initial calculation
        var x = 1 + (((payment*years/loanAmount) - 1) / 12)
        
        let financial_precision = Double(0.000001)
        
        func F(_ x: Double) -> Double {
           
            return Double(loanAmount * x * pow(1 + x, years) / (pow(1+x, years) - 1) - payment);
        }
                            
        func FPrime(_ x: Double) -> Double {
            let c_derivative = pow(x+1, years)
            return Double(loanAmount * pow(x+1, years-1) *
                (x * c_derivative + c_derivative - (years*x) - x - 1)) / pow(c_derivative - 1, 2)
        }
        
        while(abs(F(x)) > financial_precision) {
            x = x - F(x) / FPrime(x)
        }

        interest = Double(12 * x * 100)
        interestField.text = commonFunctions.getFormattedDecimalString(value: interest)
        interestField.answerDetected()
    }


    //( a = loan Amount, b = interest, c = years)
    func calculatePayment()
    {
        let a = loanAmount
        let b = (interest / 100.0) / 12
        let c = years
   
        payment = (b * a) / (1 - pow(1 + b, -c))

        paymentField.text = commonFunctions.getFormattedDecimalString(value: payment)
        paymentField.answerDetected()
    }


    // ( a = loan Amount, b = monthly interest rate, c = payment)
    func calculateNoOfYears()
    {
        let a = loanAmount
        let b = (interest / 100.0) / 12
        let c = payment
        let e = c / b
        
        years = (log(e / (e - a)) / log(1 + b))
        yearsField.text = commonFunctions.getFormattedDecimalString(value: years)
        yearsField.answerDetected()
          
            
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

        _ = MortgageDataSet.init(loanAmount: loanAmount,
                               interest: interest,
                               payment: payment,
                               years: years,
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"MortgageDataSet")
        do
        {
            let mortgageData = try self.context?.fetch(request) as! [MortgageDataSet]
            if(mortgageData.count > 0 ){

                mortgageData.forEach {mortgageDataObj in

                     print("------------Mortgage--------------")
                     print("Id",mortgageDataObj.id ?? "")
                     print("Loan Amount",mortgageDataObj.loanAmount)
                     print("Interest Rate",mortgageDataObj.interest)
                     print("Years",mortgageDataObj.years)
                     print("Payment",mortgageDataObj.payment)
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
