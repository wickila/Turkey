package turkey.display
{
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.errors.IllegalOperationError;
    import flash.events.TimerEvent;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.system.Capabilities;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import turkey.TurkeyRenderer;
    import turkey.core.turkey_internal;
    import turkey.enumrate.BlendMode;
    import turkey.events.TurkeyEnterFrameEvent;
    import turkey.events.TurkeyEvent;
    
    use namespace turkey_internal;
    
    public class Stage extends DisplayObjectContainer
    {
		public static var stage2D:flash.display.Stage;
		public static var stage3D:Stage3D;
		public static var context3D:Context3D;
        public static var stageWidth:int;
        public static var stageHeight:int;
		public static var flashMatrix:Matrix3D;
		public static var trasformMatix:Matrix;
        private var _color:uint;
        private var mEnterFrameEvent:TurkeyEnterFrameEvent = new TurkeyEnterFrameEvent(TurkeyEvent.ENTER_FRAME, 0.0);
		private var _timer:Timer;
		private var _time:uint;
		private var _frameRate:int;
		private var _bColorA:uint;
		private var _bColorR:uint;
		private var _bColorG:uint;
		private var _bColorB:uint;
        
        public function Stage(stage:flash.display.Stage, color:uint=0, frameRate:int=60)
        {
			stage2D = stage;
            stageWidth = stage.stageWidth;
            stageHeight = stage.stageWidth;
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
					0,0,0,0,
					-1,1,0,1
				]));
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE,onContext3DCrete);
			stage3D.requestContext3D();
        }
		
		private function onContext3DCrete(event:flash.events.Event):void
		{
			context3D = stage3D.context3D;
			context3D.enableErrorChecking = Capabilities.isDebugger;
			context3D.configureBackBuffer(stageWidth, stageHeight, 1, true);
			_timer.start();
			_time = getTimer();
			dispatchEvent(new TurkeyEvent(TurkeyEvent.COMPLETE));
		}
		
        public function advanceTime(passedTime:Number):void
        {
            mEnterFrameEvent.reset(TurkeyEvent.ENTER_FRAME, false, passedTime);
            broadcastEvent(mEnterFrameEvent);
        }
		
		private function onTimer(event:TimerEvent):void
		{
			mEnterFrameEvent.reset(TurkeyEvent.ENTER_FRAME, false, getTimer()-_time);
			_time = getTimer();
			broadcastEvent(mEnterFrameEvent);
			render();
		}
		
		private function render():void
		{
			context3D.clear(_bColorR,_bColorG,_bColorB,_bColorA);
			TurkeyRenderer.render(this,trasformMatix,1);
			context3D.present();
		}

        override public function hitTest(localPoint:Point):DisplayObject
        {
            if (!visible)
                return null;
            
            // locations outside of the stage area shouldn't be accepted
            if (localPoint.x < 0 || localPoint.x > stageWidth ||
                localPoint.y < 0 || localPoint.y > stageHeight)
                return null;
            
            // if nothing else is hit, the stage returns itself as target
            var target:DisplayObject = super.hitTest(localPoint);
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