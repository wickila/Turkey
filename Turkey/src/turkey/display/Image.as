package turkey.display
{
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;
	
	import turkey.textures.Texture;

	public class Image extends Quad
	{
		private var _texture:Texture;
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
				_vertexData.setTexCoords(0, 0.0, 0.0);
				_vertexData.setTexCoords(1, 1.0, 0.0);
				_vertexData.setTexCoords(2, 0.0, 1.0);
				_vertexData.setTexCoords(3, 1.0, 1.0);
			}
			else
			{
				throw new ArgumentError("Texture cannot be null");
			}
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