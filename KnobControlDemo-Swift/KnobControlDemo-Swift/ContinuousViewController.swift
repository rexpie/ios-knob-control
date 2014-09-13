
import UIKit


class ContinuousViewController: BaseViewController{
    
    
    @IBOutlet weak var viewPort: UIView!
    
    var image :UIImage!
    
    let positions :UInt = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenBounds :CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenBounds.width
        
        let originalBounds = viewPort.bounds
        let longerSide = max(originalBounds.height, originalBounds.width)
        let fullBound = CGRect(x : originalBounds.origin.x, y : originalBounds.origin.y, width : longerSide, height : longerSide)
        
        	
        viewPort.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        viewPort.tintColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        // Create the knob control
        knobControl = IOSKnobControl(frame: fullBound)
        knobControl.circular = false
        knobControl.transform = CGAffineTransformMakeTranslation(CGFloat(0.0), CGFloat(20.0))
        
        // knobControl.fontName = "CourierNewPS-BoldMT"
        knobControl.fontName = "Verdana-Bold"
        // knobControl.fontName = "Georgia-Bold"
        // knobControl.fontName = "TimesNewRomanPS-BoldMT"
        // knobControl.fontName = "AvenirNext-Bold"
        // knobControl.fontName = "TrebuchetMS-Bold"
        
        knobControl.setFillColor(UIColor.clearColor(), forState: .Normal)
        knobControl.setFillColor(UIColor.clearColor(), forState: .Highlighted)
        
        // specify an action for the .ValueChanged event and add as a subview to the knobHolder UIView
        knobControl.addTarget(self, action: "knobPositionChanged:", forControlEvents: UIControlEvents.ValueChanged)
        viewPort.addSubview(knobControl)
        
        image = UIImage(named: "cat")
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: knobControl.bounds.width, height: knobControl.bounds.height), false, 0)
        var context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        
        let imageX = knobControl.bounds.width/2
        let imageY = knobControl.bounds.height/2
        let drawPoint = CGPoint(x:imageX,y:imageY)
        //image.drawAtPoint(drawPoint)

        let angle :Double = M_PI * 2 / Double(positions)
        let offset : Double = (angle / 2.0) - (angle * (Double(positions)/2.0))
        
        for rotation in 0..<positions-10{
            drawImageWithRotation(context, image:image, rotation:CGFloat(Double(rotation) * angle + offset), point:drawPoint)
        }
        //drawImageWithRotation(context, image:image, rotation:CGFloat(-3.14/2), point:drawPoint)//
//        drawImageWithRotation(context, image:image, rotation:CGFloat(offset), point:drawPoint)
        //drawImageWithRotation(context, image:image, rotation:CGFloat(3.14/2), point:drawPoint)
        //drawImageWithRotation(context, image:image, rotation:CGFloat(3.14), point:drawPoint)
        

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        knobControl.setPosition(Float(offset), animated: false)
        knobControl.setImage(newImage, forState: UIControlState.Normal)
        knobPositionChanged(knobControl)
        
        // initialize all other properties based on initial control values
        updateKnobProperties()
    }

    func drawImageWithRotation (context: CGContext, image: UIImage, rotation: CGFloat, point: CGPoint)
    {
        CGContextSaveGState(context)
        //translate to center
        CGContextTranslateCTM(context, point.x, point.y)
        
        CGContextRotateCTM(context, rotation)
    
        
        image.drawAtPoint(CGPoint(x:-image.size.width/2, y:-point.y))
        CGContextRestoreGState(context)
    }
    
    func knobPositionChanged(sender: IOSKnobControl) {
        // display both the position and positionIndex properties
        println(sender.positionIndex)
        println(sender.position)
    }
    
    // MARK: Internal methods
    func updateKnobProperties() {
        /*
        * Using exponentiation avoids compressing the scale below 1.0. The
        * slider starts at 0 in middle and ranges from -1 to 1, so the
        * time scale can range from 1/e to e, and defaults to 1.
        */
        knobControl.timeScale = 0.1
        
        // Set the .mode property of the knob control
        
        knobControl.mode = .LinearReturn
        
        
        // Configure the gesture to use
        
        knobControl.gesture = .OneFingerRotation
        
        
        // clockwise or counterclockwise
        knobControl.clockwise = false
        
        // Make use of computed props again to switch between the two demos
        var titles = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug"]
        //, "Sep", "Oct", "Nov", "Dec" ]
        
        let font = UIFont(name: knobControl.fontName, size: 14.0)
        let italicFontDesc = UIFontDescriptor(name: "Verdana-BoldItalic", size: 14.0)
        let italicFont = UIFont(descriptor: italicFontDesc, size: 0.0)
        
        var attribTitles = [NSAttributedString]()
        
        for (index, title) in enumerate(titles) {
            let textColor = UIColor(hue:CGFloat(index)/CGFloat(titles.count), saturation:1.0, brightness:1.0, alpha:1.0)
            let attributed = NSAttributedString(string: title, attributes: [NSFontAttributeName: index % 2 == 0 ? font : italicFont, NSForegroundColorAttributeName: textColor])
            attribTitles.append(attributed)
        }
        knobControl.titles = attribTitles
        
        
        knobControl.positions = positions
        //knobControl.setImage(nil, forState: .Normal)
        
        
        // Good idea to do this to make the knob reset itself after changing certain params.
        knobControl.position = knobControl.position
    }
    
}
