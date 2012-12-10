package turkey.display
{
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
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
//        private var mEnterFrameEvent:TurkeyEnterFrameEvent = new TurkeyEnterFrameEvent(TurkeyEvent.ENTER_FRAME, 0.0);
		private var _timer:Timer;
		private var _time:uint;
		private var _frameRate:int;
		private var _mouseMoveEnable:Boolean = false;
		private static var _bColorA:uint;
		private static var _bColorR:uint;
		private static var _bColorG:uint;
		private static var _bColorB:uint;
		private var sceneTexture:Texture;
        
        public function Stage(stage:flash.display.Stage,stageWidth:Number=0,stageHeight:Number=0, frameRate:int=60,color:uint=0)
        {
			stage2D = stage;
            if(stageWidth ==0)stageWidth = stage.stageWidth;
            if(stageHeight==0)stageHeight = stage.stageHeight;
			this.stageWidth = stageWidth;
			this.stageHeight = stageHeight;
			_transformationMatrix = new Matrix();
			_colorMatrix = new Matrix3D();
			_mouseEnabled = false;
			_bColorA = (color & 0xff000000)/0xff;
			_bColorR = (color & 0xff0000)/0xff;
			_bColorG = (color & 0xff00)/0xff;
			_bColorB = (color & 0xff)/0xff;
			_frameRate = frameRate;
			_timer = new Timer(1000/frameRate);
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
		
		protected function onEnterFrame(event:Event):void
		{
			onTimer(null);
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
			context3D.configureBackBuffer(stageWidth, stageHeight, 0, false);
			stage2D.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			dispatchEvent(new TurkeyEvent(TurkeyEvent.CONTEXT3D_CREATE));
		}
		
		private function onTimer(event:TimerEvent):void
		{
//			mEnterFrameEvent.reset(TurkeyEvent.ENTER_FRAME, false, getTimer()-_time);
//			_time = getTimer();
//			broadcastEvent(mEnterFrameEvent);
			
			context3D.clear(_bColorR,_bColorG,_bColorB,_bColorA);
			addToRenderList(_transformationMatrix,_colorMatrix,1,false);
			TurkeyRenderer.render();
			context3D.present();
			
			hitMouse(stage2D.mouseX,stage2D.mouseY);
		}
		
		private function onStageClick(event:MouseEvent):void
		{
			var p:Point = new Point(event.stageX,event.stageY);
			var target:DisplayObject = hitTest(p,true);
			if(target == null)return;
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
			if(target==null)return;
			target.globalToLocal(new Point(event.stageX,event.stageY),p);
			target.dispatchEvent(new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_MOVE,target,p.x,p.y,event.stageX,event.stageY));
		}

        override public function hitTest(localPoint:Point,forMouse:Boolean=false):DisplayObject
        {
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
    }
}