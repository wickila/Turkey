package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import turkey.core.Turkey;
	import turkey.display.Image;
	import turkey.display.Sprite;
	import turkey.events.TurkeyEvent;
	import turkey.events.TurkeyMouseEvent;
	import turkey.filters.BlurFilter;
	import turkey.filters.GrayFilter;
	import turkey.filters.RadialBlurFilter;
	import turkey.textures.Texture;
	
	[SWF(width="1000",height="600",frameRate="25")]
	public class TestImage extends flash.display.Sprite
	{
		private var _loader:Loader;
		private var _urlLoader:URLLoader;
		private var _img:Image;
		public function TestImage()
		{
			Turkey.init(stage);
			Turkey.stage.addEventListener(TurkeyEvent.COMPLETE,__createComplete);
		}
		
		protected function __createComplete(event:TurkeyEvent):void
		{
			var debug:DebugStats = new DebugStats();
			addChild(debug);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onTextureComplete);
			_loader.load(new URLRequest("images.jpg"));
		}
		
		protected function onTextureComplete(event:Event):void
		{
			var filter:RadialBlurFilter = new RadialBlurFilter(.5,.5,.005);
			var grayFilter:GrayFilter = new GrayFilter();
			var blurFilter:BlurFilter = new BlurFilter(3,3);
			var img:Image = new Image(Texture.fromBitmap(Bitmap(_loader.content)));
			var img2:Image = new Image(Texture.fromBitmap(Bitmap(_loader.content)));
			img2.x = img2.y = 300;
			img2.filters = [blurFilter];
			img.filters = [filter];
			var sp:turkey.display.Sprite = new turkey.display.Sprite();
			sp.mouseEnabled = false;
			sp.addChild(img);
			sp.addChild(img2);
//			sp.filters = [grayFilter];
			img.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			sp.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			stage.addEventListener(MouseEvent.CLICK,onStageClick);
			Turkey.stage.addChild(sp);
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			var dir:int=1;
			function onEnterFrame(event2:Event):void
			{
				img2.x += dir;
				if(img2.x>stage.stageWidth)
				{
					dir = -1;
				}else if(img2.x <0)
				{
					dir = 1;
				}
			}
			function onClick(event1:TurkeyMouseEvent):void
			{
				trace(event1.currentTarget);
			}
			
			function onStageClick(event3:MouseEvent):void
			{
				filter.xOffset = mouseX / stage.stageWidth;
				filter.yOffset = mouseY / stage.stageHeight;
			}
		}
	}
}