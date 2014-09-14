
import UIKit


class ContinuousViewController: BaseViewController{
    
    
    @IBOutlet weak var viewPort: UIView!
    
    var image :UIImage!
    
    let positions :UInt = 30
    var lastPositionIndex :Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let radius :Int = 800
        knobControl = getKnobControl(viewPort, radius)
        
        //======================================================
        // image creation
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
       
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        //=====================================================================
        //End image creation
        
        knobControl.setPosition(Float(offset), animated: false)
        knobControl.setImage(newImage, forState: UIControlState.Normal)
        knobControl.addTarget(self, action: "knobPositionChanged:", forControlEvents: UIControlEvents.ValueChanged)
        knobControl.transform = CGAffineTransformMakeTranslation(CGFloat(0.0), CGFloat(20.0))

        knobPositionChanged(knobControl)
        
        // initialize all other properties based on initial control values
        updateKnobProperties()
    }

    //Util function to draw image in a circle
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
        let index = sender.positionIndex
        if index != lastPositionIndex
        {
            println(sender.positionIndex)
            println(sender.position)
            lastPositionIndex = index
        }
    }
    
    // MARK: Internal methods
    func updateKnobProperties() {
        /*
        * Using exponentiation avoids compressing the scale below 1.0. The
        * slider starts at 0 in middle and ranges from -1 to 1, so the
        * time scale can range from 1/e to e, and defaults to 1.
        */
        knobControl.positions = positions
        knobControl.position = knobControl.position
    }
    
}
