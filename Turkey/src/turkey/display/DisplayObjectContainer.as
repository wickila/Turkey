package turkey.display
{
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import turkey.TurkeyRenderer;
	import turkey.core.Turkey;
	import turkey.core.turkey_internal;
	import turkey.events.TurkeyEvent;
	import turkey.utils.MatrixUtil;
	
	use namespace turkey_internal
	public class DisplayObjectContainer extends DisplayObject
	{
		private var _children:Vector.<DisplayObject>;
		private var _mouseChildren:Boolean = true;
		
		private static var sHelperMatrix:Matrix = new Matrix();
		private static var sHelperPoint:Point = new Point();
		private static var _broadcastListeners:Vector.<DisplayObject> = new <DisplayObject>[];
		public function DisplayObjectContainer()
		{
			_children = new Vector.<DisplayObject>();
		}
		
		public function get mouseChildren():Boolean
		{
			return _mouseChildren;
		}

		public function set mouseChildren(value:Boolean):void
		{
			_mouseChildren = value;
		}

		public function addChild(child:DisplayObject):DisplayObject
		{
			addChildAt(child, numChildren);
			return child;
		}
		
		public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var numChildren:int = _children.length; 
			
			if (index >= 0 && index <= numChildren)
			{
				child.removeFromParent();
				if (index == numChildren) _children.push(child);
				else                      _children.splice(index, 0, child);
				
				child.setParent(this);
				child.dispatchEventWith(TurkeyEvent.ADDED, true);
				
				if (stage)
				{
					var container:DisplayObjectContainer = child as DisplayObjectContainer;
					if (container) container.broadcastEventWith(TurkeyEvent.ADDED_TO_STAGE);
					else           child.dispatchEventWith(TurkeyEvent.ADDED_TO_STAGE);
				}
				
				return child;
			}
			else
			{
				throw new RangeError("Invalid child index");
			}
		}
		
		public function broadcastEvent(event:TurkeyEvent):void
		{
			if (event.bubbles)
				throw new ArgumentError("Broadcast of bubbling events is prohibited");
			
			// The event listeners might modify the display tree, which could make the loop crash. 
			// Thus, we collect them in a list and iterate over that list instead.
			// And since another listener could call this method internally, we have to take 
			// care that the static helper vector does not get currupted.
			
			var fromIndex:int = _broadcastListeners.length;
			getChildEventListeners(this, event.type, _broadcastListeners);
			var toIndex:int = _broadcastListeners.length;
			
			for (var i:int=fromIndex; i<toIndex; ++i)
				_broadcastListeners[i].dispatchEvent(event);
			
			_broadcastListeners.length = fromIndex;
		}
		
		public function broadcastEventWith(type:String, data:Object=null):void
		{
			var event:TurkeyEvent = TurkeyEvent.fromPool(type, false, data);
			broadcastEvent(event);
		}
		
		private function getChildEventListeners(object:DisplayObject, eventType:String, 
												listeners:Vector.<DisplayObject>):void
		{
			var container:DisplayObjectContainer = object as DisplayObjectContainer;
			
			if (object.hasEventListener(eventType))
				listeners.push(object);
			
			if(container)
			{
				var children:Vector.<DisplayObject> = container.children;
				var numChildren:int = children.length;
				
				for (var i:int=0; i<numChildren; ++i)
					getChildEventListeners(children[i], eventType, listeners);
			}
		}
		
		internal function get children():Vector.<DisplayObject>
		{
			return _children;
		}
		
		public function removeChild(child:DisplayObject):DisplayObject
		{
			var childIndex:int = getChildIndex(child);
			if (childIndex != -1) removeChildAt(childIndex);
			return child;
		}
		
		public function removeChildAt(index:int):DisplayObject
		{
			if (index >= 0 && index < numChildren)
			{
				var child:DisplayObject = _children[index];
				child.dispatchEventWith(TurkeyEvent.REMOVED, true);
				
				if (stage)
				{
					var container:DisplayObjectContainer = child as DisplayObjectContainer;
					if (container) container.broadcastEventWith(TurkeyEvent.REMOVED_FROM_STAGE);
					else           child.dispatchEventWith(TurkeyEvent.REMOVED_FROM_STAGE);
				}
				
				child.setParent(null);
				index = _children.indexOf(child);
				if (index >= 0) _children.splice(index, 1); 
				return child;
			}else
			{
				throw new RangeError("Invalid child index");
			}
		}
		
		public function getChildAt(index:int):DisplayObject
		{
			if (index >= 0 && index < numChildren)
				return _children[index];
			else
				throw new RangeError("Invalid child index");
		}
		
		public function getChildIndex(child:DisplayObject):int
		{
			return _children.indexOf(child);
		}
		
		public function get numChildren():int { return _children.length; }
		
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			var numChildren:int = _children.length;
			
			if (numChildren == 0)
			{
				getTransformationMatrix(targetSpace, sHelperMatrix);
				MatrixUtil.transformCoords(sHelperMatrix, 0.0, 0.0, sHelperPoint);
				resultRect.setTo(sHelperPoint.x, sHelperPoint.y, 0, 0);
				return resultRect;
			}
			else if (numChildren == 1)
			{
				return _children[0].getBounds(targetSpace, resultRect);
			}
			else
			{
				var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
				var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
				
				for (var i:int=0; i<numChildren; ++i)
				{
					_children[i].getBounds(targetSpace, resultRect);
					minX = minX < resultRect.x ? minX : resultRect.x;
					maxX = maxX > resultRect.right ? maxX : resultRect.right;
					minY = minY < resultRect.y ? minY : resultRect.y;
					maxY = maxY > resultRect.bottom ? maxY : resultRect.bottom;
				}
				
				resultRect.setTo(minX, minY, maxX - minX, maxY - minY);
				return resultRect;
			}                
		}
		
		public override function hitTest(localPoint:Point,forMouse:Boolean = false):DisplayObject
		{
			if (forMouse && (!visible||(!mouseEnabled&&!mouseChildren)))
				return null;
			var localX:Number = localPoint.x;
			var localY:Number = localPoint.y;
			var numChildren:int = _children.length;
			if(!forMouse)
			{
				for (var i:int=numChildren-1; i>=0; --i) // front to back!
				{
					var child:DisplayObject = _children[i];
					getTransformationMatrix(child, sHelperMatrix);
					MatrixUtil.transformCoords(sHelperMatrix, localX, localY, sHelperPoint);
					var target:DisplayObject = child.hitTest(sHelperPoint,forMouse);
					
					if (target) return target;
				}
			}else
			{
				if(mouseChildren)
				{
					for (var j:int=numChildren-1; j>=0; --j) // front to back!
					{
						var child1:DisplayObject = _children[i];
						getTransformationMatrix(child1, sHelperMatrix);
						
						MatrixUtil.transformCoords(sHelperMatrix, localX, localY, sHelperPoint);
						var target1:DisplayObject = child1.hitTest(sHelperPoint,forMouse);
						
						if (target1) return target1;
					}
				}
				if(target1==null && mouseEnabled && getBounds(this).contains(localPoint.x,localPoint.y))
				{
					return this;
				}
			}
			return null;
		}
		
		override public function hitMouse(stageX:Number,stageY:Number):void
		{
			super.hitMouse(stageX,stageY);
			for(var i:int=0;i<_children.length;i++)
			{
				_children[i].hitMouse(stageX,stageY);
			}
		}
		
		override public function addToRenderList(parentMatrix:Matrix,parentAlpha:Number,parentFilter:Boolean):void
		{
			if(!hasVisibleArea)return;
			if(filters&&filters.length)
			{
				TurkeyRenderer.preFilter();
			}
			for(var i:int=0;i<numChildren;i++)
			{
				var child:DisplayObject = getChildAt(i);
				var matrix:Matrix = parentMatrix.clone();
				MatrixUtil.prependMatrix(matrix,transformationMatrix);
				child.addToRenderList(matrix,parentAlpha*alpha,(filters&&filters.length>0));
			}
			if(filters&&filters.length)
			{
				TurkeyRenderer.render();
				for(i=0;i<filters.length;i++)
				{
					filters[i].render(i==filters.length-1&&!parentFilter);
				}
				TurkeyRenderer.endFilter();
			}
		}
	}
}