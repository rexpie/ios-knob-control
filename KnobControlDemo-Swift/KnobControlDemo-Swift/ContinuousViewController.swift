
import UIKit


class ContinuousViewController: BaseViewController{
    
    
    @IBOutlet weak var viewPort: UIView!
    
    @IBOutlet weak var stackView: UIView!
    
    var image :UIImage!
    
    let positions :UInt = 30
    var lastPositionIndex :Int = 0
    
    var images: [UIImage]! = []
    var imageViews : [UIImageView]! = []
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        //println("pan")
        let translation = recognizer.translationInView(stackView)
        
        if ( recognizer.state == UIGestureRecognizerState.Changed){
            //println("change")
        }
        if ( recognizer.state == UIGestureRecognizerState.Ended){
            //println("end")
            let x = translation.x
            
            if (abs(x) > 50)
            {
                let direction = abs(x) / x
                println("direction", direction)
                let nextIndex:Int = knobControl.positionIndex - Int(direction)
                
                println("move")
                animateStack(nextIndex, direction:direction)
            }
        }
    }
    
    func animateStack(nextIndex:Int, direction:CGFloat)
    {
        println("positionIndex", String(knobControl.positionIndex))
        println("last pos%d", String(lastPositionIndex))
        
        println("nextIndex", nextIndex)
        let translationX = direction * 100
        
        if (nextIndex < 0)
        {
            // refresh
            return
        }
        
        if (lastPositionIndex == images.count - 1 && direction < 0)
        {
            // load more
            return
        }
        
        
        var theView: UIImageView = imageViews[lastPositionIndex]
        
        var thePrevView: UIImageView = imageViews[nextIndex]
        
        
        let indexForTopImage: Int = lastPositionIndex
        let indexForBottonImage: Int = nextIndex
        
        for view in imageViews
        {
            view.layer.zPosition = 0
        }
        
        if (direction < 0)
        {
            
            let topImageView = imageViews[indexForTopImage]
            topImageView.layer.zPosition = 2
            topImageView.transform = CGAffineTransformIdentity
            
            let bottomImageView = imageViews[indexForBottonImage]
            bottomImageView.layer.zPosition = 1
            bottomImageView.transform = CGAffineTransformIdentity
        }
        else
        {
            
            let topImageView = imageViews[indexForBottonImage]
            topImageView.layer.zPosition = 2
            topImageView.alpha = 0.0
            topImageView.transform = CGAffineTransformMakeTranslation(-translationX, 0)
            
            let bottomImageView = imageViews[indexForTopImage]
            bottomImageView.layer.zPosition = 1
        }
        
        if (direction < 0)
        {
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut ,
                animations: {
                    theView.alpha = 0;
                    theView.transform = CGAffineTransformMakeTranslation(translationX, 0)
                }, completion: {(value:Bool) in
                    theView.layer.zPosition = 0
                    theView.alpha = 1.0
                    theView.transform = CGAffineTransformIdentity
                }
            )
        }
        else
        {
            UIView.animateWithDuration(0.5,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseInOut ,
                animations: {
                    thePrevView.alpha = 1.0;
                    thePrevView.transform = CGAffineTransformIdentity
                }, completion: {(value:Bool) in
                    theView.layer.zPosition = 0
                    theView.alpha = 1.0
                    theView.transform = CGAffineTransformIdentity
                }
                
            )
            
        }
        knobControl.positionIndex = nextIndex
        lastPositionIndex = nextIndex
        
    }
    
    func handleTap(recognizer:UITapGestureRecognizer) {
        println("tap")
        let point = recognizer.locationOfTouch( 0, inView: stackView)
        println(point.x)
        println(point.y)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load images
        // TODO async
        images.append(UIImage(named: "item1"))
        images.append(UIImage(named: "item2"))
        images.append(UIImage(named: "item3"))
        images.append(UIImage(named: "item4"))
        
        let radius :Int = 800
        knobControl = getKnobControl(viewPort, radius)
        
        //======================================================
        // image creation
        
        
                //=====================================================================
        //End image creation
        for i in 0..<images.count{
            setImageAtIndex(knobControl, index: UInt(i), image: images[i])
        }
        
        knobControl.addTarget(self, action: "knobPositionChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        resetKnobControl(knobControl, positions: positions)
        knobPositionChanged(knobControl)
        
        // initialize all other properties based on initial control values
        updateKnobProperties()
        
        //--------------------------------------------------
        //knob view finished
        
        //stack view starts

        
        
        setupStack(stackView, images: images)
        
    }
    
    
    func setupStack(stackView: UIView, images: [UIImage])
    {
        var zPositionIndex: CGFloat = 2
        for image in images{
            let imageView = UIImageView(image: image)
            imageViews.append(imageView)
            imageView.layer.zPosition = zPositionIndex
            zPositionIndex = zPositionIndex - 1
            imageView.center = stackView.center
            stackView.addSubview(imageView)
        }
        
        
        let gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        stackView.addGestureRecognizer(gesture)
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
        
        if ( lastPositionIndex != index){
            animateStack(sender.positionIndex, direction: CGFloat(lastPositionIndex - index))
        }
        
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
