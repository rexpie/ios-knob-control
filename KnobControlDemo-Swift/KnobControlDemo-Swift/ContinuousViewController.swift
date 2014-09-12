
import UIKit


class ContinuousViewController: BaseViewController{
    
    
    @IBOutlet weak var viewPort: UIView!
    
    var image :UIImage!
    
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
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: knobControl.bounds.width, height: knobControl.bounds.height), true, 0)
        
        
        image.drawAtPoint(CGPoint(x:knobControl.bounds.origin.x + knobControl.bounds.width/2 - image.size.width/2,y:0))
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        knobControl.setImage(newImage, forState: UIControlState.Normal)
        knobControl.positionIndex = 0
        knobPositionChanged(knobControl)
        
        // initialize all other properties based on initial control values
        updateKnobProperties()
    }
    
    func knobPositionChanged(sender: IOSKnobControl) {
        // display both the position and positionIndex properties
        println(sender.positionIndex)
    }
    
    // MARK: Internal methods
    func updateKnobProperties() {
        /*
        * Using exponentiation avoids compressing the scale below 1.0. The
        * slider starts at 0 in middle and ranges from -1 to 1, so the
        * time scale can range from 1/e to e, and defaults to 1.
        */
        knobControl.timeScale = 1.0
        
        // Set the .mode property of the knob control
        
        knobControl.mode = .LinearReturn
        
        
        // Configure the gesture to use
        
        knobControl.gesture = .OneFingerRotation
        
        
        // clockwise or counterclockwise
        knobControl.clockwise = false
        
        // Make use of computed props again to switch between the two demos
        var titles = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
        for index in 0...5 {
            titles.append(" ")
        }
            
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
        
        
        knobControl.positions = UInt(titles.count)
        //knobControl.setImage(nil, forState: .Normal)
        
        
        // Good idea to do this to make the knob reset itself after changing certain params.
        knobControl.position = knobControl.position
    }
    
}
