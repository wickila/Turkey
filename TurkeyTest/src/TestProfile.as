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
	import turkey.events.TurkeyEvent;
	import turkey.textures.Texture;
	
	[SWF(width="800",height="600",frameRate="60")]
	public class TestProfile extends flash.display.Sprite
	{
		private var _loader:Loader;
		private var _urlLoader:URLLoader;
		private var _img:Image;
		public function TestProfile()
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
			var texture:Texture = Texture.fromBitmap(Bitmap(_loader.content));
			for(var i:int=0;i<2000;i++)
			{
				var img:Image = new Image(texture);
				img.x = stage.stageWidth*Math.random();
				img.y = stage.stageHeight*Math.random();
				img.buttonMode = true;
				img.mouseEnabled = false;
				Turkey.stage.addChild(img);
			}
		}
	}
}