package
{
	import flash.display.BitmapData;
	
	import turkey.particle.PDParticleSystem;

	public class ParticleWrapper
	{
		private var mParticle:PDParticleSystem;
		private var mTexture:BitmapData;
		private var mTextureName:String;
		private var _customTextureName:String;
		private var _customTexture:BitmapData;
		private var _particleName:String;
		public function ParticleWrapper(particleSystem:PDParticleSystem,texture:BitmapData,textureName:String,particleName:String)
		{
			this.mParticle = particleSystem;
			this.mTexture = _customTexture = texture;
			this.mTextureName = _customTextureName = textureName;
			_particleName = particleName;
		}
		
		public function get particle():PDParticleSystem
		{
			return mParticle;
		}
		
		public function set particle(value:PDParticleSystem):void
		{
			mParticle = value;
		}
		
		public function get texture():BitmapData
		{
			return mTexture;
		}
		
		public function set texture(value:BitmapData):void
		{
			mTexture = value;
		}
		[Bindable]
		public function get textureName():String
		{
			return mTextureName;
		}
		
		public function set textureName(value:String):void
		{
			mTextureName = value;
		}

		public function get customTextureName():String
		{
			return _customTextureName;
		}

		public function set customTextureName(value:String):void
		{
			_customTextureName = value;
		}

		public function get customTexture():BitmapData
		{
			return _customTexture;
		}

		public function set customTexture(value:BitmapData):void
		{
			_customTexture = value;
		}

		[Bindable]
		public function get particleName():String
		{
			return _particleName;
		}

		public function set particleName(value:String):void
		{
			_particleName = value;
		}

		public function dispose():void
		{
			particle.dispose();
		}
	}
}