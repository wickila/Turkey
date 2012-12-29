package turkey.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.TextureBase;
	
	import turkey.core.Turkey;
	import turkey.utils.TurkeyUtils;

	public class GlowFilter extends BlurFilter
	{
		private var _glowProgram:Program3D = null;
		private var _addProgram:Program3D = null;
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
			context3D.setVertexBufferAt (0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(1, null);
			context3D.setVertexBufferAt(2,_vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setTextureAt(0,Turkey.sceneTexture);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, Turkey.stage.flashMatrix, true);
			context3D.setProgram(_glowProgram);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, colorVector);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _paramsH, 3);
			Turkey.swapSceneTexture();
			context3D.setRenderToTexture(Turkey.sceneTexture);
			context3D.clear(0,0,0,0);
			context3D.drawTriangles(_indexBuffer);
			
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _paramsV, 3);
			context3D.setTextureAt(0,Turkey.sceneTexture);
			context3D.setRenderToTexture(tempTexture);
			context3D.clear(0,0,0,0);
			context3D.drawTriangles(_indexBuffer);
			
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, GlowFilter_CONSTANTS);
			context3D.setProgram(_addProgram);
			Turkey.swapSceneTexture();
			context3D.setTextureAt(1,Turkey.sceneTexture);
			context3D.setTextureAt(0,tempTexture);
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
			if(_glowProgram == null)
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
					"add ft2, ft1, ft2\n"+
					"mul ft2, ft2.w, fc3\n" +
					"mul ft2, ft2, fc3.w\n" +
					"mov oc, ft2                               \n";
				
				var vertexProgramCode:String = "m44 op, va0, vc4\n" +//v4-v7为空间转屏幕坐标
					"mov v0 va2\n";
				_glowProgram = assembleAgal(fragmentCode, vertexProgramCode);
				_addProgram = assembleAgal("tex ft1, v0, fs0 <2d,linear,nomip>\n" +
					"tex ft2, v0, fs1 <2d,linear,nomip>\n" +
					"sub ft3.w, fc0.w, ft2.w\n"+
					"mul ft1.xyz, ft3.w, ft1.xyz\n" +
					"add oc, ft2, ft1\n", vertexProgramCode);
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
				tempTexture = Turkey.stage.context3D.createTexture(
					TurkeyUtils.getNextPowerOfTwo(Turkey.stage.stageWidth),
					TurkeyUtils.getNextPowerOfTwo(Turkey.stage.stageHeight),
					Context3DTextureFormat.BGRA,
					true
				);
			}
		}
	}
}