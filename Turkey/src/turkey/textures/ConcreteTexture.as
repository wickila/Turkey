// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package turkey.textures
{
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.textures.TextureBase;
    
    import turkey.display.Stage;
    import turkey.events.TurkeyEvent;

    /** A ConcreteTexture wraps a Stage3D texture object, storing the properties of the texture. */
    public class ConcreteTexture extends Texture
    {
        private var mBase:TextureBase;
        private var mFormat:String;
        private var mWidth:int;
        private var mHeight:int;
        private var mMipMapping:Boolean;
        private var mPremultipliedAlpha:Boolean;
        private var mOptimizedForRenderTexture:Boolean;
        private var mData:Object;
        private var mScale:Number;
        
        /** Creates a ConcreteTexture object from a TextureBase, storing information about size,
         *  mip-mapping, and if the channels contain premultiplied alpha values. */
        public function ConcreteTexture(bitmapData:BitmapData,base:TextureBase, format:String, width:int, height:int, 
                                        mipMapping:Boolean, premultipliedAlpha:Boolean,
                                        optimizedForRenderTexture:Boolean=false,
                                        scale:Number=1)
        {
			super(bitmapData);
            mScale = scale <= 0 ? 1.0 : scale;
            mBase = base;
            mFormat = format;
            mWidth = width;
            mHeight = height;
            mMipMapping = mipMapping;
            mPremultipliedAlpha = premultipliedAlpha;
            mOptimizedForRenderTexture = optimizedForRenderTexture;
        }
        
        /** Disposes the TextureBase object. */
        public override function dispose():void
        {
            if (mBase) mBase.dispose();
            super.dispose();
        }
        
        private function onContextCreated(event:TurkeyEvent):void
        {
            var context:Context3D = Stage.context3D;
            var bitmapData:BitmapData = mData as BitmapData;
            var atfData:AtfData = mData as AtfData;
            var nativeTexture:flash.display3D.textures.Texture;
            
            if (bitmapData)
            {
                nativeTexture = context.createTexture(mWidth, mHeight, 
                    Context3DTextureFormat.BGRA, mOptimizedForRenderTexture);
                Texture.uploadBitmapData(nativeTexture, bitmapData, mMipMapping);
            }
            else if (atfData)
            {
                nativeTexture = context.createTexture(atfData.width, atfData.height, atfData.format,
                                                      mOptimizedForRenderTexture);
                Texture.uploadAtfData(nativeTexture, atfData.data);
            }
            
            mBase = nativeTexture;
        }
        
        // properties
        
        /** Indicates if the base texture was optimized for being used in a render texture. */
        public function get optimizedForRenderTexture():Boolean { return mOptimizedForRenderTexture; }
        
        /** @inheritDoc */
        public override function get base():TextureBase { return mBase; }
        
        /** @inheritDoc */
        public override function get root():ConcreteTexture { return this; }
        
        /** @inheritDoc */
        public override function get format():String { return mFormat; }
        
        /** @inheritDoc */
        public override function get width():Number  { return mWidth / mScale;  }
        
        /** @inheritDoc */
        public override function get height():Number { return mHeight / mScale; }
        
        /** @inheritDoc */
        public override function get nativeWidth():Number { return mWidth; }
        
        /** @inheritDoc */
        public override function get nativeHeight():Number { return mHeight; }
        
        /** The scale factor, which influences width and height properties. */
        public override function get scale():Number { return mScale; }
        
        /** @inheritDoc */
        public override function get mipMapping():Boolean { return mMipMapping; }
        
        /** @inheritDoc */
        public override function get premultipliedAlpha():Boolean { return mPremultipliedAlpha; }
    }
}