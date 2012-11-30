package turkey.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	import turkey.core.Turkey;

	public class GrayFilter extends FragmentFilter
	{
		private static const POST_FILTER_POSITIONS:Vector.<Number> = new <Number>[
			-1,  1, // TL
			1,  1, // TR
			1, -1, // BR
			-1, -1  // BL
		];
		
		/** Triangles forming a full-viewport quad */
		private static const POST_FILTER_TRIS:Vector.<uint> = new <uint>[0, 2, 3, 0, 1, 2];
		private static const GRAYSCALE_FRAGMENT_CONSTANTS:Vector.<Number> = new <Number>[0.3, 0.59, 0.11, 0];
		private static const POST_FILTER_VERTEX_CONSTANTS:Vector.<Number> = new <Number>[1, 2, 0, 0];
		
		private static var _program:Program3D = null;
		private static var _vertexBuffer:VertexBuffer3D = null;
		private static var _indexBuffer:IndexBuffer3D = null;
		public function GrayFilter()
		{
			super();
		}
		
		override protected function createProgram():void
		{
			if(_program == null){
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				var vertSource:String =
					// Pass position through unchanged. It's already in clip space.
					"mov op, va0\n" +
					
					// Position = (position+1)/2
					// Transforms [-1,1] to [0,1]
					"add vt0, vc0.xxxx, va0\n" +
					"div vt0, vt0, vc0.yyyy\n" +
					"sub vt0.y, vc0.x, vt0.y\n" +
					"mov v0, vt0\n";
				assembler.assemble(Context3DProgramType.VERTEX, vertSource);
				var vertexShaderAGAL:ByteArray = assembler.agalcode;
				var fragSource:String = 
					// Sample scene texture
					"tex ft0, v0, fs0 <2d,clamp,linear>\n" +
					
					// Apply coefficients and compute sum
					"dp3 ft0.x, ft0, fc0\n" +
					
					// Copy sum to all channels
					"mov ft0.y, ft0.x\n" +
					"mov ft0.z, ft0.x\n" +
					
					"mov oc, ft0\n";
				assembler.assemble(Context3DProgramType.FRAGMENT, fragSource);
				var fragmentShaderAGAL:ByteArray = assembler.agalcode;
				_program = Turkey.stage.context3D.createProgram();
				_program.upload(vertexShaderAGAL, fragmentShaderAGAL);
				_vertexBuffer = Turkey.stage.context3D.createVertexBuffer(4, 2);
				_vertexBuffer.uploadFromVector(POST_FILTER_POSITIONS, 0, 4);
				_indexBuffer = Turkey.stage.context3D.createIndexBuffer(6);
				_indexBuffer.uploadFromVector(POST_FILTER_TRIS, 0, 6);
			}
		}
		
		override public function render(isLast:Boolean=true):void
		{
			var context3D:Context3D = Turkey.stage.context3D;
			context3D.setProgram(_program);
			context3D.setTextureAt(0, Turkey.sceneTexture);
			context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(1, null);
			context3D.setVertexBufferAt(2, null);
			context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, POST_FILTER_VERTEX_CONSTANTS);
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, GRAYSCALE_FRAGMENT_CONSTANTS);
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
	}
}