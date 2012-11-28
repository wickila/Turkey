package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import turkey.core.Turkey;
	import turkey.display.Image;
	import turkey.display.Sprite;
	import turkey.events.TurkeyEvent;
	import turkey.events.TurkeyMouseEvent;
	import turkey.textures.Texture;
	
	[SWF(width="1000",height="600")]
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
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onTextureComplete);
			_loader.load(new URLRequest("image.png"));
		}
		
		protected function onTextureComplete(event:Event):void
		{
			var img:Image = new Image(Texture.fromBitmap(Bitmap(_loader.content)));
			var sp:turkey.display.Sprite = new turkey.display.Sprite();
			sp.mouseEnabled = false;
			sp.addChild(img);
			img.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			sp.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			Turkey.stage.addChild(sp);
			
			function onClick(event1:TurkeyMouseEvent):void
			{
				trace(event1.currentTarget);
			}
		}
	}
}