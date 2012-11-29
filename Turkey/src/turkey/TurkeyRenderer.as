package turkey
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	
	import turkey.core.Turkey;
	import turkey.display.DisplayObject;
	import turkey.display.DisplayObjectContainer;
	import turkey.display.Image;
	import turkey.display.Stage;
	import turkey.enumrate.BlendMode;
	import turkey.utils.MatrixUtil;
	import turkey.utils.VertexData;

	public class TurkeyRenderer
	{
		private static var _displayObjects:Vector.<DisplayObject>;
		private static var _matrices:Vector.<Matrix>;
		private static var _alhpas:Vector.<Number>;
		private static var _vertices:Vector.<Number>;
		private static var _vertexbuffer:VertexBuffer3D;
		private static var _vertexData:VertexData;
		private static var _indices:Vector.<uint>;
		private static var _indexBuffer:IndexBuffer3D;
		private static var _program:Program3D;
		
		private static var _renderNum:uint;
		private static var _renderIndex:uint;
		
		public function TurkeyRenderer()
		{
			
		}
		/**
		 *	渲染某个对象 
		 * @param child
		 * @param parentMatrix
		 * @param parentAlpha
		 * 
		 */		
		public static function render(child:DisplayObject,parentMatrix:Matrix,parentAlpha:Number=1):void
		{
			Turkey.stage.clear();
			reset();
			addChildForRender(child,parentMatrix,parentAlpha);
			if(_renderNum<1)return;
			rebuildBuffer();
			Turkey.stage.context3D.setProgram(Turkey.getProgram(Image.IMAGE_PROGRAM));
			drawTriangles();
			Turkey.stage.context3D.present();
		}
		
		private static function drawTriangles():void
		{
			for(_renderIndex=0;_renderIndex<_renderNum;_renderIndex++)
			{
				Turkey.stage.context3D.setTextureAt(0, _displayObjects[_renderIndex].texture.base);
				var arr:Array = BlendMode.getBlendFactors(_displayObjects[_renderIndex].blendMode);
				Turkey.stage.context3D.setBlendFactors(arr[0],arr[1]);
				Turkey.stage.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, Turkey.stage.flashMatrix, true);
				Turkey.stage.context3D.drawTriangles(_indexBuffer,_renderIndex*6,2);
			}
		}
		
		/**
		 *	根据渲染对象池来更新渲染数据 
		 * 
		 */		
		private static function rebuildBuffer():void
		{
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
			_vertexbuffer = Turkey.stage.context3D.createVertexBuffer(_renderNum * 4,VertexData.ELEMENTS_PER_VERTEX);
			_indexBuffer = Turkey.stage.context3D.createIndexBuffer(_indices.length);
			
			_vertexbuffer.uploadFromVector(_vertexData.rawData,0,_renderNum * 4);
			_indexBuffer.uploadFromVector(_indices,0,_indices.length);
			Turkey.stage.context3D.setVertexBufferAt(0, _vertexbuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
			Turkey.stage.context3D.setVertexBufferAt(1, _vertexbuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			Turkey.stage.context3D.setVertexBufferAt(2, _vertexbuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
		}
		/**
		 *	加入到渲染队列中 
		 * @param child
		 * @param parentMatrix
		 * @param parentAlpha
		 * 
		 */		
		private static function addChildForRender(child:DisplayObject,parentMatrix:Matrix,parentAlpha:Number):void
		{
			var alpha:Number = child.alpha*parentAlpha;
			var matrix:Matrix = parentMatrix.clone();
			if(child.hasVisibleArea)
			{
				if(child is DisplayObjectContainer)
				{
					var numChildren:uint = DisplayObjectContainer(child).numChildren;
					for(var i:int;i<numChildren;i++)
					{
						var newMatrix:Matrix = matrix.clone();
						MatrixUtil.prependMatrix(newMatrix,DisplayObjectContainer(child).getChildAt(i).transformationMatrix);
						addChildForRender(DisplayObjectContainer(child).getChildAt(i),newMatrix,alpha)
					}
				}else
				{
					_displayObjects.push(child);
					_matrices.push(matrix);
					_alhpas.push(alpha);
					_renderNum ++;
				}
			}
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