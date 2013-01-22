package turkey.display
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import turkey.core.Turkey;
	import turkey.textures.Texture;
	
	public class MovieClip extends Image
	{
		protected var _textures:Vector.<Texture>;
		protected var _index:int=0;
		protected var _totalFrame:int;
		protected var _playing:Boolean=false;
		public function MovieClip(textures:Vector.<Texture>)
		{
			super(textures[0]);
			_textures = textures;
			_totalFrame = _textures.length;
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		protected function onEnterFrame(event:Event):void
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
			if(_playing)return;
			_playing = true;
			Turkey.stage.stage2D.addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		public function puase():void
		{
			_playing = false;
			Turkey.stage.stage2D.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		override public function hitTest(localPoint:Point, forMouse:Boolean=false):DisplayObject
		{
				if (forMouse && (!visible||!mouseEnabled))return null;
				if(!_pixelHit)return super.hitTest(localPoint,forMouse);
				getBounds(this,_selfBounds);
				return (_selfBounds.contains(localPoint.x,localPoint.y) && (_bitmapdata.getPixel32(int(localPoint.x + _texture.frame.x + _texture.showRect.x),int(localPoint.y + _texture.frame.y + _texture.showRect.y))&0xff000000)!=0)?this:null;
		}
		
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			if (targetSpace == this) // optimization
			{
				vertexData.getPosition(3, sHelperPoint);
				resultRect.setTo(0.0, 0.0, _texture.frame.width, _texture.frame.height);
			}
			else if (targetSpace == parent && rotation == 0.0) // optimization
			{
				var scaleX:Number = this.scaleX;
				var scaleY:Number = this.scaleY;
				_vertexData.getPosition(3, sHelperPoint);
				resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
					sHelperPoint.x * scaleX, sHelperPoint.y * scaleY);
				if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
				if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
			}
			else
			{
				getTransformationMatrix(targetSpace, sHelperMatrix);
				_vertexData.getBounds(sHelperMatrix, 0, 4, resultRect);
			}
			
			return resultRect;
		}
		
		public function stop():void
		{
			_playing = false;
			_index = 0;
			texture = _textures[0];
			Turkey.stage.stage2D.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		override public function dispose():void
		{
			stop();
			_textures = null;
			super.dispose();
		}
	}
}