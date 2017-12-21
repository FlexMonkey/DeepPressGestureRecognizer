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
   
        // MARK: Setup UIButton
        
        button.setTitle("Button with Gesture Recognizer", for: UIControlState.normal)

        stackView.addArrangedSubview(button)
        
        let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: self, action: #selector(deepPressHandler(value:)), threshold: 0.75)
        
        button.addGestureRecognizer(deepPressGestureRecognizer)

        // MARK: Setup DeepPressableButton
        
        deepPressableButton.setTitle("DeepPressableButton", for: UIControlState.normal)
  
        stackView.addArrangedSubview(deepPressableButton)

        deepPressableButton.setDeepPressAction(target: self, action: #selector(deepPressHandler(value:)))
        
        stackView.addArrangedSubview(button)
    
        // MARK: Setup DeepPressableSlider
        
        slider.setDeepPressAction(target: self, action: #selector(deepPressHandler(value:)))
        
        slider.addTarget(self, action: #selector(sliderChange), for: UIControlEvents.valueChanged)
        stackView.addArrangedSubview(slider)
        
        stackView.addConstraint(NSLayoutConstraint(item: slider, attribute: .width, relatedBy: .equal, toItem: stackView, attribute: .width, multiplier: 1.0, constant:0))
        
        // MARK: Setup UIStepper
        
        let deepPressGestureRecognizer_2 = DeepPressGestureRecognizer(target: self, action: #selector(deepPressHandler(value:)), threshold: 0.75)
        
        stepper.addGestureRecognizer(deepPressGestureRecognizer_2)
        stepper.addTarget(self, action: #selector(stepperChange), for: UIControlEvents.valueChanged)
        
        stackView.addArrangedSubview(stepper)
        
    }

    @objc func deepPressHandler(value: DeepPressGestureRecognizer)
    {
        if value.state == UIGestureRecognizerState.began
        {
            print("deep press begin: ", value.view?.description as Any)
        }
        else if value.state == UIGestureRecognizerState.ended
        {
            print("deep press ends.")
        }
    }
    
    @objc func stepperChange()
    {
        print("stepper change", stepper.value)
    }

    @objc func sliderChange()
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
    func intrinsicContentSize() -> CGSize
    {
        return CGSize(width: 200, height: super.intrinsicContentSize.height)
    }
}



