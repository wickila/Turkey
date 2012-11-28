package turkey.display
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import turkey.textures.Texture;
	import turkey.utils.TurkeyUtils;
	import turkey.utils.VertexData;

	public class Image extends Quad
	{
		protected var _texture:Texture;
		protected var _bitmapdata:BitmapData;
		private var _vertexDataCache:VertexData;
		protected var _vertexDataChanged:Boolean;
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
				_vertexData.setTexCoords(0, 0.0, 0.0);
				_vertexData.setTexCoords(1, 1.0, 0.0);
				_vertexData.setTexCoords(2, 0.0, 1.0);
				_vertexData.setTexCoords(3, 1.0, 1.0);
				_bitmapdata = _texture.bitmapData;
				_vertexDataCache = new VertexData(4);
				_vertexDataChanged = true;
			}
			else
			{
				throw new ArgumentError("Texture cannot be null");
			}
		}
		
		public function set texture(value:Texture):void
		{
			_texture = value;
			_bitmapdata = _texture.bitmapData;
			_vertexDataChanged = true;
		}

		override public function hitTest(localPoint:Point, forMouse:Boolean=false):DisplayObject
		{
			if (forMouse && (!visible||!mouseEnabled))return null;
			if(!_pixelHit)return super.hitTest(localPoint,forMouse);
			return (_bitmapdata.getPixel32(localPoint.x,localPoint.y)&0xff000000)!=0?this:null;
		}
		
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			if (targetSpace == this) // optimization
			{
				vertexData.getPosition(0,sHelperPoint);var rx:int = sHelperPoint.x;var ry:int = sHelperPoint.y;
				vertexData.getPosition(3, sHelperPoint);
				resultRect.setTo(rx, ry, sHelperPoint.x, sHelperPoint.y);
			}else if (targetSpace == parent && rotation == 0.0) // optimization
			{
				var scaleX:Number = this.scaleX;
				var scaleY:Number = this.scaleY;
				vertexData.getPosition(3, sHelperPoint);
				resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
					sHelperPoint.x * scaleX, sHelperPoint.y * scaleY);
				if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
				if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
			}
			else
			{
				getTransformationMatrix(targetSpace, sHelperMatrix);
				vertexData.getBounds(sHelperMatrix, 0, 4, resultRect);
			}
			
			return resultRect;
		}
		
		override public function get vertexData():VertexData
		{
			if(_vertexDataChanged)
			{
				_vertexDataChanged = false;
				_vertexData.copyTo(_vertexDataCache);
				_texture.adjustVertexData(_vertexDataCache, 0, 4);
			}
			return _vertexDataCache;
		}
		
		override public function get width():Number
		{
			return _texture.nativeWidth;
		}
		
		override public function get height():Number
		{
			return _texture.nativeHeight;
		}
		
		override public function get texture():Texture
		{
			return _texture;
		}
	}
}