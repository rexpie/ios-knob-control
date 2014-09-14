
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
        
                //=====================================================================
        //End image creation
        for i in 0..<positions - 10{
            setImageAtIndex(knobControl, index: i, image: image)
        }
        
        knobControl.addTarget(self, action: "knobPositionChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        resetKnobControl(knobControl, positions: positions)
        knobPositionChanged(knobControl)
        
        // initialize all other properties based on initial control values
        updateKnobProperties()
    }

    func setImageAtIndex(knobControl: IOSKnobControl, index: UInt, image: UIImage)
    {
        // using bounds is essential to get the correct size for the image, see frame vs. bounds in ios
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: knobControl.bounds.width, height: knobControl.bounds.height), false, 0)
        
        var originalImage : UIImage! = knobControl.imageForState(UIControlState.Normal)
        if (originalImage != nil){
            originalImage!.drawAtPoint(CGPointMake(0, 0))
        }
        
        
        // CG context used across many calls
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        
        let imageX = knobControl.bounds.width/2
        let imageY = knobControl.bounds.height/2
        
        //center of knobControl
        let drawPoint = CGPoint(x:imageX,y:imageY)
        
        // angle between every image
        let angle :Double = M_PI * 2 / Double(positions)
        
        // strangely knobControl like to place the 0 index at bottom of the image, not top.
        // use offset to put the image into the right place, so the first image we place is at index 0
        let offset : Double = (angle / 2.0) - (angle * (Double(positions)/2.0))
        
        drawImageWithRotation(context, image:image, rotation:CGFloat(Double(index) * angle + offset), point:drawPoint)
    
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        knobControl.setImage(newImage, forState: UIControlState.Normal)
        
    }
    
    //Util function to draw image in a circle
    func drawImageWithRotation (context: CGContext, image: UIImage, rotation: CGFloat, point: CGPoint)
    {
        let yOffset = CGFloat(20)
        CGContextSaveGState(context)
        //translate to center
        CGContextTranslateCTM(context, point.x, point.y)
        
        CGContextRotateCTM(context, rotation)
    
        
        image.drawAtPoint(CGPoint(x:-image.size.width/2, y: yOffset - point.y))
        CGContextRestoreGState(context)
    }
    
    func knobPositionChanged(sender: IOSKnobControl)
    {
        // display both the position and positionIndex properties
        let index = sender.positionIndex
        if index != lastPositionIndex
        {
            println(sender.positionIndex)
            println(sender.position)
            lastPositionIndex = index
        }
    }
    
    func resetKnobControl(knobControl:IOSKnobControl, positions: UInt)
    {
        // angle between every image
        let angle :Double = M_PI * 2 / Double(positions)
        
        // strangely knobControl like to place the 0 index at bottom of the image, not top.
        // use offset to put the image into the right place, so the first image we place is at index 0
        let offset : Double = (angle / 2.0) - (angle * (Double(positions)/2.0))
        knobControl.setPosition(Float(offset), animated: false)

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
