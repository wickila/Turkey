package turkey.filters
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import turkey.core.Turkey;
	
	/**
	 * ...
	 * @author
	 */
	public class Light extends FragmentFilter {
		private var _radius:uint = 512;
		private var _context3D:Context3D;
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _program:Program3D;
		private var _program1:Program3D;
		private var _texture0:Texture;
		private var _color:Vector.<Number>;
		private var _vertexBuffer1:VertexBuffer3D;
		public function Light(){
			super();
			_color = new Vector.<Number>(4,true);
			setPosition(0,0);
			color = 0xffff00ff;
		}
		
		override protected function createProgram():void
		{
			if(_program == null){
				_context3D = Turkey.stage.context3D;
				createRandomTexture(_radius);
				_vertexBuffer = _context3D.createVertexBuffer(4,4);
				var w:int = Turkey.stage.stageWidth;
				var h:int = Turkey.stage.stageHeight;
				_vertexBuffer.uploadFromVector(Vector.<Number>([0,0,0,0,
					w,0,1,0,
					0,h,0,1,
					w,h,1,1]),0,4);
				_indexBuffer = _context3D.createIndexBuffer(6);
				_indexBuffer.uploadFromVector(Vector.<uint>([0,1,2,1,3,2]),0,6);
				var agalAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				_program = _context3D.createProgram();
				var vertexShader:ByteArray = agalAssembler.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0 \n"
					+ "mov v0, va1\n");
				//fragment shader
				var code:String = "";
				code += "tex ft0, v0, fs0<2d,repeat,linear>\n";
				code += "mov oc ft0";
				var fragmentShader:ByteArray = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
				_program = _context3D.createProgram();
				_program.upload(vertexShader, fragmentShader);
				
				_program1 = _context3D.createProgram();
				//fragment shader
				code = "";
				code += "tex ft0, v0, fs0<2d,repeat,linear>\n";
				code += "tex ft1, v0, fs1<2d,repeat,linear>\n";
				code += "mul ft1, ft1.xyz, fc0.xyz\n";
				code += "add ft1, ft1, fc0.w\n";
				code += "mul oc ft0 ft1.xyz";
				fragmentShader = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
				_program1 = _context3D.createProgram();
				_program1.upload(vertexShader, fragmentShader);
			}
		}
		
		private function createRandomTexture(size:uint):void {
			var sp:Sprite = new Sprite();
			var shape:Shape = new Shape();
			var mt:Matrix = new Matrix();
			mt.createGradientBox(size<<1,size<<1);
			mt.translate(-size,-size);
			shape.graphics.beginGradientFill(GradientType.RADIAL,[0xffffff,0],[1,1],[0,255],mt);
			shape.graphics.drawCircle(0,0,size);
			shape.graphics.endFill();
			sp.addChild(shape);
			shape.x = shape.y = size;
			var bd:BitmapData = new BitmapData(size<<1, size<<1, true, 0x00000000);
			bd.draw(sp);
			_texture0 = _context3D.createTexture(size<<1, size<<1, Context3DTextureFormat.BGRA, false);
			_texture0.uploadFromBitmapData(bd);
			bd.dispose();
		}
		
		override public function render(renderToBuff:Boolean=true):void
		{
			Turkey.swapSceneTexture();
			_context3D.setVertexBufferAt(0, _vertexBuffer1, 0, Context3DVertexBufferFormat.FLOAT_2);//x,y
			_context3D.setVertexBufferAt(1, _vertexBuffer1, 2, Context3DVertexBufferFormat.FLOAT_2);//u,v
			_context3D.setProgram(_program);
			_context3D.setTextureAt(0, _texture0);
			_context3D.setRenderToTexture(Turkey.sceneTexture);
			_context3D.clear(0,0,0,0);
			_context3D.drawTriangles(_indexBuffer);
			_context3D.setTextureAt(1, Turkey.sceneTexture);
			Turkey.swapSceneTexture();
			_context3D.setTextureAt(0,Turkey.sceneTexture);
			_context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);//x,y
			_context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);//u,v
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,_color);
			_context3D.setProgram(_program1);
			if(renderToBuff)
			{
				_context3D.setRenderToBackBuffer();
			}else
			{
				Turkey.swapSceneTexture();
				_context3D.setRenderToTexture(Turkey.sceneTexture);
				_context3D.clear(0,0,0,0);
			}
			_context3D.drawTriangles(_indexBuffer);
			_context3D.setTextureAt(0, null);
			_context3D.setTextureAt(1, null);
		}
		
		public function setPosition(x:int,y:int):void
		{
			_vertexBuffer1&&_vertexBuffer1.dispose();
			_vertexBuffer1 = _context3D.createVertexBuffer(4,4);
			x = x-(_radius>>1);
			y = y-(_radius>>1);
			_vertexBuffer1.uploadFromVector(Vector.<Number>([x,y,0,0,
				_radius+x,y,1,0,
				x,_radius+y,0,1,
				_radius+x,_radius+y,1,1]),0,4);
		}
		
		override public function dispose():void
		{
			super.dispose();
			_context3D = null;
			_texture0.dispose();_texture0 = null;
			_vertexBuffer.dispose();_vertexBuffer = null;
			_indexBuffer.dispose();_indexBuffer = null;
			_program.dispose();_program = null;
		}
		
		public function set color(value:uint):void
		{
			_color[0] = ((uint(value>>24) & 0xff))/0xff;
			_color[1] = ((uint(value>>16) & 0xff))/0xff;
			_color[2] = ((uint(value>>8) & 0xff))/0xff;
			_color[3] = ((uint(value) & 0xff))/0xff;
		}
	}
}