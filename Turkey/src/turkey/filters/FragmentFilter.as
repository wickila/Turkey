package turkey.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	import turkey.core.Turkey;

	public class FragmentFilter
	{
		protected static var INDEX_VECTOR:Vector.<uint> = Vector.<uint>([0,1,2,0,2,3]);
		public function FragmentFilter()
		{
			createProgram();
		}
		
		protected function createProgram():void
		{
			
		}
		/**
		 *	进行滤镜渲染（从临时材质渲染到屏幕） 
		 * @param renderToBuff 是否立即渲染到缓冲区
		 * 
		 */		
		public function render(renderToBuff:Boolean=true):void
		{
			
		}
		
		protected function assembleAgal(fragmentShader:String=null, vertexShader:String=null):Program3D
		{
			var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexShader);
			
			var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader);
			
			var context:Context3D = Turkey.stage.context3D;
			var program:Program3D = context.createProgram();
			program.upload(vertexProgramAssembler.agalcode, fragmentProgramAssembler.agalcode);          
			
			return program;
		}
		
		public function dispose():void{
			
		}
	}
}