package turkey.display
{
	import com.adobe.utils.PerspectiveMatrix3D;
	
	import turkey.core.turkey_internal;
	import turkey.events.TurkeyEvent;
	
	use namespace turkey_internal
	public class DisplayObjectContainer extends DisplayObject
	{
		private var _children:Vector.<DisplayObject>;
		private static var _broadcastListeners:Vector.<DisplayObject> = new <DisplayObject>[];
		public function DisplayObjectContainer()
		{
			_children = new Vector.<DisplayObject>();
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
	}
}