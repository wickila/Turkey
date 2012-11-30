package turkey.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	
	import turkey.core.Turkey;
	import turkey.utils.TurkeyUtils;

	public class BlurFilter extends FragmentFilter
	{
		private static const GAUSSIAN_SAMPLES:int = 9;
		
		protected var _gaussians:Vector.<Number> = new <Number>[0.05, 0.09, 0.12, 0.15, 0.18, 0.15, 0.12, 0.09, 0.05];
		protected var _paramsH:Vector.<Number>;
		protected var _paramsV:Vector.<Number>;
		protected var _invW:Number;
		protected var _invH:Number;
		protected var _blurX:Number = 0.5;
		protected var _blurY:Number = 0.5;
		
		private static var _program:Program3D;
		private static var _vertexBuffer:VertexBuffer3D;
		private static var _indexBuffer:IndexBuffer3D;
		
		public function BlurFilter(blurX:Number=1, blurY:Number=1)
		{
			super();
			_paramsH = new <Number>[];
			_paramsH.length = 12;
			// cut repeated values
			for(var i:int = 0; i < GAUSSIAN_SAMPLES-4; ++i)
			{
				_paramsH[i+4] = _gaussians[i];
			}
			_invW = 1/TurkeyUtils.getNextPowerOfTwo(Turkey.stage.stageWidth);
			this.blurX = blurX;
			
			_paramsV = new <Number>[];
			_paramsV.length = 12;
			// cut repeated values
			for(i = 0; i < GAUSSIAN_SAMPLES-4; ++i)
			{
				_paramsV[i+4] = _gaussians[i];
			}
			_invH = 1/TurkeyUtils.getNextPowerOfTwo(Turkey.stage.stageHeight);
			
			this.blurY = blurY; 
		}
		
		override public function render(isLast:Boolean=true):void
		{
			var context3D:Context3D = Turkey.stage.context3D;
			context3D.setProgram(_program);
			context3D.setVertexBufferAt (0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(1, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(2,null);//filter不处理rgba的变换
			context3D.setTextureAt(0,Turkey.sceneTexture);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, Turkey.stage.flashMatrix, true);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _paramsH, 3);
			Turkey.swapSceneTexture();
			context3D.setRenderToTexture(Turkey.sceneTexture);
			context3D.clear(0,0,0,0);
			context3D.drawTriangles(_indexBuffer);
			context3D.setTextureAt(0,Turkey.sceneTexture);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _paramsV, 3);
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
		
		override protected function createProgram():void
		{
			if(_program == null)
			{
				var fragmentCode:String;
				
				var _gauss_regs:Vector.<String> = new Vector.<String>(9);
				_gauss_regs[0] = "fc1.x";
				_gauss_regs[1] = "fc1.y";
				_gauss_regs[2] = "fc1.z";
				_gauss_regs[3] = "fc1.w";
				_gauss_regs[4] = "fc2.x"; // cut line
				_gauss_regs[5] = "fc1.w";
				_gauss_regs[6] = "fc1.z";
				_gauss_regs[7] = "fc1.y";
				_gauss_regs[8] = "fc1.x";
				
				fragmentCode = 		"mov ft0, v0	                                \n" +
					"sub ft0.xy, ft0.xy, fc0.xy                     \n" +
					"tex ft1, ft0, fs0 <2d,linear,mipnone,clamp>    \n" +
					"mul ft1, ft1, "+_gauss_regs[0]+"       \n" +
					"add ft0.xy, ft0.xy, fc0.zw                     \n";
				
				// Calculate the positions for the blur
				//-4, -3, -2, -1, 0, 1, 2, 3, 4
				
				for (var i:int = 1; i < GAUSSIAN_SAMPLES-1; ++i)
				{
					
					fragmentCode +=             "tex ft2, ft0, fs0 <2d,linear,mipnone,clamp>    \n" +
						"mul ft2, ft2, "+_gauss_regs[i]+"       \n" +
						"add ft1, ft1, ft2                              \n" +
						"add ft0.xy, ft0.xy, fc0.zw                     \n";
				}
				
				fragmentCode +=             "tex ft2, ft0, fs0 <2d,linear,mipnone,clamp>    \n" +
					"mul ft2, ft2, " + _gauss_regs[8] + "   \n" +
					"add oc, ft1, ft2                               \n";
				
				var vertexProgramCode:String = "m44 op, va0, vc4\n" +//v4-v7为空间转屏幕坐标
					"mov v0 va1\n";
				_program = assembleAgal(fragmentCode, vertexProgramCode);
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
		
		public function get blurX():Number { return _blurX; }
		public function set blurX(value:Number):void
		{
			_blurX = value;
			_paramsH[0] = _invW * _blurX * 4.;
			_paramsH[2] = _invW * _blurX;
		}
		
		public function get blurY():Number { return _blurY; }
		public function set blurY(value:Number):void
		{
			_blurY = value;
			_paramsV[1] = _invH * _blurY * 4.;
			_paramsV[3] = _invH * _blurY;
		}
		
	}
}