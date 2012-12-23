package turkey.core
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Stage;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.TextureBase;
	import flash.utils.Dictionary;
	
	import turkey.display.Image;
	import turkey.display.Stage;
	import turkey.enumrate.BlendMode;
	import turkey.events.EventDispatcher;
	import turkey.events.TurkeyEvent;
	import turkey.utils.TurkeyUtils;

	use namespace turkey_internal;
	public class Turkey extends EventDispatcher
	{
		public static var stage:turkey.display.Stage;
		private static var _programs:Dictionary;
		private static var _sceneTexture:TextureBase;
		private static var _sceneTexture1:TextureBase;
		private static var _sceneTexture2:TextureBase;
		public function Turkey()
		{
		}
		
		public static function init(stage2D:flash.display.Stage,stageWidth:Number=0,stageHeight:Number=0,frameRate:int=60,color:uint=0x00000000):void
		{
			stage = new turkey.display.Stage(stage2D,stageWidth,stageHeight,frameRate,color);
			stage.addEventListener(TurkeyEvent.CONTEXT3D_CREATE,onStageInit);
		}
		
		public static function get sceneTexture():TextureBase
		{
			return _sceneTexture;
		}
		
		public static function swapSceneTexture():void
		{
			if(_sceneTexture == _sceneTexture1)
			{
				_sceneTexture = _sceneTexture2;
			}else
			{
				_sceneTexture = _sceneTexture1;
			}
		}
		
		private static function onStageInit(event:TurkeyEvent):void
		{
			initPrograms();
			_sceneTexture1 = stage.context3D.createTexture(
				TurkeyUtils.getNextPowerOfTwo(stage.stageWidth),
				TurkeyUtils.getNextPowerOfTwo(stage.stageHeight),
				Context3DTextureFormat.BGRA,
				true
			);
			_sceneTexture2 = stage.context3D.createTexture(
				TurkeyUtils.getNextPowerOfTwo(stage.stageWidth),
				TurkeyUtils.getNextPowerOfTwo(stage.stageHeight),
				Context3DTextureFormat.BGRA,
				true
			);
			_sceneTexture = _sceneTexture1;
			stage.context3D.setProgram(Turkey.getProgram(Image.IMAGE_PROGRAM));
			stage.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, stage.flashMatrix, true);
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
				"tex ft0, v1, fs0 <2d,linear>\n" +
				"mul ft0.xyz, ft0.xyz, v0.xyz\n"+
				"mul oc, ft0, v0.w"
			);
			var program:Program3D = Turkey.stage.context3D.createProgram();
			program.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			_programs[Image.IMAGE_PROGRAM] = program;
		}
	}
}