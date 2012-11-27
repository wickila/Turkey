package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import turkey.display.Image;
	import turkey.display.Sprite;
	import turkey.display.Stage;
	import turkey.events.TurkeyEvent;
	import turkey.events.TurkeyMouseEvent;
	import turkey.textures.Texture;
	
	[SWF(width="800",height="600")]
	public class TurkeyTest extends flash.display.Sprite
	{
		private var _stage2d:Stage;
		private var _loader:Loader;
		private var _urlLoader:URLLoader;
		private var _img:Image;
		public function TurkeyTest()
		{
			_stage2d = new Stage(this.stage,0xffffff);
			_stage2d.addEventListener(TurkeyEvent.COMPLETE,__createComplete);
		}
		
		protected function __createComplete(event:TurkeyEvent):void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,onTextureComplete);
			_loader.load(new URLRequest("effect.png"));
		}
		
		protected function onTextureComplete(event:Event):void
		{
			var sp:turkey.display.Sprite = new turkey.display.Sprite();
			_img = new Image(Texture.fromBitmapData(Bitmap(_loader.content).bitmapData));
			_img.mouseEnabled = false;
//			_img.scaleX = _img.scaleY = 3;
//			_img.rotation = 30*Math.PI/180;
//			_img.x = 200;
//			_img.alpha = .5;
//			_img.alpha = .2;
			sp.x = 200;
//			sp.mouseChildren = false;
//			sp.addChild(_img);
			sp.buttonMode = true;
			_img.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			sp.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			sp.addEventListener(TurkeyMouseEvent.MOUSE_OUT,onMouseOut);
			sp.y = 200;
//			sp.alpha = .1;
//			sp.rotation = 30*Math.PI/180;
			_stage2d.addChild(_img);
//			_img = new Image(Texture.fromBitmapData(Bitmap(_loader.content).bitmapData));
//			_img.x = 100;
//			_img.y = 100;
//			_img.alpha = .8;
//			sp.x = 100;
//			_stage2d.addChild(_img);
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			function onEnterFrame(event1:Event):void
			{
//				sp.rotation += Math.PI/180;
			}
			
			function onClick(event:TurkeyMouseEvent):void
			{
				trace(event.target,event.localX,event.localY,event.stageX,event.stageY);
			}
			function onMouseOut(event:TurkeyMouseEvent):void
			{
				trace(event.target,event.localX,event.localY,event.stageX,event.stageY);
			}
		}
	}
}