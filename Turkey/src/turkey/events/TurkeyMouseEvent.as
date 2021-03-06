package turkey.events
{
	import turkey.display.DisplayObject;

	public class TurkeyMouseEvent extends TurkeyEvent
	{
		public static const CLICK:String = "turkeyClick";
		public static const RIGHT_CLICK:String = "turkeyRightClick";
		public static const MOUSE_MOVE:String = "turkeyMouseMove";
		public static const MOUSE_OVER:String = "turkeyMouseOver";
		public static const MOUSE_OUT:String = "turkeyMouseOut";
		public static const MOUSE_DOWN:String = "turkeyMouseDown";
		public static const MOUSE_UP:String = "turkeyMouseUp";
		public static const RIGHT_MOUSE_DOWN:String = "turkeyRightMouseDown";
		public static const RIGHT_MOUSE_UP:String = "turkeyRightMouseUp";
		
		public var localX:Number;
		public var localY:Number;
		public var stageX:Number;
		public var stageY:Number;
		public var altKey:Boolean = false;
		public var shiftKey:Boolean = false;
		public var ctrKey:Boolean = false;
		public function TurkeyMouseEvent(type:String, target:DisplayObject, localX:Number, localY:Number, stageX:Number, stageY:Number,altkey:Boolean=false,shiftKey:Boolean=false,ctrKey:Boolean=false)
		{
			super(type,true);
			setTarget(target);
			this.localX = localX;
			this.localY = localY;
			this.stageX = stageX;
			this.stageY = stageY;
			this.altKey = altKey;
			this.shiftKey = shiftKey;
			this.ctrKey = ctrKey;
		}
	}
}