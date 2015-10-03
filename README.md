# DeepPressGestureRecognizer
UIGestureRecognizer for recognising deep press 3D Touch on iPhone 6s

_Companion project to this blog post: http://flexmonkey.blogspot.com/2015/10/deeppressgesturerecognizer-3d-touch.html_

Back in March, I looked at creating custom gesture recognisers for a single touch rotation in Creating Custom Gesture Recognisers in Swift. With the introduction of 3D Touch in the new iPhone 6s, I thought it would be an interesting exercise to do the same for deep presses. 

My DeepPressGestureRecognizer is an extended UIGestureRecognizer that invokes an action when the press passes a given threshold. Its syntax is the same as any other gesture recogniser, such as long press, and is implemented like so:

    let button = UIButton(type: UIButtonType.System)
    
    button.setTitle("Button with Gesture Recognizer", forState: UIControlState.Normal)

    stackView.addArrangedSubview(button)
    
    let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: self,
        action: "deepPressHandler:",
        threshold: 0.75)
    

    button.addGestureRecognizer(deepPressGestureRecognizer)

The action has the same states as other recognisers too, so when the state is Began, the user's touch's force has passed the threshold:

    func deepPressHandler(value: DeepPressGestureRecognizer)
    {
        if value.state == UIGestureRecognizerState.Began
        {
            print("deep press begin")
        }
        else if value.state == UIGestureRecognizerState.Ended
        {
            print("deep press ends.")
        }

    }

If that's too much code, I've also created a protocol extension which means you get the deep press recogniser simply by having your class implement DeepPressable:

    class DeepPressableButton: UIButton, DeepPressable
    {

    }

...and then setting the appropriate action in setDeepPressAction():

    let deepPressableButton = DeepPressableButton(type: UIButtonType.System)
    deepPressableButton.setDeepPressAction(self, action: "deepPressHandler:")

Sadly, there's no public API to Apple's Taptic Engine (however, there are workarounds as Dal Rupnik discusses here). Rather than using private APIs, my code optionally vibrates the  device when a deep press has been recognised.
Deep Press Gesture Recogniser Mechanics

To extend UIGestureRecognizer, you'll need to add a bridging header to import UIKit/UIGestureRecognizerSubclass.h. Once you have that you're free to override touchesBegan, touchesMoved and touchesEnded. In DeepPressGestureRecognizer, the first of these two methods call handleTouch() which checks either:

If a deep press hasn't been recognised but the current force is above a normalised threshold, then treat that touch event as the beginning of the deep touch gesture.
If a deep press has been recognised and the touch force has dropped below the threshold, treat that touch event as the end of the gesture.

The code for handleTouch() is: 

    private func handleTouch(touch: UITouch)
    {
        guard let view = view where touch.force != 0 && touch.maximumPossibleForce != 0 else
        {
            return
        }

        if !deepPressed && (touch.force / touch.maximumPossibleForce) >= threshold
        {
            view.layer.addSublayer(pulse)
            pulse.pulse(CGRect(origin: CGPointZero, size: view.frame.size))

            state = UIGestureRecognizerState.Began
            
            if vibrateOnDeepPress
            {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
            
            deepPressed = true
        }
        else if deepPressed && (touch.force / touch.maximumPossibleForce) < threshold
        {
            state = UIGestureRecognizerState.Ended
            
            deepPressed = false
        }

    }

In touchesEnded  if a deep touch hasn't been recognised (e.g. the user has lightly tapped a button or changed a slider), I set the gesture's state to Failed:

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesEnded(touches, withEvent: event)
        
        state = deepPressed ?
            UIGestureRecognizerState.Ended :
            UIGestureRecognizerState.Failed
        
        deepPressed = false

    }
Visual Feedback

In the absence of access to the iPhone's Taptic Engine, I decided to add a radiating pulse effect to the source component when the gesture is recognised. This is done by adding a CAShapeLayer to the component's CALayer and transitioning from a rectangle path the size of the component to a much larger one (thanks to Jameson Quave for this article that describes that beautifully). 

To do this, first I two CGPath instances for the beginning and end states:

    let startPath = UIBezierPath(roundedRect: frame,
        cornerRadius: 5).CGPath
    let endPath = UIBezierPath(roundedRect: frame.insetBy(dx: -50, dy: -50),

        cornerRadius: 5).CGPath

Then create three basic animations to grow the path, fade it out by reducing the opacity to zero and fattening the stroke:

    let pathAnimation = CABasicAnimation(keyPath: "path")
    pathAnimation.toValue = endPath
    
    let opacityAnimation = CABasicAnimation(keyPath: "opacity")
    opacityAnimation.toValue = 0
    
    let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")

    lineWidthAnimation.toValue = 10

Inside a single CATransaction  I give all three animations the same properties for duration, timing function, etc. and set them going. Once the animation is finished, I remove the pulse layer from the source component's layer:

    CATransaction.begin()
    
    CATransaction.setCompletionBlock
    {
        self.removeFromSuperlayer()
    }
    
    for animation in [pathAnimation, opacityAnimation, lineWidthAnimation]
    {
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        addAnimation(animation, forKey: animation.keyPath)
    }
    

    CATransaction.commit()
DeepPressable Protocol Extension

I couldn't resist adding a protocol extension to make any class that can add gesture recognisers deep-pressable. The protocol itself has two of my own methods for setting and removing deep press actions:

    func setDeepPressAction(target: AnyObject, action: Selector)
    func removeDeepPressAction()

These are given default behaviour in the extension:

    func setDeepPressAction(target: AnyObject, action: Selector)
    {
        let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: target, action: action, threshold: 0.75)
        
        self.addGestureRecognizer(deepPressGestureRecognizer)
    }
    
    func removeDeepPressAction()
    {
        guard let gestureRecognizers = gestureRecognizers else
        {
            return
        }
        
        for recogniser in gestureRecognizers where recogniser is DeepPressGestureRecognizer
        {
            removeGestureRecognizer(recogniser)
        }

    }
In Conclusion

Without the access to the Taptic Engine, this may not be an ideal interaction experience, however the visual feedback may help mitigate that. However, hopefully this post illustrates how easy it is to integrate 3D Touch information into a custom gesture recogniser. You may want to use this example to create a continuous force gesture recogniser, for example in a drawing application. 

As always, the source code for this project is available in my GitHub repository here.  Enjoy!
