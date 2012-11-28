package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import turkey.display.Image;
	import turkey.display.MovieClip;
	import turkey.display.Stage;
	import turkey.events.TurkeyEvent;
	import turkey.events.TurkeyMouseEvent;
	import turkey.textures.Texture;
	import turkey.textures.TextureAtlas;
	
	[SWF(width="1000",height="600")]
	public class TurkeyTest extends flash.display.Sprite
	{
		private var _stage2d:Stage;
		private var _loader:Loader;
		private var _urlLoader:URLLoader;
		private var _img:Image;
		private var _textureAlas:TextureAtlas;
		public function TurkeyTest()
		{
			_stage2d = new Stage(this.stage,0xffffff);
			_stage2d.addEventListener(TurkeyEvent.COMPLETE,__createComplete);
		}
		
		protected function __createComplete(event:TurkeyEvent):void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,onTextureComplete);
			_loader.load(new URLRequest("texture.png"));
		}
		
		protected function onTextureComplete(event:Event):void
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE,onDesComplete);
			_urlLoader.load(new URLRequest("description.xml"));
		}
		
		protected function onDesComplete(event:Event):void
		{
			var textureBody:Texture = Texture.fromBitmapData(Bitmap(_loader.content).bitmapData);//动画材质
			_textureAlas = new TextureAtlas(textureBody,new XML(_urlLoader.data));//动画解析文件
			var img:Image = new Image(textureBody);
			var mc:MovieClip = new MovieClip(_textureAlas.getTextures("test222"));
			mc.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			_stage2d.addChild(mc);
			img.buttonMode = true;
			img.pixelHit = true;
			mc.buttonMode = true;
			trace(mc.width);
			mc.pivotX = 74;
			mc.pivotY = 362;
			mc.x = mc.y = 200;
			mc.pixelHit = true;
			
			function onClick(event:TurkeyMouseEvent):void
			{
				if(mc.playing)
				{
					mc.puase();
				}else
				{
					mc.play();
				}
			}
		}
	}
}