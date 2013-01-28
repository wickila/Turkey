package turkey.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;
	
	import turkey.core.Turkey;
	import turkey.filters.FragmentFilter;
	
	/**
	 * Depth of field post effect.
	 */
	public class WavesFilter extends FragmentFilter
	{
		// Cache	
		private static var programCache:Dictionary = new Dictionary(true);
		private var finalProgram:Program3D;
		
		private var hOffset:Number;
		private var vOffset:Number;
		
		private var prevPrerenderTexWidth:int = 0;
		private var prevPrerenderTexHeight:int = 0;
		private var constant:Vector.<Number> = new <Number>[0, 0, 0, 0];
		
		public var frequencyX:Number = 1;
		public var frequencyY:Number = 20;
		public var amount:Number = 1;
			
		protected static var _vertexBuffer:VertexBuffer3D;
		protected static var _indexBuffer:IndexBuffer3D;
		
		public function WavesFilter()
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
		}
		
		/**
		 * @inherit
		 */
		override public function render(renderToBuff:Boolean=true):void
		{
			var context3D:Context3D = Turkey.stage.context3D;
			context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(1, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);		
			context3D.setVertexBufferAt(2,null);//filter不处理rgba的变换
			constant[0] = frequencyX;
			constant[1] = frequencyY;	
			constant[2] = 5;
			constant[3] = amount;
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, constant, 1);	
			constant[0] = 1000;
			constant[1] = 600;
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, constant, 1);	
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, Turkey.stage.flashMatrix, true);
			context3D.setProgram(finalProgram);
			context3D.setTextureAt(0,Turkey.sceneTexture);
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
		}
		
		override protected function createProgram():void
		{
			var vertexProgramCode:String = "m44 op, va0, vc4\n" +//v4-v7为空间转屏幕坐标
				"mov v0 va1\n";
			var fragmentCode:String = "mov ft0 v0\n"+
				"mul ft0.x ft0.x fc1.x\n"+
				"mul ft0.y ft0.y fc1.y\n"+
				"div ft1.x ft0.y fc0.x\n"+
				"cos ft1.x ft1.x\n"+
				"mul ft1.x ft1.x fc0.z\n" +
				"div ft1.y ft0.x fc0.y\n" +
				"cos ft1.y ft1.y\n" +
				"mul ft1.y ft1.y fc0.z\n"+
				"mul ft1.zw ft1.xx ft1.yy\n"+
				"mul ft1.zw ft1.zw fc0.ww\n"+
				"add ft0.xy ft0.xy ft1.zw\n"+
				"div ft0.xy ft0.xy fc1.xy\n"+
				"tex ft1, ft0.xy, fs0 <2d,linear,mipnone,clamp>\n"+
				"mov oc ft1";
			finalProgram= assembleAgal(fragmentCode,vertexProgramCode);
		}
	}
}