package turkey
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	
	import turkey.core.Turkey;
	import turkey.display.DisplayObject;
	import turkey.display.Image;
	import turkey.utils.VertexData;

	public class TurkeyRenderer
	{
		private static var _textures:Vector.<TextureBase>=new Vector.<TextureBase>();
		private static var _vertices:Vector.<Number> = new Vector.<Number>();
		private static var _vertexbuffer:VertexBuffer3D;
		private static var _vertexData:Vector.<Number> = new Vector.<Number>();
		private static var _indices:Vector.<uint> = new Vector.<uint>();
		private static var _indexBuffer:IndexBuffer3D;
		private static var _program:Program3D;
		
		private static var _renderNum:uint=0;
		
		private static var _drawIndex:uint=0;
		private static var _drawIndexs:Vector.<int> = new Vector.<int>();
		private static var _currentTexture:TextureBase;
		
		public function TurkeyRenderer()
		{
			
		}
		/**
		 *	将渲染队列渲染到依次渲染,然后清空渲染队列,重置渲染数据
		 * 
		 */		
		public static function render():void
		{
			if(_renderNum<1)return;
			rebuildBuffer();
			drawTriangles();
			reset();
		}
		
		/**
		 *	准备进行滤镜渲染，详情见http://jacksondunstan.com/articles/1998，译文地址：http://bbs.9ria.com/thread-156067-1-1.html 
		 * 
		 */		
		public static function preFilter():void
		{
			render();
			Turkey.stage.context3D.setRenderToTexture(Turkey.sceneTexture, false);
			Turkey.stage.context3D.clear(0,0,0,0);//此处一定要清屏为0,0,0,0，不能是默认的舞台颜色
		}
		/**
		 *	滤镜渲染完毕，重新设置回正常渲染模式 
		 * 
		 */		
		public static function endFilter():void
		{
			Turkey.stage.context3D.setProgram(Turkey.getProgram(Image.IMAGE_PROGRAM));
			Turkey.stage.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, Turkey.stage.flashMatrix, true);
		}
		
		private static function drawTriangles():void
		{
			var context3D:Context3D = Turkey.stage.context3D;
			for(var i:int=0;i<_drawIndexs.length;i++)
			{
				_drawIndex = _drawIndexs[i];
				context3D.setTextureAt(0, _textures[i]);
				var num:int = (i==_drawIndexs.length-1)?(_renderNum-_drawIndex):(_drawIndexs[i+1]-_drawIndex);
				context3D.drawTriangles(_indexBuffer,_drawIndexs[i]*6,num<<1);
			}
		}
		
		/**
		 *	根据渲染对象池来更新渲染数据 
		 * 
		 */		
		private static function rebuildBuffer():void
		{
			var context3D:Context3D = Turkey.stage.context3D;
			_vertexbuffer && _vertexbuffer.dispose();
			_indexBuffer && _indexBuffer.dispose();
			_vertexbuffer = context3D.createVertexBuffer(_renderNum<<2,VertexData.ELEMENTS_PER_VERTEX);
			_indexBuffer = context3D.createIndexBuffer(_indices.length);
			
			_vertexbuffer.uploadFromVector(_vertexData,0,_renderNum<<2);
			_indexBuffer.uploadFromVector(_indices,0,_indices.length);
			context3D.setVertexBufferAt(0, _vertexbuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
			context3D.setVertexBufferAt(1, _vertexbuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context3D.setVertexBufferAt(2, _vertexbuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
		}
		/**
		 *	加入到渲染队列中 
		 * @param child 显示对象
		 * @param matrix 经过计算后的显示对象的位置信息
		 * @param alpha 经过计算后的显示对象的透明度
		 * 
		 */		
		public static function addChildForRender(child:DisplayObject,matrix:Matrix,alpha:Number):void
		{
			var raw:Vector.<Number> = child.vertexData.rawData;
			var i:int = _renderNum<<5;//_renderNum * 4 * 8,4个顶点，每个顶点8个数据:x,y,r,g,b,a,u,v
			for (var j:int=0; j<4; ++j)//此for循环里面做了三件事，1，把显示对象的顶点数据加入到渲染队列里面。2，设置顶点数据的空间坐标。 3，设置顶点坐标的alpha颜色值 (_vertexData.append(child.vertexData);_vertexData.transformVertex(i*4,matrix,4);_vertexData.setAlpha(_renderNum*4,parentAlpha);
			{
				var m:int = j<<3;//j*8
				var x:Number = raw[m];
				var y:Number = raw[m+1];
				_vertexData[i+m]   = matrix.a * x + matrix.c * y + matrix.tx;//x
				_vertexData[i+m+1] = matrix.d * y + matrix.b * x + matrix.ty;//y
				_vertexData[i+m+2] = raw[m+2];//r
				_vertexData[i+m+3] = raw[m+3];//g
				_vertexData[i+m+4] = raw[m+4];//b
				_vertexData[i+m+5] = alpha;//a
				_vertexData[i+m+6] = raw[m+6];//u
				_vertexData[i+m+7] = raw[m+7];//v
			}
			i= _renderNum<<2;//_renderNum*4
			_indices.push(i,i+1,i+2,i+1,i+3,i+2);
			if(_currentTexture==null){_currentTexture=child.texture.base;_drawIndexs.push(_renderNum);_textures.push(_currentTexture);};
			if(_currentTexture != child.texture.base)
			{
				_drawIndexs.push(_renderNum);
				_currentTexture = child.texture.base;
				_textures.push(_currentTexture);
			}
			_renderNum ++;
		}
		
		/**
		 *	重置渲染数据 
		 * 
		 */		
		public static function reset():void
		{
			_renderNum = _drawIndex = 0;
			_vertices = new Vector.<Number>();
			_indices = new Vector.<uint>();
			_vertexData = new Vector.<Number>();
			_drawIndexs = new Vector.<int>();
			_textures = new Vector.<TextureBase>();
			_currentTexture = null;
		}
	}
}