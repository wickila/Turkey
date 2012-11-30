package turkey.display
{
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.errors.IllegalOperationError;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.system.Capabilities;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import turkey.TurkeyRenderer;
    import turkey.core.turkey_internal;
    import turkey.events.TurkeyEnterFrameEvent;
    import turkey.events.TurkeyEvent;
    import turkey.events.TurkeyMouseEvent;
    
    use namespace turkey_internal;
    
    public class Stage extends DisplayObjectContainer
    {
		public var stage2D:flash.display.Stage;
		public var stage3D:Stage3D;
		public var context3D:Context3D;
        public var stageWidth:int;
        public var stageHeight:int;
		public var flashMatrix:Matrix3D;
		public var trasformMatix:Matrix;
        private var _color:uint;
        private var mEnterFrameEvent:TurkeyEnterFrameEvent = new TurkeyEnterFrameEvent(TurkeyEvent.ENTER_FRAME, 0.0);
		private var _timer:Timer;
		private var _time:uint;
		private var _frameRate:int;
		private var _mouseMoveEnable:Boolean = false;
		private static var _bColorA:uint;
		private static var _bColorR:uint;
		private static var _bColorG:uint;
		private static var _bColorB:uint;
		private var sceneTexture:Texture;
		private var grayscaleProgram:Program3D;
		private var postFilterVertexBuffer:VertexBuffer3D;
		private var postFilterIndexBuffer:IndexBuffer3D;
        
        public function Stage(stage:flash.display.Stage, frameRate:int=60,color:uint=0)
        {
			stage2D = stage;
            stageWidth = stage.stageWidth;
            stageHeight = stage.stageHeight;
			trasformMatix = new Matrix();
            _color = color;
			_bColorA = (_color & 0xff000000)/0xff;
			_bColorR = (_color & 0xff0000)/0xff;
			_bColorG = (_color & 0xff00)/0xff;
			_bColorB = (_color & 0xff)/0xff;
			_frameRate = frameRate;
			_timer = new Timer(1000/frameRate);
			_timer.addEventListener(TimerEvent.TIMER,onTimer);
			flashMatrix = new Matrix3D(Vector.<Number>(
				[
					2/stageWidth,0,0,0,
					0,-2/stageHeight,0,0,
					0,0,1,0,
					-1,1,0,1
				]));
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE,onContext3DCrete);
			stage2D.addEventListener(MouseEvent.CLICK,onStageClick);
			stage2D.addEventListener(MouseEvent.RIGHT_CLICK,onStageClick);
			stage2D.addEventListener(MouseEvent.MOUSE_DOWN,onStageClick);
			stage2D.addEventListener(MouseEvent.MOUSE_UP,onStageClick);
			stage2D.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,onStageClick);
			stage2D.addEventListener(MouseEvent.RIGHT_MOUSE_UP,onStageClick);
			stage3D.requestContext3D();
        }
		/**
		 * 
		 * @return 是否监听鼠标移动事件，此事件比较耗效率，所以默认禁用
		 * 
		 */		
		public function get mouseMoveEnable():Boolean
		{
			return _mouseMoveEnable;
		}

		public function set mouseMoveEnable(value:Boolean):void
		{
			if(_mouseMoveEnable == value)return;
			_mouseMoveEnable = value;
			if(_mouseMoveEnable)
			{
				stage2D.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			}else
			{
				stage2D.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			}
		}

		private function onContext3DCrete(event:flash.events.Event):void
		{
			context3D = stage3D.context3D;
			context3D.enableErrorChecking = Capabilities.isDebugger;
			context3D.setDepthTest(true,Context3DCompareMode.ALWAYS);
			context3D.configureBackBuffer(stageWidth, stageHeight, 2, true);
			_timer.start();
			_time = getTimer();
			dispatchEvent(new TurkeyEvent(TurkeyEvent.CONTEXT3D_CREATE));
		}
		
		private function onTimer(event:TimerEvent):void
		{
			mEnterFrameEvent.reset(TurkeyEvent.ENTER_FRAME, false, getTimer()-_time);
			_time = getTimer();
			broadcastEvent(mEnterFrameEvent);
			
			context3D.clear(_bColorR,_bColorG,_bColorB,_bColorA);
			addToRenderList(_transformationMatrix,1,false);
			TurkeyRenderer.render();
			context3D.present();
			
			updateMouseState();
		}
		
		private function updateMouseState():void
		{
			for each(var child:DisplayObject in children)
			{
				child.hitMouse(stage2D.mouseX,stage2D.mouseY);
			}
		}
		
		private function onStageClick(event:MouseEvent):void
		{
			var p:Point = new Point(event.stageX,event.stageY);
			var target:DisplayObject = hitTest(p,true);
			target.globalToLocal(new Point(event.stageX,event.stageY),p);
			target.dispatchEvent(getEventByType(event.type,target,p,event.stageX,event.stageY));
		}
		
		private function getEventByType(type:String,target:DisplayObject,localPoint:Point,stageX:Number,stageY:Number):TurkeyMouseEvent
		{
			switch(type)
			{
				case MouseEvent.CLICK:
					return new TurkeyMouseEvent(TurkeyMouseEvent.CLICK,target,localPoint.x,localPoint.y,stageX,stageY);
				case MouseEvent.RIGHT_CLICK:
					return new TurkeyMouseEvent(TurkeyMouseEvent.RIGHT_CLICK,target,localPoint.x,localPoint.y,stageX,stageY);
				case MouseEvent.MOUSE_DOWN:
					return new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_DOWN,target,localPoint.x,localPoint.y,stageX,stageY);
				case MouseEvent.RIGHT_MOUSE_DOWN:
					return new TurkeyMouseEvent(TurkeyMouseEvent.RIGHT_MOUSE_DOWN,target,localPoint.x,localPoint.y,stageX,stageY);
				case MouseEvent.MOUSE_UP:
					return new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_UP,target,localPoint.x,localPoint.y,stageX,stageY);
				case MouseEvent.RIGHT_MOUSE_UP:
					return new TurkeyMouseEvent(TurkeyMouseEvent.RIGHT_MOUSE_UP,target,localPoint.x,localPoint.y,stageX,stageY);
			}
			return null;
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var p:Point = new Point(event.stageX,event.stageY);
			var target:DisplayObject = hitTest(p,true);
			target.globalToLocal(new Point(event.stageX,event.stageY),p);
			target.dispatchEvent(new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_MOVE,target,p.x,p.y,event.stageX,event.stageY));
		}

        override public function hitTest(localPoint:Point,forMouse:Boolean=false):DisplayObject
        {
			if(forMouse && (!visible||!mouseEnabled))
                return null;
            
            // locations outside of the stage area shouldn't be accepted
            if (localPoint.x < 0 || localPoint.x > stageWidth ||
                localPoint.y < 0 || localPoint.y > stageHeight)
                return null;
            
            // if nothing else is hit, the stage returns itself as target
            var target:DisplayObject = super.hitTest(localPoint,forMouse);
            if (target == null) target = this;
            return target;
        }
        
        /** @private */
        override public function set width(value:Number):void 
        { 
            throw new IllegalOperationError("Cannot set width of stage");
        }
        
        /** @private */
        override public function set height(value:Number):void
        {
            throw new IllegalOperationError("Cannot set height of stage");
        }
        
        override public function set x(value:Number):void
        {
            throw new IllegalOperationError("Cannot set x-coordinate of stage");
        }
        
        override public function set y(value:Number):void
        {
            throw new IllegalOperationError("Cannot set y-coordinate of stage");
        }
        
        override public function set scaleX(value:Number):void
        {
            throw new IllegalOperationError("Cannot scale stage");
        }

        override public function set scaleY(value:Number):void
        {
            throw new IllegalOperationError("Cannot scale stage");
        }
        
        override public function set rotation(value:Number):void
        {
            throw new IllegalOperationError("Cannot rotate stage");
        }
        
        public function get color():uint { return _color; }
        public function set color(value:uint):void { _color = value; }
    }
}