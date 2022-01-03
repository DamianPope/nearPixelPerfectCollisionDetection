package;

//
//This code centres around the function nearPixelPerfectCollisionCheck (below).
//The function can detect if two images overlap, even when the overlap is a single pixel.
//When the user sets the collisionTestStepSize parameter to a value larger than one, the function performs "near perfect" collision detection,
//also known as coarse-grained collision detection
//Instead of checking every single pixel to see if there's overlap (i.e., a collision), 
//it can check every second pixel, or every third, or fourth etc.
//As pixels are small, it still detects collisions well and uses less processing power compared to checking every pixel.
//This functionality provides more flexibility and can be useful it's important to minimize processing power requirements
//
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;

class Main extends Sprite
{
	private var minX:Int;
	private var minY:Int;
	private var maxX:Int;
	private var maxY:Int;
	
	private var object1:Bitmap;	
	private var object2:Bitmap;
	
	private var object1_SpeedX:Float;
	private var object2_SpeedX:Float;
	
	private var object1_SpeedY:Float;
	private var object2_SpeedY:Float;
	
	private var object1_original_width:Float;
	private var object1_original_height:Float;
	
	private var object2_original_width:Float;
	private var object2_original_height:Float;
	
	public function new()
	{
		super();

		//Define edges of on-screen area where objects move.
		//When an object hits an edge, it bounces back in the opposite direction.
		//The edges stop objects from moving off the screen. 
		minX = Math.floor(0.05*stage.stageWidth);
		maxX = Math.floor(0.95 * stage.stageWidth);
		
		minY = Math.floor(0.05*stage.stageHeight);
		maxY = Math.floor(0.95*stage.stageHeight);
	
		//
		//Load images for the two objects that move on the screen.
		//
		var bitmapData = Assets.getBitmapData("assets/object1.png");
		var bitmapDataTwo = Assets.getBitmapData("assets/object2.png");
		
		//Initialize positions of two objects & place them on the screen
		object1 = new Bitmap(bitmapDataTwo);
		object1.x = 0.5 * stage.stageWidth; 
		
		object1_original_width = object1.width;
		
		object1.width = 0.1 * stage.stageWidth; 
		object1.height*=object1.width/object1_original_width;
		addChild (object1);
		
		object2 = new Bitmap(bitmapData);
		object2_original_width = object2.width;
		
		object2.width = 0.1 * stage.stageWidth; 
		object2.height*=object2.width/object2_original_width;
		addChild (object2);
		
		//initialize speeds of the two objects
		//This is done by giving them random speeds in the x & y directions
		object1_SpeedX = Math.random() * 5;
		object1_SpeedY = Math.random() * 5;
		
		object2_SpeedX = Math.random() * 5;
		object2_SpeedY=Math.random() * 5;
		
		//
		//Listen for i) each new frame and ii) when the stage resizes due to the program first running
		//
		stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
		stage.addEventListener(Event.RESIZE, stage_onResize);
	}
		
	
	private function stage_onEnterFrame(event:Event):Void
	{
		//
		//If object1 and object2 aren't colliding, move them across the screen.
		//If they are colliding, freeze them in place.
		//
		if (!nearPixelPerfectCollisionCheck(object1, object2, object1.width/object1_original_width, object2.width/object2_original_width, 255, 1))
		{
			//Move object1 across screen
			object1.x+= object1_SpeedX;
			object1.y+= object1_SpeedY;
				
			//reverse speed of object1 if it's reached an edge
			if (object1.x > maxX)
			{

				object1_SpeedX *= -1;
					object1.x = maxX;
			}
			
			else if (object1.x < minX)
			{
					object1_SpeedX *= -1;
					object1.x = minX;
			}

			if (object1.y > maxY)
			{
					object1_SpeedY *= -1;
					object1.y = maxY;
			}
			
			else if (object1.y < minY)
			{
					object1_SpeedY *= -1;
					object1.y = minY;
			}
			
			//Move object2 across screen
			object2.x+= object2_SpeedX;
			object2.y+= object2_SpeedY;
			
			//reverse speed of object2 if it's reached an edge
			if (object2.x > maxX)
			{

				object2_SpeedX *= -1;
				object2.x = maxX;
			}
			
			else if (object2.x < minX)
			{
					object2_SpeedX *= -1;
					object2.x = minX;
			}

			if (object2.y > maxY)
			{
					object2_SpeedY *= -1;
					object2.y = maxY;
			}
			
			else if (object2.y < minY)
			{
					object2_SpeedY *= -1;
					object2.y = minY;
			}		
		}
	}

	
	//Function that listens for stage to be resized when the program starts running. 
	//We capture the width & height of the stage (i.e., the program window) in maxX and maxY
	private function stage_onResize(event:Event):Void
	{
		maxX = stage.stageWidth;
		maxY = stage.stageHeight;
	}
	
	//
	//Function that checks to see if two objects have collided. That is, if they have at least one overlapping pixel.
	//
	//PARAMETERS
	//contact, target = two objects that we check to see if they're colliding
	//
	//contactScalingFactor = factor that we've rescaled contact object by
	//for example, if we shrunk it to half it's original size, contactScalingFactor = 0.5
	//
	//targetScalingFactor = scaling factor for other object
	//
	//alphaTolerance = tolerance level for transparency of pixels. It can range between 255 and 0. When it's 255, collisions only occur when two pixels with no transparency (i.e., alpha = 1)
	//overlap. When it's less than 255, we allow for pixels that are only slightly transparent.
	//
	//collisionTestStepSize = specifies how carefully we want to check pixels for collisions. collisionTestStepSize = n means that we check every n-th pixel
	//
    public function nearPixelPerfectCollisionCheck(contact:DisplayObject, target:DisplayObject, contactScalingFactor:Float,targetScalingFactor:Float, alphaTolerance:Int,collisionTestStepSize:Int):Bool
    {
		//store boundaries of two DisplayObjects that we're checking for a collision between
		var boundsA = new Rectangle(contact.x,contact.y,contact.width,contact.height);
        var boundsB = new Rectangle(target.x,target.y,target.width,target.height);
		 
        //Identify the smallest rectangle that bounds the region where the two objects overlap
		var intersect:Rectangle = boundsA.intersection(boundsB);
        if (intersect.isEmpty() || intersect.width == 0 || intersect.height == 0) {return false;}
        
		//create a bitmap of each DisplayObject
        var testA = new BitmapData(Math.ceil(contact.width),Math.ceil(contact.height),true,0x00000000);       
		//Note: Code below assumes that contact has a registration point in its top left corner
		testA.draw(contact, new Matrix(contactScalingFactor, 0, 0, contactScalingFactor, 0, 0));
		
        var testB = new BitmapData(Math.ceil(target.width), Math.ceil(target.height), true, 0x00000000);
        testB.draw(target,new Matrix(targetScalingFactor,0,0,targetScalingFactor,0,0)); 
        
		var overlapWidth:Int = Math.ceil(intersect.width);
		var overlapHeight:Int = Math.ceil(intersect.height);

		var targetX:Int;
        var targetY:Int;
		
        var pixelColor:Int;
        var pixelAlpha:Int;
        var transformedAlpha:Int;

        //the two +1's below account for the fact the Haxe loop for (i in a...b) goes from a to (b-1)
        var maxX_pixelCounter:Int = overlapWidth+1;
        var maxY_pixelCounter:Int = overlapHeight+1;

        //
        //loop through all pixels inside the intersect region. 
		//see if any have alpha=1 for both contact & target objects, i.e. both bitmaps have parts that are located at the same pixel
        //
        for (i in 0...Math.ceil(maxX_pixelCounter/collisionTestStepSize))
        {
            for (j in 0...Math.ceil(maxY_pixelCounter/collisionTestStepSize))
            {				
				//Calculate the local coordinates of the pixel that we want to check 
				var testA_i:Int = Math.floor(intersect.x - contact.x+collisionTestStepSize*i);
                var testA_j:Int = Math.floor(intersect.y - contact.y+collisionTestStepSize*j);
			
                pixelColor=testA.getPixel32(testA_i,testA_j);
                    
                //Extract alpha channel from 32-bit ARGB colour of pixel by: 
				//i) bitshifting colour 24 bits to right (>>24) and 
				//ii) zeroing the first 24 bits of 32-bit string(& 0xFF) by performing the bitwise AND (&) operation with 0xFF
				//
				//This idea comes from Corey O'Neil's collision detection code: https://github.com/tamagokun/Flash-libs/blob/master/com/coreyoneil/collision/CDK.as
				//
				pixelAlpha = (pixelColor >> 24) & 0xFF;
            
				if (pixelAlpha>=alphaTolerance)
                {		
					//check if the pixel is in the target
					var testB_i:Int = Math.floor(testA_i-(target.x-contact.x));
                    var testB_j:Int = Math.floor(testA_j-(target.y-contact.y));
         
                    pixelColor=testB.getPixel32(testB_i,testB_j);
                    pixelAlpha = (pixelColor >> 24) & 0xFF;
                
                    if (pixelAlpha >= alphaTolerance) { return true; }
				}
            }    
        }
		return false;
    }
}
