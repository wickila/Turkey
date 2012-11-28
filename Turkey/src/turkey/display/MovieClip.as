package turkey.display
{
	import flash.geom.Point;
	
	import turkey.events.TurkeyEnterFrameEvent;
	import turkey.textures.Texture;
	
	public class MovieClip extends Image
	{
		protected var _textures:Vector.<Texture>;
		protected var _index:int=0;
		protected var _totalFrame:int;
		protected var _playing:Boolean=true;
		public function MovieClip(textures:Vector.<Texture>)
		{
			super(textures[0]);
			_textures = textures;
			_totalFrame = _textures.length;
			initEvents();
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}

		protected function initEvents():void
		{
			addEventListener(TurkeyEnterFrameEvent.ENTER_FRAME,onEnterFrame);
		}
		
		private function onEnterFrame(event:TurkeyEnterFrameEvent):void
		{
			update();
		}
		
		protected function update():void
		{
			_index = (_index+1)%_totalFrame;
			texture = _textures[_index];
		}
		
		public function get totalFrame():int
		{
			return _totalFrame;
		}
		
		public function get currentFrame():int
		{
			return _index+1;
		}
		
		override public function get width():Number
		{
			return getBounds(this).width;
		}
		
		override public function get height():Number
		{
			return getBounds(this).height;
		}
		
		public function play():void
		{
			_playing = true;
			addEventListener(TurkeyEnterFrameEvent.ENTER_FRAME,onEnterFrame);
		}
		
		public function puase():void
		{
			_playing = false;
			removeEventListener(TurkeyEnterFrameEvent.ENTER_FRAME,onEnterFrame);
		}
		
		override public function hitTest(localPoint:Point, forMouse:Boolean=false):DisplayObject
		{
				if (forMouse && (!visible||!mouseEnabled))return null;
				if(!_pixelHit)return super.hitTest(localPoint,forMouse);
				return (_bitmapdata.getPixel32(int(localPoint.x + _texture.frame.x + _texture.showRect.x),int(localPoint.y + _texture.frame.y + _texture.showRect.y))&0xff000000)!=0?this:null;
		}
		
		public function stop():void
		{
			_playing = false;
			_index = 0;
			texture = _textures[0];
			removeEventListener(TurkeyEnterFrameEvent.ENTER_FRAME,onEnterFrame);
		}
	}
}