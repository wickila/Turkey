package turkey
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import turkey.core.Turkey;
	import turkey.display.DisplayObject;
	import turkey.display.Image;
	import turkey.enumrate.BlendMode;
	import turkey.utils.VertexData;

	public class TurkeyRenderer
	{
		private static var _textures:Vector.<TextureBase>=new Vector.<TextureBase>();
		private static var _blendModes:Vector.<String> = new Vector.<String>();
		private static var _vertexbuffer:VertexBuffer3D;
		private static var _vertexData:Vector.<Number> = new Vector.<Number>();
		private static var _indices:Vector.<uint> = new Vector.<uint>();
		private static var _indexBuffer:IndexBuffer3D;
		
		public static var context3D:Context3D;
		
		private static var _renderNum:uint=0;
		
		private static var _drawIndex:uint=0;
		private static var _drawIndexs:Vector.<int> = new Vector.<int>();
		private static var _currentTexture:TextureBase;
		private static var _currentBlendMode:String = null;
		private static var _colorSourceHelperVector:Vector.<Number> = new <Number>[1,1,1];
		private static var _colorHelperVector:Vector.<Number> = new Vector.<Number>(3);
		private static var _colorAlphaHelperVector:Vector3D = new Vector3D();
		
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
			//rebuildBuffer
			_vertexbuffer && _vertexbuffer.dispose();
			_indexBuffer && _indexBuffer.dispose();
			_vertexbuffer = context3D.createVertexBuffer(_renderNum<<2,VertexData.ELEMENTS_PER_VERTEX);
			_indexBuffer = context3D.createIndexBuffer(_indices.length);
			
			_vertexbuffer.uploadFromVector(_vertexData,0,_renderNum<<2);
			_indexBuffer.uploadFromVector(_indices,0,_indices.length);
			context3D.setVertexBufferAt(0, _vertexbuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
			context3D.setVertexBufferAt(1, _vertexbuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context3D.setVertexBufferAt(2, _vertexbuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			
			//drawTraingles
			var len:int = _drawIndexs.length;
			for(var i:int=0;i<len;i++)
			{
				_drawIndex = _drawIndexs[i];
				var arr:Array = BlendMode.getBlendFactors(_blendModes[i]);
				context3D.setBlendFactors(arr[0],arr[1]);
				context3D.setTextureAt(0, _textures[i]);
				context3D.drawTriangles(_indexBuffer,_drawIndex*6,((i==len-1)?(_renderNum-_drawIndex):(_drawIndexs[i+1]-_drawIndex))<<1);
			}
			
			//reset
			_renderNum = _drawIndex = 0;
			_indices = new Vector.<uint>();
			_vertexData = new Vector.<Number>();
			_drawIndexs = new Vector.<int>();
			_textures = new Vector.<TextureBase>();
			_blendModes = new Vector.<String>();
			_currentTexture = null;
			_currentBlendMode = null;
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
		
		/**
		 *	加入到渲染队列中 
		 * @param child 显示对象
		 * @param matrix 经过计算后的显示对象的位置信息
		 * @param alpha 经过计算后的显示对象的透明度
		 * 
		 */		
		public static function addChildForRender(child:DisplayObject,matrix:Matrix,colorMatrix:Matrix3D,alpha:Number):void
		{
			var raw:Vector.<Number> = child.vertexData.rawData;
			colorMatrix.transformVectors(_colorSourceHelperVector,_colorHelperVector);
			colorMatrix.copyRowTo(3,_colorAlphaHelperVector);
			
			var r:Number = _colorHelperVector[0];
			var g:Number = _colorHelperVector[1];
			var b:Number = _colorHelperVector[2];
			var m:int,l:int,x:Number,y:Number=0;
			var i:int = _renderNum<<5;//_renderNum * 4 * 8,4个顶点，每个顶点8个数据:x,y,r,g,b,a,u,v
			for(var j:int=0;j<4;j++)//此for循环里面做了四件事，1，把显示对象的顶点数据加入到渲染队列里面。2，设置顶点数据的空间坐标。3,设置顶点坐标的颜色值 4，设置顶点坐标的alpha颜色值 (_vertexData.append(child.vertexData);_vertexData.transformVertex(i*4,matrix,4);_vertexData.setAlpha(_renderNum*4,parentAlpha);
			{
				m = j<<3;//j*8
				l = i+m;
				x = raw[m];
				y = raw[m+1];
				_vertexData[l]   = matrix.a * x + matrix.c * y + matrix.tx;//x
				_vertexData[l+1] = matrix.d * y + matrix.b * x + matrix.ty;//y
				_vertexData[l+2] = r;//r
				_vertexData[l+3] = g;//g
				_vertexData[l+4] = b;//b
				_vertexData[l+5] = _colorAlphaHelperVector.x * r + _colorAlphaHelperVector.y * g + _colorAlphaHelperVector.z * b + _colorAlphaHelperVector.w * alpha;//a
				_vertexData[l+6] = raw[m+6];//u
				_vertexData[l+7] = raw[m+7];//v
			}
			i= _renderNum<<2;//_renderNum*4
			_indices.push(i,i+1,i+2,i+1,i+3,i+2);
			if((_currentTexture==null||_currentTexture != child.texture.base)||(_currentBlendMode==null||_currentBlendMode!=child.blendMode))//材质与blendmode相同的对象一起渲染
			{
				_drawIndexs.push(_renderNum);
				_textures.push(_currentTexture = child.texture.base);
				_blendModes.push(_currentBlendMode=child.blendMode);
			}
			_renderNum ++;
		}
	}
}