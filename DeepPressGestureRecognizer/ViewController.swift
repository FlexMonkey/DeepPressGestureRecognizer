//
//  ViewController.swift
//  DeepPressGestureRecognizer
//
//  Created by SIMON_NON_ADMIN on 03/10/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let stackView = UIStackView()
    
    let button = UIButton(type: UIButtonType.System)
    let deepPressableButton = DeepPressableButton(type: UIButtonType.System)
    let slider = DeepPressableSlider()
    let stepper = UIStepper()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(stackView)
   
        // ----
        
        button.setTitle("Button with Gesture Recognizer", forState: UIControlState.Normal)

        stackView.addArrangedSubview(button)
        
        let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: self, action: "deepPressHandler:", threshold: 0.75)
        
        button.addGestureRecognizer(deepPressGestureRecognizer)

        // ----
        
        deepPressableButton.setTitle("DeepPressableButton", forState: UIControlState.Normal)
  
        stackView.addArrangedSubview(deepPressableButton)

        deepPressableButton.setDeepPressAction(self, action: "deepPressHandler:")
        
        stackView.addArrangedSubview(button)
    
        // ----
        
        slider.setDeepPressAction(self, action: "deepPressHandler:")

        slider.addTarget(self, action: "sliderChange", forControlEvents: UIControlEvents.ValueChanged)
        
        stackView.addArrangedSubview(slider)
        
        // ----
        
        let deepPressGestureRecognizer_2 = DeepPressGestureRecognizer(target: self, action: "deepPressHandler:", threshold: 0.75)
        
        stepper.addGestureRecognizer(deepPressGestureRecognizer_2)
        stepper.addTarget(self, action: "stepperChange", forControlEvents: UIControlEvents.ValueChanged)
        
        stackView.addArrangedSubview(stepper)
        
    }

    func deepPressHandler(value: DeepPressGestureRecognizer)
    {
        if value.state == UIGestureRecognizerState.Began
        {
            print("deep press begin: ", value.view?.description)
        }
        else if value.state == UIGestureRecognizerState.Ended
        {
            print("deep press ends.")
        }
    }
    
    func stepperChange()
    {
        print("stepper change", stepper.value)
    }

    func sliderChange()
    {
        print("slider change", slider.value)
    }
    
    override func viewDidLayoutSubviews()
    {
        stackView.axis = UILayoutConstraintAxis.Vertical
        stackView.distribution = UIStackViewDistribution.EqualSpacing
        stackView.alignment = UIStackViewAlignment.Center
        
        stackView.frame = CGRect(x: 0,
            y: topLayoutGuide.length,
            width: view.frame.width,
            height: view.frame.height - topLayoutGuide.length).insetBy(dx: 50, dy: 100)
    }
}

class DeepPressableButton: UIButton, DeepPressable
{
    
}

class DeepPressableSlider: UISlider, DeepPressable
{
    override func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: 200, height: super.intrinsicContentSize().height)
    }
}



