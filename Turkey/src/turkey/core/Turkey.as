package turkey.core
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Stage;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.Dictionary;
	
	import turkey.display.Image;
	import turkey.display.Stage;
	import turkey.events.EventDispatcher;
	import turkey.events.TurkeyEvent;

	use namespace turkey_internal;
	public class Turkey extends EventDispatcher
	{
		public static var stage:turkey.display.Stage;
		private static var _programs:Dictionary;
		public function Turkey()
		{
		}
		
		public static function init(stage2D:flash.display.Stage,frameRate:int=60,color:uint=0xffffffff):void
		{
			stage = new turkey.display.Stage(stage2D,frameRate,color);
			stage.addEventListener(TurkeyEvent.CONTEXT3D_CREATE,onStageInit);
		}
		
		private static function onStageInit(event:TurkeyEvent):void
		{
			initPrograms();
			stage.dispatchEvent(new TurkeyEvent(TurkeyEvent.COMPLETE));
		}
		
		private static function initPrograms():void
		{
			_programs = new Dictionary();
			initImageProgram();
		}
		
		public static function getProgram(name:String):Program3D
		{
			return _programs[name];
		}
		
		private static function initImageProgram():void
		{
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + // pos to clipspace
				"mov v0, va1\n" +// copy rgba
				"mov v1, va2"//copy uv
			);
			var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex ft1, v1, fs0 <2d,linear,nomip>\n" +
				"mul ft1, ft1, v0.w\n"+
				"mov oc, ft1"
			);
			var program:Program3D = Turkey.stage.context3D.createProgram();
			program.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			_programs[Image.IMAGE_PROGRAM] = program;
		}
	}
}