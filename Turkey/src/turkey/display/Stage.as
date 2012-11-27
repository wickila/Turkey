package turkey.display
{
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
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
		private static var _bColorA:uint;
		private static var _bColorR:uint;
		private static var _bColorG:uint;
		private static var _bColorB:uint;
        
        public function Stage(stage:flash.display.Stage, color:uint=0, frameRate:int=60)
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
			stage2D.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage3D.requestContext3D();
        }
		
		private function onContext3DCrete(event:flash.events.Event):void
		{
			context3D = stage3D.context3D;
			context3D.enableErrorChecking = Capabilities.isDebugger;
			context3D.setDepthTest(true,Context3DCompareMode.ALWAYS);
			context3D.configureBackBuffer(stageWidth, stageHeight, 2, true);
			_timer.start();
			_time = getTimer();
			dispatchEvent(new TurkeyEvent(TurkeyEvent.COMPLETE));
		}
		
		private function onTimer(event:TimerEvent):void
		{
			mEnterFrameEvent.reset(TurkeyEvent.ENTER_FRAME, false, getTimer()-_time);
			_time = getTimer();
			broadcastEvent(mEnterFrameEvent);
			updateMouseState();
			render();
		}
		
		private function updateMouseState():void
		{
			for each(var child:DisplayObject in children)
			{
				child.hitMouse(stage2D.mouseX,stage2D.mouseY);
			}
		}
		
		private function render():void
		{
			TurkeyRenderer.render(this,trasformMatix,1);
		}
		
		public static function clear():void
		{
			context3D.clear(_bColorR,_bColorG,_bColorB,_bColorA);
		}
		private var bubbleChain:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		private function onStageClick(event:MouseEvent):void
		{
			var t:uint = getTimer();
			bubbleChain = new Vector.<DisplayObject>();
			var p:Point = new Point(event.stageX,event.stageY);
			addBubbleChain(TurkeyMouseEvent.CLICK,this,event.stageX,event.stageY);
			var target:DisplayObject = hitTest(p,true);
			var child:DisplayObject = target;
			while(child)
			{
				child.globalToLocal(new Point(event.stageX,event.stageY),p);
				child.dispatchEvent(new TurkeyMouseEvent(TurkeyMouseEvent.CLICK,target,p.x,p.y,event.stageX,event.stageY));
				child = child.parent;
			}
//			trace("dispatch click event cost ",getTimer()-t,"毫秒");
		}
		
		/**
		 *	查找target里面需要响应鼠标事件的显示对象，加入队列，准备发送事件 
		 * @param target
		 * @param mx
		 * @param my
		 * 
		 */		
		private function addBubbleChain(eventType:String,target:DisplayObject,mx:Number,my:Number):void
		{
			if(target is DisplayObjectContainer)
			{
				if(target.mouseEnabled&&target.hasEventListener(eventType))bubbleChain.push(target);
				var con:DisplayObjectContainer = DisplayObjectContainer(target);
				if(con.mouseChildren)
				{
					for(var i:int = DisplayObjectContainer(target).numChildren-1;i>-1;i--)
					{
						if(con.getChildAt(i).getBounds(this).contains(mx,my))
						{
							addBubbleChain(eventType,con.getChildAt(i),mx,my);
							break;//查找到了本容器内的响应对象，就停止本次查找（因为一个容器内只能有一个现实对象响应鼠标事件)
						}
					}
				}
			}else
			{
				if(target.mouseEnabled && target.hasEventListener(eventType))
				{
					bubbleChain.push(target);
				}
			}
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var t:uint = getTimer();
			bubbleChain = new Vector.<DisplayObject>();
			var p:Point = new Point();
			addBubbleChain(TurkeyMouseEvent.MOUSE_MOVE,this,event.stageX,event.stageY);
			var target:DisplayObject;
			if(bubbleChain.length>0)target = bubbleChain[bubbleChain.length-1];
			while(bubbleChain.length>0)
			{
				var child:DisplayObject = bubbleChain.shift();
				child.globalToLocal(new Point(event.stageX,event.stageY),p);
				child.dispatchEvent(new TurkeyMouseEvent(TurkeyMouseEvent.MOUSE_MOVE,target,p.x,p.y,event.stageX,event.stageY));
			}
//			trace("dispatch click event cost ",getTimer()-t,"毫秒");
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