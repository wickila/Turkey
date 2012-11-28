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
	import turkey.display.MovieClip;
	import turkey.events.TurkeyEvent;
	import turkey.events.TurkeyMouseEvent;
	import turkey.textures.Texture;
	import turkey.textures.TextureAtlas;
	
	[SWF(width="1000",height="600")]
	public class TurkeyTest extends flash.display.Sprite
	{
		private var _loader:Loader;
		private var _urlLoader:URLLoader;
		private var _img:Image;
		private var _textureAlas:TextureAtlas;
		public function TurkeyTest()
		{
			Turkey.init(stage);
			Turkey.stage.addEventListener(TurkeyEvent.COMPLETE,__createComplete);
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
			Turkey.stage.addChild(img);
			img.pivotX = -100;
			img.pivotY = -100;
			var mc:MovieClip = new MovieClip(_textureAlas.getTextures("test222"));
			mc.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			mc.pivotX = 74;
			mc.pivotY = 362;
			mc.x = mc.y = 200;
			mc.pixelHit = true;
//			Turkey.stage.addChild(mc);
			
			mc = new MovieClip(_textureAlas.getTextures("test222"));
			mc.addEventListener(TurkeyMouseEvent.CLICK,onClick);
			mc.pivotX = 74;
			mc.pivotY = 362;
			mc.x = mc.y = 400;
			mc.pixelHit = true;
			Turkey.stage.addChild(mc);
			
			
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