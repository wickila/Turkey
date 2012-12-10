package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import turkey.core.Turkey;
	import turkey.display.Image;
	import turkey.display.Sprite;
	import turkey.events.TurkeyEvent;
	import turkey.events.TurkeyMouseEvent;
	import turkey.textures.Texture;

	[SWF(width="1000",height="600",frameRate="60")]
	public class TestColorMatrix extends flash.display.Sprite
	{
		private var _loader:Loader;
		private var _loader1:Loader;
		private var _urlLoader:URLLoader;
		private var _img:Image;
		public function TestColorMatrix()
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
			var texture:Texture = Texture.fromBitmap(Bitmap(_loader.content));
			var texture1:Texture = Texture.fromBitmap(Bitmap(_loader1.content));
			var img:Image = new Image(texture);
			var img2:Image = new Image(texture);
			img2.y = 400;
			img2.colorMatrix = new Matrix3D(new <Number>[
				.9,0,0,0,
				0,.9,0,0,
				0,0,.9,0,
				0,0,0,1,
			]);
			var sp:turkey.display.Sprite = new turkey.display.Sprite();
			sp.mouseEnabled = false;
//			sp.colorMatrix = new Matrix3D(new <Number>[
//				2,0,0,0,
//				0,2,0,0,
//				0,0,5,0,
//				0,0,0,1,
//			]);
			sp.addChild(img);
			sp.addChild(img2);
			img.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			img.addEventListener(TurkeyMouseEvent.MOUSE_DOWN,onMouseDown);
			img.addEventListener(TurkeyMouseEvent.MOUSE_UP,onMouseUp);
			sp.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			Turkey.stage.addChild(sp);
//			addEventListener(Event.ENTER_FRAME,onEnterFrame);
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