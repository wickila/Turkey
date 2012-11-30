package turkey.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	
	import turkey.core.Turkey;

	public class RadialBlurFilter extends FragmentFilter
	{
		private static var _indexBuffer : IndexBuffer3D = null;
		private static var _vertexBuffer : VertexBuffer3D=null;
		private static var _program:Program3D = null;
		
		private var _constParam:Vector.<Number>;
		private static const STEP:int = 5;
		private var _scaleMatrix:Matrix3D;
		private var _distance:Number;
		private var _xOffset:Number;
		private var _yOffset:Number;
		
		/**
		 *	径向模糊滤镜，可以创造类似快速运动的效果。 
		 * @param xOffset 放射中心x坐标(相对于舞台，取值0～1）
		 * @param yOffset 放射中心y坐标(相对于舞台，取值0～1）
		 * @param distance 放射幅度
		 * 
		 */		
		public function RadialBlurFilter(xOffset:Number = 0.5,yOffset:Number = 0.5,distance:Number = 0.005)
		{
			_constParam = new <Number>[STEP,distance,xOffset,yOffset];
			_scaleMatrix = new Matrix3D();
			this.distance = distance;
			this.xOffset = xOffset;
			this.yOffset = yOffset;
		}
		
		override protected function createProgram():void
		{
			if(_program == null)
			{
				var vertexProgram:String = "m44 op, va0, vc0\nmov v0, va1\n";
				var code:String = "";
				code += "tex ft0, v0, fs0 <2d,linear>\n" +
					"mov ft1, fc1\n"+
					"mov ft2, fc2\n"+
					"mov ft3, fc3\n"+
					"mov ft4, fc4\n";
				for (var i:int = 0; i < STEP; i++) 
				{
					code +=
						"sub ft1.x, ft1.x,fc0.y \n"+//scale x
						"sub ft2.y, ft2.y,fc0.y \n"+//scale y
						
						"mul ft6.x, ft1.x,fc0.z \n"+//scaleX*offx;
						"sub ft6.x, fc0.z,ft6.x \n"+//offx-scaleX*offx;
						"mov ft1.w, ft6.x \n"+
						
						"mul ft6.x, ft2.y,fc0.w \n"+
						"sub ft6.x, fc0.w,ft6.x \n"+
						"mov ft2.w, ft6.x \n"+
						
						"mov ft5, v0\n" +//,repeat,miplinear
						"m44 ft5, ft5, ft1\n" +//乘以缩放矩阵
						"tex ft5, ft5, fs0 <2d,linear>\n" +//,repeat,miplinear
						"add ft0, ft0, ft5\n";
				}
				
				code +=
					"div oc, ft0, fc0.x\n"//,repeat,miplinear
				_program = assembleAgal(code,vertexProgram);
				_vertexBuffer = Turkey.stage.context3D.createVertexBuffer(4, 8);
				var w:Number = Turkey.stage.stageWidth;
				var h:Number = Turkey.stage.stageHeight;
				_vertexBuffer.uploadFromVector(Vector.<Number>([
					0,0,0,0,0,1,0,0,
					w,0,0,0,0,1,1,0,
					w,h,0,0,0,1,1,1,
					0,h,0,0,0,1,0,1
				]), 0, 4);
				_indexBuffer = Turkey.stage.context3D.createIndexBuffer(6);
				_indexBuffer.uploadFromVector(INDEX_VECTOR, 0, 6);
			}
		}
		
		override public function render(isLast:Boolean=true):void
		{
			var context3D:Context3D = Turkey.stage.context3D;
			context3D.setProgram(_program);
			context3D.setTextureAt (0, Turkey.sceneTexture);
			context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(1, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(2,null);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,_constParam);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.FRAGMENT,1,_scaleMatrix,true);
			if(isLast)
			{
				context3D.setRenderToBackBuffer();
			}else
			{
				Turkey.swapSceneTexture();
				context3D.setRenderToTexture(Turkey.sceneTexture);
				context3D.clear(0,0,0,0);
			}
			context3D.drawTriangles(_indexBuffer);
		}
		
		public function get distance():Number
		{
			return _distance;
		}
		
		public function set distance(value:Number):void
		{
			_distance = value;
			_constParam[1] = value;
		}
		
		public function get xOffset():Number
		{
			return _xOffset;
		}
		
		public function set xOffset(value:Number):void
		{
			_xOffset = value;
			_constParam[2] = value;
		}
		
		public function get yOffset():Number
		{
			return _yOffset;
		}
		
		public function set yOffset(value:Number):void
		{
			_yOffset = value;
			_constParam[3] = value;
		}
	}
}