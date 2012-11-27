package turkey.display
{
	import flash.display.BitmapData;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import turkey.textures.Texture;
	import turkey.utils.TurkeyUtils;

	public class Image extends Quad
	{
		private var _texture:Texture;
		private var _bitmapdata:BitmapData;
		public function Image(texture:Texture)
		{
			if (texture)
			{
				_texture = texture;
				var frame:Rectangle = texture.frame;
				var width:Number  = frame ? frame.width  : texture.width;
				var height:Number = frame ? frame.height : texture.height;
				var pma:Boolean = texture.premultipliedAlpha;
				super(width, height, 0x00000000, pma);
				var u:Number = width/TurkeyUtils.getNextPowerOfTwo(width);
				var v:Number = height/TurkeyUtils.getNextPowerOfTwo(height);
				_vertexData.setTexCoords(0, 0.0, 0.0);
				_vertexData.setTexCoords(1, u, 0.0);
				_vertexData.setTexCoords(2, 0.0, v);
				_vertexData.setTexCoords(3, u, v);
				_bitmapdata = _texture.bitmapData;
			}
			else
			{
				throw new ArgumentError("Texture cannot be null");
			}
		}
		
		override public function hitTest(localPoint:Point, forMouse:Boolean=false):DisplayObject
		{
			if (forMouse && (!visible||!mouseEnabled))return null;
			if(!_pixelHit)return super.hitTest(localPoint,forMouse);
			return (_bitmapdata.getPixel32(localPoint.x,localPoint.y)&0xff000000)!=0?this:null;
		}
		
		override public function get width():Number
		{
			return _texture.nativeWidth;
		}
		
		override public function get height():Number
		{
			return _texture.nativeHeight;
		}
		
		override public function get texture():TextureBase
		{
			return _texture.base;
		}
	}
}