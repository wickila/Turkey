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
	import turkey.filters.GlowFilter;
	import turkey.filters.GrayFilter;
	import turkey.filters.RadialBlurFilter;
	import turkey.filters.SBlurFilter;
	import turkey.textures.Texture;
	
	[SWF(width="1000",height="600",frameRate="60")]
	public class TestImage extends flash.display.Sprite
	{
		private var _loader:Loader;
		private var _loader1:Loader;
		private var _urlLoader:URLLoader;
		private var _img:Image;
		public function TestImage()
		{
			Turkey.init(stage,0,0,0xffffffff);
			Turkey.stage.addEventListener(TurkeyEvent.COMPLETE,__createComplete);
		}
		
		protected function __createComplete(event:TurkeyEvent):void
		{
			var debug:DebugStats = new DebugStats();
			addChild(debug);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onTextureComplete);
			_loader.load(new URLRequest("image.png"));
		}
		
		protected function onTextureComplete(event:Event):void
		{
			_loader1 = new Loader();
			_loader1.contentLoaderInfo.addEventListener(Event.COMPLETE,onTextureComplete1);
			_loader1.load(new URLRequest("image.jpg"));
		}
		
		protected function onTextureComplete1(event:Event):void
		{
			var filter:RadialBlurFilter = new RadialBlurFilter(.5,.5,.005);
			var grayFilter:GrayFilter = new GrayFilter();
			var blurFilter:BlurFilter = new BlurFilter(3,3);
			var glowFilter:GlowFilter = new GlowFilter(0x0000ff,1,1,6);
			var sFilter:SBlurFilter = new SBlurFilter();
			var texture:Texture = Texture.fromBitmap(Bitmap(_loader.content));
			var texture1:Texture = Texture.fromBitmap(Bitmap(_loader1.content));
			var img:Image = new Image(texture);
			var img2:Image = new Image(texture);
			img2.y = 400;
			img2.pivotX = 80;
			img2.pivotY = img2.height/2;
			img.buttonMode = true;
//			img2.visible = false;
//			img2.filters = [glowFilter];
			img2.filters = [sFilter];
			var sp:turkey.display.Sprite = new turkey.display.Sprite();
			sp.mouseEnabled = false;
			sp.addChild(img);
			sp.addChild(img2);
//			sp.filters = [grayFilter];
			img.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			img.addEventListener(TurkeyMouseEvent.MOUSE_DOWN,onMouseDown);
			img.addEventListener(TurkeyMouseEvent.MOUSE_UP,onMouseUp);
			sp.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			stage.addEventListener(MouseEvent.CLICK,onStageClick);
			Turkey.stage.addChild(sp);
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			var dir:int=1;
			function onEnterFrame(event2:Event):void
			{
				img2.x += dir;
//				img2.rotation += Math.PI/180;
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
			
			function onMouseDown(event4:TurkeyMouseEvent):void
			{
				img.dragStart();
			}
			
			function onMouseUp(event5:TurkeyMouseEvent):void
			{
				img.dragStop();
			}
		}
	}
}