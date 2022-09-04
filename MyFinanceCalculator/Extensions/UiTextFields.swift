//
//  UiTextFields.swift
//  MyFinanceCalculator
//
//  Created by Ransi on 2022-07-24.
//

import UIKit

extension UITextField: UITextFieldDelegate {
    
    private struct AssociatedKeys {
        static var customTag = "customTag"
    }

    var customTag: String! {
        get {
            guard let placeholder = objc_getAssociatedObject(self, &AssociatedKeys.customTag) as? String else {
                return String()
            }

            return placeholder
        }

        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.customTag, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // delegate methods
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
           clear()
           return true;
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        clear()
    }
    
    // custom methods
    
    func setDelegate()
    {
        self.delegate = self
    }
    
    // when text field is empty we color it to red and shake
    func errorDetected() {
        
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5;

        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 3, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 3, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
    
    // clear previous drawing changes
    func clear() {
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5;
    }
    
    // when we found an answer we color it to green and shake
    func answerDetected() {
        UserDefaults.standard.set(self.text, forKey: self.customTag!)

        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5;
        
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 3, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 3, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
}
