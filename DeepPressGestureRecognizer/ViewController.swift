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
    
    let button = UIButton(type: UIButtonType.system)
    let deepPressableButton = DeepPressableButton(type: UIButtonType.system)
    let slider = DeepPressableSlider()
    let stepper = UIStepper()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(stackView)
   
        // ----
        
        button.setTitle("Button with Gesture Recognizer", for: UIControlState())

        stackView.addArrangedSubview(button)
        
        let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: self, action: #selector(ViewController.deepPressHandler(_:)), threshold: 0.75)
        
        button.addGestureRecognizer(deepPressGestureRecognizer)

        // ----
        
        deepPressableButton.setTitle("DeepPressableButton", for: UIControlState())
  
        stackView.addArrangedSubview(deepPressableButton)

		deepPressableButton.setDeepPressAction(target: self, action: #selector(ViewController.deepPressHandler(_:)))
        
        stackView.addArrangedSubview(button)
    
        // ----
        
		slider.setDeepPressAction(target: self, action: #selector(ViewController.deepPressHandler(_:)))

        slider.addTarget(self, action: #selector(ViewController.sliderChange), for: UIControlEvents.valueChanged)
        
        stackView.addArrangedSubview(slider)
        
        // ----
        
        let deepPressGestureRecognizer_2 = DeepPressGestureRecognizer(target: self, action: #selector(ViewController.deepPressHandler(_:)), threshold: 0.75)
        
        stepper.addGestureRecognizer(deepPressGestureRecognizer_2)
        stepper.addTarget(self, action: #selector(ViewController.stepperChange), for: UIControlEvents.valueChanged)
        
        stackView.addArrangedSubview(stepper)
        
    }

    func deepPressHandler(_ value: DeepPressGestureRecognizer)
    {
        if value.state == .began
        {
            print("deep press begin: ", value.view?.description)
        }
        else if value.state == .ended
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
        stackView.axis = UILayoutConstraintAxis.vertical
        stackView.distribution = UIStackViewDistribution.equalSpacing
        stackView.alignment = UIStackViewAlignment.center
        
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



