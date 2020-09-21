import UIKit

enum ProgressViewAction: Int {
    case ProgressViewActionNone  = 0
    case ProgressViewActionSuccess
    case ProgressViewActionFailure
}

class ProgressBarIndeterminate: UIView {

    var progressBar: UIView!
    var progressLayer: CAShapeLayer!
    var indeterminateLayer: CALayer!
    var displayLink: CADisplayLink!
    
    var progress: CGFloat                       = 0
    var currentAction: ProgressViewAction       = .ProgressViewActionNone
    var indeterminate: Bool                     = true {
        didSet {
            if indeterminate == true {
                self.indeterminateLayer.isHidden  = false
                self.progressLayer.isHidden       = false
                self.progressBar.isHidden         = false
                
                indeterminateLayer.opacity      = 1
                progressLayer.opacity           = 1
                
                let animation: CABasicAnimation = CABasicAnimation(keyPath: "position")
                animation.duration              = self.animationDuration * 2.5
                animation.repeatCount           = Float.infinity
                animation.isRemovedOnCompletion   = false
                
                animation.fromValue             = indeterminateLayer.frame.size.width == 0 ? NSValue(cgPoint: CGPoint(x: -indeterminateLayer.frame.size.width - self.bounds.size.width, y: 0)) : NSValue(cgPoint: CGPoint(x: -indeterminateLayer.frame.size.width, y: 0))
                animation.toValue               = indeterminateLayer.frame.size.width == self.bounds.size.width ? NSValue(cgPoint: CGPoint(x: indeterminateLayer.frame.size.width + self.bounds.size.width, y: 0)) : NSValue(cgPoint: CGPoint(x: self.bounds.size.width * 2, y: 0))
                indeterminateLayer.frame.size.width = self.bounds.size.width
                indeterminateLayer.add(animation, forKey: "position")
                self.setNeedsDisplay()
            } else if indeterminate == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.004) {
                    self.indeterminateLayer.isHidden  = true
                    self.progressLayer.isHidden       = true
                    self.progressBar.isHidden         = true
                    self.setNeedsDisplay()
                }
            }
        }
    }
    
    var animationStartTime: CFTimeInterval      = 0.0
    var animationDuration: CFTimeInterval       = 0.0
    var animationFromValue: CGFloat             = 0.0
    var animationToValue: CGFloat               = 0.0
    
    var progressBarThickness: CGFloat           = 3.0 {
        willSet {
            progressLayer.lineWidth             = progressBarThickness
            
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay()
        }
    }
    
    var progressBarCornerRadius: CGFloat        = 0.0 {
        willSet {
            progressBar.layer.cornerRadius      = progressBarCornerRadius
            indeterminateLayer.cornerRadius     = progressBarCornerRadius
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay()
        }
    }
    
    var primaryColor                            = UIColor.blue {
        willSet {
            indeterminateLayer.backgroundColor  = self.primaryColor.cgColor
            self.setNeedsDisplay()
        }
    }
    
    var secondaryColor                          = UIColor(red: 181.0/255.0, green: 182/255.0, blue: 183.0/255.0, alpha: 1.0) {
        willSet {
            indeterminateLayer.backgroundColor  = self.secondaryColor.cgColor
            self.setNeedsDisplay()
        }
    }
    
    var successColor                            = UIColor(red: 63.0/255.0, green: 226.0/255.0, blue: 80.0/255.0, alpha: 1.0) {
        didSet {
            layer.borderColor                   = successColor.cgColor
            self.setNeedsDisplay()
        }
    }
    
    var failureColor                            = UIColor(red: 249.0/255.0, green: 37.0/255.0, blue: 0.0/255.0, alpha: 1.0){
        didSet {
            layer.borderColor                   = failureColor.cgColor
            self.setNeedsDisplay()
        }
    }
	
	deinit {
		MemoryResourceTracking.decrementTotal(String(describing: self))
	}

    init() {
        super.init(frame: CGRect.zero)
        self.setup()
    }
    
    convenience override init(frame: CGRect) {
        self.init()
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
		
		MemoryResourceTracking.incrementTotal(String(describing: self))
		
        self.backgroundColor                    = UIColor.clear
        
        progressBar                             = UIView.init()
        progressBar.backgroundColor             = secondaryColor;
        progressBar.layer.cornerRadius          = progressBarCornerRadius
        progressBar.clipsToBounds               = true
        self.addSubview(progressBar)
        
        progressLayer                           = CAShapeLayer()
        progressLayer.strokeColor               = self.primaryColor.cgColor
        progressLayer.lineWidth                 = progressBarThickness
		progressLayer.lineCap                   = CAShapeLayerLineCap.round
        progressBar.layer.addSublayer(progressLayer)

        indeterminateLayer                      = CALayer()
        indeterminateLayer.backgroundColor      = self.primaryColor.cgColor;
        indeterminateLayer.cornerRadius         = progressBarCornerRadius;
        indeterminateLayer.opacity              = 0
        progressBar.layer.addSublayer(indeterminateLayer)
        
        animationDuration                       = 0.5
        progressBarCornerRadius                 = progressBarThickness / 2.0

        self.layoutSubviews()
    }

    override func layoutSubviews() {
        
        var progressFrame = CGRect(x: 0.0, y: (self.bounds.size.height - progressBarThickness), width: self.bounds.size.width, height: progressBarThickness)
        progressFrame.origin = CGPoint(x: 0.0, y: (self.bounds.size.height - progressBarThickness))
		
        progressBar.frame = CGRect(x: 0.0, y: (self.bounds.size.height - progressBarThickness), width: self.bounds.size.width, height: progressBarThickness)
        
        progressLayer.frame = progressFrame
        
        indeterminateLayer.frame = CGRect(x: 0.0, y: (self.bounds.size.height - progressBarThickness), width: self.bounds.size.width, height: progressBarThickness * 2)

        super.layoutSubviews()
    }
    
    override public var intrinsicContentSize: CGSize {
        get {
			return CGSize(width: UIView.noIntrinsicMetric, height: progressBarThickness);
        }
    }
    
    func indeterminateAnimation() -> CABasicAnimation {
        let animation: CABasicAnimation         = CABasicAnimation(keyPath: "backgroundColor")
        animation.duration                      = 2 * self.animationDuration
        animation.repeatCount                   = 1;
		animation.fillMode                      = CAMediaTimingFillMode.forwards;
        animation.isRemovedOnCompletion           = false
        return animation
    }
    
    func setProgress(progress: CGFloat, animated: Bool = true) {
        if (animated == false) {
            if (displayLink != nil) {
                displayLink.invalidate()
                displayLink                     = nil
            }
            self.setNeedsDisplay()
        } else {
            animationStartTime                  = CACurrentMediaTime();
            animationFromValue                  = self.progress;
            animationToValue                    = progress;
            if (displayLink == nil) {
                if (displayLink != nil) { displayLink.invalidate() }
                displayLink                     = CADisplayLink.init(target: self, selector: #selector(ProgressBarIndeterminate.animateProgress(displayLink:)))
				self.displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            }
        }
    }
    
	@objc func animateProgress(displayLink: CADisplayLink) {
        DispatchQueue.main.async {
            let dt: TimeInterval                  = (displayLink.timestamp - self.animationStartTime) / self.animationDuration
            if (dt >= 1.0) {
                self.displayLink.invalidate()
                self.displayLink                    = nil
                self.setNeedsDisplay()
                return
            }
            self.progress                           = (self.animationFromValue + CGFloat(dt)) * (self.animationToValue - self.animationFromValue)
            self.setNeedsDisplay()
        }
    }
    
    func performAction(action: ProgressViewAction, animated: Bool) {
        if (action == .ProgressViewActionNone && currentAction != .ProgressViewActionNone) {
            currentAction                                   = action;
            self.setNeedsDisplay()
            
            CATransaction.begin()
            let barAnimation: CABasicAnimation              = self.barColorAnimation()
            barAnimation.fromValue                          = progressLayer.strokeColor
            barAnimation.toValue                            = self.primaryColor.cgColor
            
            let indeterminateAnimation: CABasicAnimation    = self.indeterminateColorAnimation()
            indeterminateAnimation.fromValue                = indeterminateLayer.backgroundColor
            indeterminateAnimation.toValue                  = self.primaryColor.cgColor

            progressLayer.add(barAnimation, forKey: "strokeColor")
            indeterminateLayer.add(indeterminateAnimation, forKey:"backgroundColor")
            CATransaction.commit()
            
        } else if (action == .ProgressViewActionSuccess && currentAction != .ProgressViewActionSuccess) {
            currentAction                                   = action
            self.setNeedsDisplay()

            CATransaction.begin()
            let barAnimation: CABasicAnimation              = self.barColorAnimation()
            barAnimation.fromValue                          = progressLayer.strokeColor
            barAnimation.toValue                            = successColor.cgColor

            let indeterminateAnimation: CABasicAnimation    = self.indeterminateColorAnimation()
            indeterminateAnimation.fromValue                = indeterminateLayer.backgroundColor
            indeterminateAnimation.toValue                  = successColor.cgColor

            progressLayer.add(barAnimation, forKey:"strokeColor")
            indeterminateLayer.add(indeterminateAnimation, forKey:"backgroundColor")
            CATransaction.commit()
            
        } else if (action == .ProgressViewActionFailure && currentAction != .ProgressViewActionFailure) {
            currentAction                                   = action
            self.setNeedsDisplay()

            CATransaction.begin()
            let barAnimation: CABasicAnimation              = self.barColorAnimation()
            barAnimation.fromValue                          = progressLayer.strokeColor
            barAnimation.toValue                            = failureColor.cgColor
            
            let indeterminateAnimation: CABasicAnimation    = self.indeterminateColorAnimation()
            indeterminateAnimation.fromValue                = indeterminateLayer.backgroundColor
            indeterminateAnimation.toValue                  = failureColor.cgColor
            
            progressLayer.add(barAnimation, forKey:"strokeColor")
            indeterminateLayer.add(indeterminateAnimation, forKey:"backgroundColor")
            CATransaction.commit()
        }
    }
    
    func barColorAnimation() -> CABasicAnimation {
        let animation: CABasicAnimation                     = CABasicAnimation.init(keyPath: "strokeColor")
        animation.duration                                  = 2 * animationDuration
        animation.repeatCount                               = 1
		animation.fillMode                                  = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion                       = false
        return animation
    }

    func indeterminateColorAnimation() -> CABasicAnimation {
        let animation: CABasicAnimation                     = CABasicAnimation.init(keyPath: "backgroundColor")
        animation.duration                                  = 2 * animationDuration
        animation.repeatCount                               = 1
		animation.fillMode                                  = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion                       = false
        return animation
    }

    override func draw(_ rect: CGRect) {
        if progress != 0 {
            let path: UIBezierPath = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: progressBarThickness / 2.0))
            path.addLine(to: CGPoint(x: progressLayer.frame.size.width * self.progress, y: progressBarThickness / 2.0))
            progressLayer.path                              = path.cgPath
        } else {
            progressLayer.path                              = nil
        }
    }
}
