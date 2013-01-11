package turkey.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.TextureBase;
	
	import turkey.core.Turkey;

	public class GlowFilter extends BlurFilter
	{
		private var _blurProgram:Program3D = null;
		private var _glowProgram:Program3D = null;
		private var colorVector:Vector.<Number> = new Vector.<Number>(4,true);
		private static const GlowFilter_CONSTANTS:Vector.<Number> = new <Number>[1, 1, 1, 1];
		private static var tempTexture:TextureBase;
		public function GlowFilter(color:uint,blurX:Number=1, blurY:Number=1, strength:Number = 0)
		{
			super(blurX, blurY);
			colorVector[0] = ((uint(color>>16) & 0xff))/0xff;
			colorVector[1] = ((uint(color>>8) & 0xff))/0xff;
			colorVector[2] = ((uint(color) & 0xff))/0xff;
			colorVector[3] = 1+(strength/10);
		}
		
		override public function render(renderToBuff:Boolean=true):void
		{
			var context3D:Context3D = Turkey.stage.context3D;
			var origin:TextureBase = Turkey.sceneTexture;
			context3D.setProgram(_blurProgram);
			context3D.setVertexBufferAt (0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(1, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(2,null);//filter不处理rgba的变换
			context3D.setTextureAt(0,origin);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, Turkey.stage.flashMatrix, true);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _paramsH, 3);
			Turkey.swapSceneTexture();
			context3D.setRenderToTexture(Turkey.sceneTexture);
			context3D.clear(0,0,0,0);
			context3D.drawTriangles(_indexBuffer);
			context3D.setProgram(_glowProgram);
			context3D.setTextureAt(1,Turkey.sceneTexture);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _paramsV, 3);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, colorVector);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, GlowFilter_CONSTANTS);
			if(renderToBuff)
			{
				context3D.setRenderToBackBuffer();
			}else
			{
				Turkey.swapSceneTexture();
				context3D.setRenderToTexture(Turkey.sceneTexture);
				context3D.clear(0,0,0,0);
			}
			context3D.drawTriangles(_indexBuffer);
			context3D.setTextureAt(1,null);
		}
		
		override protected function createProgram():void
		{
			if(_blurProgram == null)
			{
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
				_blurProgram = createPrograms(false);
				_glowProgram = createPrograms(true);
			}
		}
		
		private function createPrograms(glow:Boolean):Program3D
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
			var i:int=0;
			if(glow)
			{
				fragmentCode = 		"mov ft0, v0	                                \n" +
					"tex ft3, ft0, fs0 <2d,linear,mipnone,clamp>    \n" +
					"sub ft0.xy, ft0.xy, fc0.xy                     \n" +
					"tex ft1, ft0, fs1 <2d,linear,mipnone,clamp>    \n" +
					"mul ft1, ft1, "+_gauss_regs[0]+"       \n" +
					"add ft0.xy, ft0.xy, fc0.zw                     \n";
				
				// Calculate the positions for the blur
				//-4, -3, -2, -1, 0, 1, 2, 3, 4
				
				for (i = 1; i < GAUSSIAN_SAMPLES-1; ++i)
				{
					
					fragmentCode +=             "tex ft2, ft0, fs1 <2d,linear,mipnone,clamp>    \n" +
						"mul ft2, ft2, "+_gauss_regs[i]+"       \n" +
						"add ft1, ft1, ft2                              \n" +
						"add ft0.xy, ft0.xy, fc0.zw                     \n";
				}
				
				fragmentCode +=             "tex ft2, ft0, fs1 <2d,linear,mipnone,clamp>    \n" +
					"mul ft2, ft2, " + _gauss_regs[8] + "   \n"
				fragmentCode+=	"add ft2, ft1, ft2\n" +
								"mul ft2, ft2.w, fc3\n" +
								"mul ft2, ft2, fc3.w\n" +
								
								"sub ft4.w, fc4.w, ft3.w\n" + //(1-ft3.w)
								"mul ft2, ft2, ft4.w\n"+ //ft2 * (1-ft3.w)
								"add oc, ft3, ft2";
			}else
			{
				fragmentCode = 		"mov ft0, v0	                                \n" +
					"sub ft0.xy, ft0.xy, fc0.xy                     \n" +
					"tex ft1, ft0, fs0 <2d,linear,mipnone,clamp>    \n" +
					"mul ft1, ft1, "+_gauss_regs[0]+"       \n" +
					"add ft0.xy, ft0.xy, fc0.zw                     \n";
				
				// Calculate the positions for the blur
				//-4, -3, -2, -1, 0, 1, 2, 3, 4
				
				for (i = 1; i < GAUSSIAN_SAMPLES-1; ++i)
				{
					
					fragmentCode +=             "tex ft2, ft0, fs0 <2d,linear,mipnone,clamp>    \n" +
						"mul ft2, ft2, "+_gauss_regs[i]+"       \n" +
						"add ft1, ft1, ft2                              \n" +
						"add ft0.xy, ft0.xy, fc0.zw                     \n";
				}
				
				fragmentCode +=             "tex ft2, ft0, fs0 <2d,linear,mipnone,clamp>    \n" +
					"mul ft2, ft2, " + _gauss_regs[8] + "   \n"
				fragmentCode += "add oc, ft1, ft2\n";
			}
				
			
			var vertexProgramCode:String = "m44 op, va0, vc4\n" +//v4-v7为空间转屏幕坐标
				"mov v0 va1\n";
			return assembleAgal(fragmentCode, vertexProgramCode);
		}
	}
}