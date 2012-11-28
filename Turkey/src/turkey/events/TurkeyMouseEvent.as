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
		
		public var localX:Number;
		public var localY:Number;
		public var stageX:Number;
		public var stageY:Number;
		public function TurkeyMouseEvent(type:String, target:DisplayObject, localX:Number, localY:Number, stageX:Number, stageY:Number)
		{
			super(type,true);
			setTarget(target);
			this.localX = localX;
			this.localY = localY;
			this.stageX = stageX;
			this.stageY = stageY;
		}
	}
}