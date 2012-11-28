// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package turkey.events
{
	import turkey.core.turkey_internal;

    public class TurkeyEvent
    {
        /** Event type for a display object that is added to a parent. */
        public static const ADDED:String = "added";
        /** Event type for a display object that is added to the stage */
        public static const ADDED_TO_STAGE:String = "addedToStage";
        /** Event type for a display object that is entering a new frame. */
        public static const ENTER_FRAME:String = "enterFrame";
        /** Event type for a display object that is removed from its parent. */
        public static const REMOVED:String = "removed";
        /** Event type for a display object that is removed from the Turkey.stage. */
        public static const REMOVED_FROM_STAGE:String = "removedFromStage";
        /** Event type for a triggered button. */
        public static const TRIGGERED:String = "triggered";
        /** Event type for a display object that is being flattened. */
        public static const FLATTEN:String = "flatten";
        /** Event type for a resized Flash Player. */
        public static const RESIZE:String = "resize";
        /** Event type that may be used whenever something finishes. */
        public static const COMPLETE:String = "complete";
        /** Event type for a (re)created stage3D rendering context. */
        public static const CONTEXT3D_CREATE:String = "context3DCreate";
        /** Event type that indicates that the root DisplayObject has been created. */
        public static const ROOT_CREATED:String = "rootCreated";
        /** Event type for an animated object that requests to be removed from the juggler. */
        public static const REMOVE_FROM_JUGGLER:String = "removeFromJuggler";
        
        /** An event type to be utilized in custom events. Not used by Starling right now. */
        public static const CHANGE:String = "change";
        /** An event type to be utilized in custom events. Not used by Starling right now. */
        public static const CANCEL:String = "cancel";
        /** An event type to be utilized in custom events. Not used by Starling right now. */
        public static const SCROLL:String = "scroll";
        /** An event type to be utilized in custom events. Not used by Starling right now. */
        public static const OPEN:String = "open";
        /** An event type to be utilized in custom events. Not used by Starling right now. */
        public static const CLOSE:String = "close";
        /** An event type to be utilized in custom events. Not used by Starling right now. */
        public static const SELECT:String = "select";
        
        private static var sEventPool:Vector.<TurkeyEvent> = new <TurkeyEvent>[];
        
        private var mTarget:EventDispatcher;
        private var mCurrentTarget:EventDispatcher;
        private var mType:String;
        private var mBubbles:Boolean;
        private var mStopsPropagation:Boolean;
        private var mStopsImmediatePropagation:Boolean;
        private var mData:Object;
        
        /** Creates an event object that can be passed to listeners. */
        public function TurkeyEvent(type:String, bubbles:Boolean=false, data:Object=null)
        {
            mType = type;
            mBubbles = bubbles;
            mData = data;
        }
        
        /** Prevents listeners at the next bubble stage from receiving the event. */
        public function stopPropagation():void
        {
            mStopsPropagation = true;            
        }
        
        /** Prevents any other listeners from receiving the event. */
        public function stopImmediatePropagation():void
        {
            mStopsPropagation = mStopsImmediatePropagation = true;
        }
        
        /** Returns a description of the event, containing type and bubble information. */
        public function toString():String
        {
           return "Turkey Event";
        }
        
        /** Indicates if event will bubble. */
        public function get bubbles():Boolean { return mBubbles; }
        
        /** The object that dispatched the event. */
        public function get target():EventDispatcher { return mTarget; }
        
        /** The object the event is currently bubbling at. */
        public function get currentTarget():EventDispatcher { return mCurrentTarget; }
        
        /** A string that identifies the event. */
        public function get type():String { return mType; }
        
        /** Arbitrary data that is attached to the event. */
        public function get data():Object { return mData; }
        
        // properties for internal use
        
        /** @private */
        internal function setTarget(value:EventDispatcher):void { mTarget = value; }
        
        /** @private */
        internal function setCurrentTarget(value:EventDispatcher):void { mCurrentTarget = value; } 
        
        /** @private */
        internal function setData(value:Object):void { mData = value; }
        
        /** @private */
        internal function get stopsPropagation():Boolean { return mStopsPropagation; }
        
        /** @private */
        internal function get stopsImmediatePropagation():Boolean { return mStopsImmediatePropagation; }
        
        // event pooling
        
        /** @private */
		turkey_internal static function fromPool(type:String, bubbles:Boolean=false, data:Object=null):TurkeyEvent
        {
            return new TurkeyEvent(type, bubbles, data);
        }
        
        /** @private */
		turkey_internal function reset(type:String, bubbles:Boolean=false, data:Object=null):TurkeyEvent
        {
            mType = type;
            mBubbles = bubbles;
            mData = data;
            mTarget = mCurrentTarget = null;
            mStopsPropagation = mStopsImmediatePropagation = false;
            return this;
        }
    }
}