//
//  ViewController.swift
//  Synco
//
//  Created by Alessio De Gaetano on 04/10/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var syncDownButtonOutlet: UIButton!
    @IBOutlet weak var syncUpButtonOutlet: UIButton!
    @IBOutlet weak var resetButtonOutlet: UIButton!
    @IBOutlet weak var switchButtonOutlet: UIButton!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var minRedLabel: UILabel!
    @IBOutlet weak var minGreenLabel: UILabel!
    @IBOutlet weak var minBlueLabel: UILabel!
    @IBOutlet weak var maxRedLabel: UILabel!
    @IBOutlet weak var maxGreenLabel: UILabel!
    @IBOutlet weak var maxBlueLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    
    var db: Firestore!
    var ref: DatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // START SETUP FIREBASE
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        ref = Database.database(url: Constants.getUrl()).reference()    // Replace "Constants.getUrl()" with your Firebase DB URL
        setupListener()
        // END SETUP FIREBASE
        
        let sliders = [redSlider, greenSlider, blueSlider]
        let buttons = [syncDownButtonOutlet, syncUpButtonOutlet, resetButtonOutlet]
        
        for button in buttons {
            button?.clipsToBounds = true
            button?.layer.cornerRadius = 17
            button?.layer.cornerCurve = .continuous
            button?.isHidden = true
        }
        
        for slider in sliders {
            slider?.minimumValue = 0
            slider?.maximumValue = 255
            slider?.isContinuous = true
            
            slider?.addTarget(self, action: #selector(sliderUpdateView), for: UIControl.Event.valueChanged)
            slider?.addTarget(self, action: #selector(sliderUpdateDB), for: UIControl.Event.touchUpInside)
        }
        
        updateView()
    }
    
    
    
    @IBAction func syncDownButtonAction(_ sender: Any) {
        forcedUpdateFromDB()
    }
    
    @IBAction func syncUpButtonAction(_ sender: Any) {
        updateDB(red: redSlider.value, green: greenSlider.value, blue: blueSlider.value)
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        updateDB(red: 255 / 2, green: 255 / 2, blue: 255 / 2)
    }
    
    @IBAction func switchButtonAction(_ sender: Any) {
        let buttons = [syncDownButtonOutlet, syncUpButtonOutlet, resetButtonOutlet]
        
        for button in buttons {
            button?.isHidden.toggle()
        }
    }
    
    
    
    func setupListener() {
        ref.child("colors").observe(DataEventType.value, with: { snapshot in
            
            let value = snapshot.value as? NSDictionary
            let redValue = value!["red"] as! NSNumber
            let greenValue = value!["green"] as! NSNumber
            let blueValue = value!["blue"] as! NSNumber
            
            let red = redValue.floatValue
            let green = greenValue.floatValue
            let blue = blueValue.floatValue
            
            self.updateSliders(red: red, green: green, blue: blue)
        })
    }
    
    
    
    public func forcedUpdateFromDB() {
        ref.child("colors").observeSingleEvent(of: .value, with: { snapshot in
            
            let value = snapshot.value as? NSDictionary
            let redValue = value!["red"] as! NSNumber
            let greenValue = value!["green"] as! NSNumber
            let blueValue = value!["blue"] as! NSNumber
            
            let red = redValue.floatValue
            let green = greenValue.floatValue
            let blue = blueValue.floatValue
            
            self.updateSliders(red: red, green: green, blue: blue)
        }) { error in
          print(error.localizedDescription)
        }
    }
    
    
    
    @objc func sliderUpdateView(slider: UISlider) {
        updateView()
    }
    
    @objc func sliderUpdateDB(slider: UISlider) {
        updateDB(red: redSlider.value, green: greenSlider.value, blue: blueSlider.value)
        updateView()
    }
    
    func updateView() {
        updateView(red: redSlider.value, green: greenSlider.value, blue: blueSlider.value)
        updateLabel(red: redSlider.value, green: greenSlider.value, blue: blueSlider.value)
    }
    
    func updateDB(red redValue: Float, green greenValue: Float, blue blueValue: Float) {
        let myChild = ref.child("colors")
        let dictionary = ["red": redValue, "green": greenValue, "blue": blueValue]
        myChild.setValue(dictionary)
    }
    
    func updateView(red redValue: Float, green greenValue: Float, blue blueValue: Float) {
        colorView.backgroundColor = UIColor(red: CGFloat(redValue) / 255.0,
                                            green: CGFloat(greenValue) / 255.0,
                                            blue: CGFloat(blueValue) / 255.0,
                                            alpha: 1.0)
    }
    
    func updateSliders(red redValue: Float, green greenValue: Float, blue blueValue: Float) {
        redSlider.setValue(redValue, animated: true)
        greenSlider.setValue(greenValue, animated: true)
        blueSlider.setValue(blueValue, animated: true)
        
        updateView()
    }
    
    func updateLabel(red redValue: Float, green greenValue: Float, blue blueValue: Float) {
        currentValueLabel.text = String("R: \(Int(redValue)) " +
                                        "G: \(Int(greenValue)) " +
                                        "B: \(Int(blueValue))")
    }
}

