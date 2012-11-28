package turkey.core
{
	import flash.display.Stage;
	
	import turkey.display.Stage;

	use namespace turkey_internal;
	public class Turkey
	{
		public static var stage:turkey.display.Stage;
		public function Turkey()
		{
		}
		
		public static function init(stage2D:flash.display.Stage,frameRate:int=60,color:uint=0xffffffff):void
		{
			stage = new turkey.display.Stage(stage2D,frameRate,color);
		}
	}
}