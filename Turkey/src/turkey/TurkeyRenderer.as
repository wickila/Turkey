package turkey
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	
	import turkey.core.Turkey;
	import turkey.display.DisplayObject;
	import turkey.display.Image;
	import turkey.enumrate.BlendMode;
	import turkey.utils.VertexData;

	public class TurkeyRenderer
	{
		private static var _displayObjects:Vector.<DisplayObject>=new Vector.<DisplayObject>();
		private static var _matrices:Vector.<Matrix> = new Vector.<Matrix>();
		private static var _alhpas:Vector.<Number> = new Vector.<Number>();
		private static var _vertices:Vector.<Number> = new Vector.<Number>();
		private static var _vertexbuffer:VertexBuffer3D;
		private static var _vertexData:VertexData;
		private static var _indices:Vector.<uint> = new Vector.<uint>();
		private static var _indexBuffer:IndexBuffer3D;
		private static var _program:Program3D;
		
		private static var _renderNum:uint=0;
		private static var _renderIndex:uint=0;
		
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
		}
		
		private static function drawTriangles():void
		{
			var context3D:Context3D = Turkey.stage.context3D;
			context3D.setProgram(Turkey.getProgram(Image.IMAGE_PROGRAM));
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, Turkey.stage.flashMatrix, true);
			for(_renderIndex=0;_renderIndex<_renderNum;_renderIndex++)
			{
				var displayObj:DisplayObject = _displayObjects[_renderIndex];
				context3D.setTextureAt(0, displayObj.texture.base);
				var arr:Array = BlendMode.getBlendFactors(displayObj.blendMode);
				context3D.setBlendFactors(arr[0],arr[1]);
				context3D.drawTriangles(_indexBuffer,_renderIndex*6,2);
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
			_vertexData = new VertexData(_renderNum * 4);
			for(var i:int=0;i<_renderNum;i++)
			{
				_displayObjects[i].vertexData.copyTo(_vertexData, i*4);
				_vertexData.transformVertex(i*4,_matrices[i],4);
				_vertexData.setAlpha(i*4,_alhpas[i]);
				_vertexData.setAlpha(i*4+1,_alhpas[i]);
				_vertexData.setAlpha(i*4+2,_alhpas[i]);
				_vertexData.setAlpha(i*4+3,_alhpas[i]);
				_indices.push(i*4,i*4+1,i*4+2,i*4+1,i*4+3,i*4+2);
			}
			_vertexbuffer = context3D.createVertexBuffer(_renderNum * 4,VertexData.ELEMENTS_PER_VERTEX);
			_indexBuffer = context3D.createIndexBuffer(_indices.length);
			
			_vertexbuffer.uploadFromVector(_vertexData.rawData,0,_renderNum * 4);
			_indexBuffer.uploadFromVector(_indices,0,_indices.length);
			context3D.setVertexBufferAt(0, _vertexbuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
			context3D.setVertexBufferAt(1, _vertexbuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context3D.setVertexBufferAt(2, _vertexbuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
		}
		/**
		 *	加入到渲染队列中 
		 * @param child
		 * @param parentMatrix
		 * @param parentAlpha
		 * 
		 */		
		public static function addChildForRender(child:DisplayObject,matrix:Matrix,alpha:Number):void
		{
			_displayObjects.push(child);
			_matrices.push(matrix);
			_alhpas.push(alpha);
			_renderNum ++;
		}
		
		/**
		 *	重置渲染数据 
		 * 
		 */		
		public static function reset():void
		{
			_renderNum = _renderIndex = 0;
			_vertices = new Vector.<Number>();
			_indices = new Vector.<uint>();
			_displayObjects = new Vector.<DisplayObject>();
			_matrices = new Vector.<Matrix>();
			_alhpas = new Vector.<Number>();
		}
	}
}