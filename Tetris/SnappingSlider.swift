

import UIKit

public protocol SnappingSliderDelegate: class {
    
    func snappingSliderDidIncrementValue(slider:SnappingSlider)
    func snappingSliderDidDecrementValue(slider:SnappingSlider)
    func snappingSliderDidUpVlaue(slider:SnappingSlider)
    func snappingSliderDidDownVlaue(slider:SnappingSlider)
}

public class SnappingSlider: UIView {

    final public weak var delegate:SnappingSliderDelegate?

    final public var incrementAndDecrementLabelFont:UIFont = UIFont(name: "TrebuchetMS-Bold", size: 18.0)! {
        didSet {
            setNeedsLayout()
        }
    }
    final public var incrementAndDecrementLabelTextColor:UIColor = UIColor(red:158/255, green:158/255, blue:158/255, alpha:1) {
        didSet {
            setNeedsLayout()
        }
    }
    final public var incrementAndDecrementBackgroundColor:UIColor = UIColor(red:221/255, green:221/255, blue:221/255, alpha:1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    final public var sliderColor:UIColor = UIColor(red:158/255, green:158/255, blue:158/255, alpha:1) {
        didSet {
            setNeedsLayout()
        }
    }
    final public var sliderTitleFont:UIFont = UIFont(name: "TrebuchetMS-Bold", size: 15.0)! {
        didSet {
            setNeedsLayout()
        }
    }
    final public var sliderTitleColor:UIColor = UIColor.whiteColor() {
        didSet {
            setNeedsLayout()
        }
    }
    final public var sliderTitleText:String = "Slide Me" {
        didSet {
            setNeedsLayout()
        }
    }
    
    final public var sliderCornerRadius:CGFloat = 3.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    final private let sliderContainer = UIView(frame: CGRectZero)
    final private let minusLabel = UILabel(frame: CGRectZero)
    final private let plusLabel = UILabel(frame: CGRectZero)
    
    final private let upLabel = UILabel(frame: CGRectZero)
    final private let downLabel = UILabel(frame: CGRectZero)
    
    final private let sliderView = UIView(frame: CGRectZero)
    final private let sliderViewLabel = UILabel(frame: CGRectZero)
    
    final private var isCurrentDraggingSlider = false
    final private var lastDelegateFireOffset = CGFloat(0)
    
    final private var lastDelegateFireOffsetY = CGFloat(0)
    final private var touchesBeganPoint = CGPointZero
    
    final private let sliderPanGestureRecogniser = UIPanGestureRecognizer()
    final private let dynamicButtonAnimator = UIDynamicAnimator()
    final private var snappingBehavior:SliderSnappingBehavior?

    final private let sliderButton: CGFloat = 80.0
    
    // MARK: Init & View Lifecycle

    public init(frame:CGRect, title:String) {

        super.init(frame: frame)

        sliderTitleText = title
        setup()
        setNeedsLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        setup()
        setNeedsLayout()
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        if snappingBehavior?.snappingPoint.x != center.x {
        
            snappingBehavior = SliderSnappingBehavior(item: sliderView, snapToPoint: CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5))
            lastDelegateFireOffset = sliderView.center.x
        }
        
        if snappingBehavior?.snappingPoint.y != center.y {
            
            snappingBehavior = SliderSnappingBehavior(item: sliderView, snapToPoint: CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5))
            lastDelegateFireOffsetY = sliderView.center.y
        }

        
        sliderContainer.frame = frame
        print(frame)
        print(bounds)
        sliderContainer.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5)
        sliderContainer.backgroundColor = incrementAndDecrementBackgroundColor

        minusLabel.frame = CGRectMake(0.0, 0.0, bounds.size.width * 0.25, bounds.size.height)
        minusLabel.center = CGPointMake(minusLabel.bounds.size.width * 0.5, bounds.size.height * 0.5)
        minusLabel.backgroundColor = incrementAndDecrementBackgroundColor
        minusLabel.font = incrementAndDecrementLabelFont
        minusLabel.textColor = incrementAndDecrementLabelTextColor
        
        plusLabel.frame = CGRectMake(0.0, 0.0, bounds.size.width * 0.25, bounds.size.height)
        plusLabel.center = CGPointMake(bounds.size.width - plusLabel.bounds.size.width * 0.5, bounds.size.height * 0.5)
        plusLabel.backgroundColor = incrementAndDecrementBackgroundColor
        plusLabel.font = incrementAndDecrementLabelFont
        plusLabel.textColor = incrementAndDecrementLabelTextColor
        
        
        upLabel.frame = CGRectMake(0.0, 0.0, bounds.size.width * 0.25, bounds.size.height * 0.25)
        upLabel.center = CGPointMake(bounds.width * 0.5,  upLabel.bounds.height * 0.5)
        upLabel.backgroundColor = incrementAndDecrementBackgroundColor
        upLabel.font = incrementAndDecrementLabelFont
        upLabel.textColor = incrementAndDecrementLabelTextColor
            
        downLabel.frame = CGRectMake(0.0, 0.0, bounds.size.width * 0.25, bounds.size.height * 0.25)
        downLabel.center = CGPointMake(bounds.width * 0.5,  bounds.size.height - upLabel.bounds.height * 0.5)
        downLabel.backgroundColor = incrementAndDecrementBackgroundColor
        downLabel.font = incrementAndDecrementLabelFont
        downLabel.textColor = incrementAndDecrementLabelTextColor

        sliderView.frame = CGRectMake(0.0, 0.0, bounds.size.width * 0.5, bounds.size.height * 0.5)
        sliderView.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5)
        sliderView.backgroundColor = sliderColor
        
        sliderViewLabel.frame = CGRectMake(0.0, 0.0, sliderView.bounds.size.width, sliderView.bounds.size.height)
        sliderViewLabel.center = CGPointMake(sliderView.bounds.size.width * 0.5, sliderView.bounds.size.height * 0.5)
        sliderViewLabel.backgroundColor = sliderColor
        sliderViewLabel.font = incrementAndDecrementLabelFont
        sliderViewLabel.text = sliderTitleText
        

        
        layer.cornerRadius = sliderCornerRadius
    }
    
    // MARK: Gesture Handling
    
    final func handleGesture(sender: UIGestureRecognizer) {

        if sender as NSObject == sliderPanGestureRecogniser {
        
            switch sender.state {
             
            case .Began:
                
                isCurrentDraggingSlider = true
                touchesBeganPoint = sliderPanGestureRecogniser.translationInView(sliderView)
                dynamicButtonAnimator.removeBehavior(snappingBehavior!)
                lastDelegateFireOffset = (bounds.size.width * 0.5) + ((touchesBeganPoint.x + touchesBeganPoint.x) * 0.40)
                
                lastDelegateFireOffsetY = (bounds.size.height * 0.5) + ((touchesBeganPoint.y + touchesBeganPoint.y) * 0.40)
                
            case .Changed:
                
                let translationInView = sliderPanGestureRecogniser.translationInView(sliderView)
                
                let translatedCenterX:CGFloat = (bounds.size.width * 0.5) + ((touchesBeganPoint.x + translationInView.x) * 0.40)
                sliderView.center = CGPointMake(translatedCenterX, sliderView.center.y);
                
                if (translatedCenterX < lastDelegateFireOffset) {
                    
                    if (fabs(lastDelegateFireOffset - translatedCenterX) >= (sliderView.bounds.size.width * 0.15)) {
                        
                        delegate?.snappingSliderDidDecrementValue(self)
                        lastDelegateFireOffset = translatedCenterX
                    }
                }
                else {
                    
                    if (fabs(lastDelegateFireOffset - translatedCenterX) >= (sliderView.bounds.size.width * 0.15)) {
                        
                        delegate?.snappingSliderDidIncrementValue(self)
                        lastDelegateFireOffset = translatedCenterX
                    }
                }
                
                let translatedCenterY:CGFloat = (bounds.size.height * 0.5) + ((touchesBeganPoint.y + translationInView.y) * 0.40)
                sliderView.center = CGPointMake(sliderView.center.x, translatedCenterY);
                
                if (translatedCenterY < lastDelegateFireOffsetY) {
                    
                    if (fabs(lastDelegateFireOffsetY - translatedCenterY) >= (sliderView.bounds.size.height * 0.15)) {
                        
                        delegate?.snappingSliderDidUpVlaue(self)
                        lastDelegateFireOffsetY = translatedCenterY
                    }
                }
                else {
                    
                    if (fabs(lastDelegateFireOffsetY - translatedCenterY) >= (sliderView.bounds.size.height * 0.15)) {
                        
                        delegate?.snappingSliderDidDownVlaue(self)
                        lastDelegateFireOffsetY = translatedCenterY
                    }
                }

                
            case .Ended:

                fallthrough
                
            case .Failed:

                fallthrough

            case .Cancelled:
                
                dynamicButtonAnimator.addBehavior(snappingBehavior!)
                isCurrentDraggingSlider = false
                lastDelegateFireOffset = center.x
                lastDelegateFireOffsetY = center.y

            case .Possible:

                // Swift requires at least one statement per case
                let x = 0
            }
        }
        
    }

    private func setup() {
        sliderContainer.backgroundColor = backgroundColor

        minusLabel.text = "L"
        minusLabel.textAlignment = NSTextAlignment.Center
        sliderContainer.addSubview(minusLabel)

        plusLabel.text = "R"
        plusLabel.textAlignment = NSTextAlignment.Center
        sliderContainer.addSubview(plusLabel)
        

        
        upLabel.text = "U"
        upLabel.textAlignment = NSTextAlignment.Center
        sliderContainer.addSubview(upLabel)
        
        downLabel.text = "D"
        downLabel.textAlignment = NSTextAlignment.Center
        sliderContainer.addSubview(downLabel)

        sliderContainer.addSubview(sliderView)

        

        sliderViewLabel.userInteractionEnabled = false
        sliderViewLabel.textAlignment = NSTextAlignment.Center
        sliderViewLabel.textColor = sliderTitleColor
        sliderView.addSubview(sliderViewLabel)

        sliderPanGestureRecogniser.addTarget(self, action: NSSelectorFromString("handleGesture:"))
        sliderView.addGestureRecognizer(sliderPanGestureRecogniser)

        sliderContainer.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5)
        addSubview(sliderContainer)
        clipsToBounds = true
    }
}

final class SliderSnappingBehavior: UIDynamicBehavior {
 
    let snappingPoint:CGPoint
    init(item: UIDynamicItem, snapToPoint point: CGPoint) {
    
        let dynamicItemBehavior:UIDynamicItemBehavior  = UIDynamicItemBehavior(items: [item])
        dynamicItemBehavior.allowsRotation = false
        
        let snapBehavior:UISnapBehavior = UISnapBehavior(item: item, snapToPoint: point)
        snapBehavior.damping = 0.25
        
        snappingPoint = point
        
        super.init()
        
        addChildBehavior(dynamicItemBehavior)
        addChildBehavior(snapBehavior)
    }
}
