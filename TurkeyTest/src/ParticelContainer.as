package
{
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    import turkey.display.Sprite;
    import turkey.events.TurkeyEvent;
    import turkey.events.TurkeyMouseEvent;
    import turkey.particle.PDParticleSystem;
    import turkey.particle.ParticleSystem;
    import turkey.textures.Texture;
    
    public class ParticelContainer extends Sprite
    {
        // particle designer configurations
        
        [Embed(source="../media/drugs.pex", mimeType="application/octet-stream")]
        private static const DrugsConfig:Class;
        
        [Embed(source="../media/fire.pex", mimeType="application/octet-stream")]
        private static const FireConfig:Class;
        
        [Embed(source="../media/sun.pex", mimeType="application/octet-stream")]
        private static const SunConfig:Class;
        
        [Embed(source="../media/jellyfish.pex", mimeType="application/octet-stream")]
        private static const JellyfishConfig:Class;
        
        // particle textures
        
        [Embed(source = "../media/drugs_particle.png")]
        private static const DrugsParticle:Class;
        
        [Embed(source = "../media/fire_particle.png")]
        private static const FireParticle:Class;
        
        [Embed(source = "../media/sun_particle.png")]
        private static const SunParticle:Class;
        
        [Embed(source = "../media/jellyfish_particle.png")]
        private static const JellyfishParticle:Class;
        
        // member variables
        
        private var mParticleSystems:Vector.<ParticleSystem>;
        private var mParticleSystem:ParticleSystem;
        
        public function ParticelContainer()
        {
            var drugsConfig:XML = XML(new DrugsConfig());
            var drugsTexture:Texture = Texture.fromBitmap(new DrugsParticle());
            
            var fireConfig:XML = XML(new FireConfig());
            var fireTexture:Texture = Texture.fromBitmap(new FireParticle());
            
            var sunConfig:XML = XML(new SunConfig());
            var sunTexture:Texture = Texture.fromBitmap(new SunParticle());
            
            var jellyConfig:XML = XML(new JellyfishConfig());
            var jellyTexture:Texture = Texture.fromBitmap(new JellyfishParticle());
            
            mParticleSystems = new <ParticleSystem>[
                new PDParticleSystem(drugsConfig, drugsTexture),
                new PDParticleSystem(fireConfig, fireTexture),
                new PDParticleSystem(sunConfig, sunTexture),
                new PDParticleSystem(jellyConfig, jellyTexture)
            ];
            
            // add event handlers for touch and keyboard
            
            addEventListener(TurkeyEvent.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(TurkeyEvent.REMOVED_FROM_STAGE, onRemovedFromStage);
        }
        
        private function startNextParticleSystem():void
        {
            if(mParticleSystem)
            {
                mParticleSystem.stop();
				if(mParticleSystem.parent)
				{
					mParticleSystem.parent.removeChild(mParticleSystem);
				}
            }
            
            mParticleSystem = mParticleSystems.shift();
            mParticleSystems.push(mParticleSystem);

            mParticleSystem.emitterX = 320;
            mParticleSystem.emitterY = 240;
            mParticleSystem.start();
            
            addChild(mParticleSystem);
        }
        
        private function onAddedToStage(event:TurkeyEvent):void
        {
            stage.stage2D.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
            stage.addEventListener(TurkeyMouseEvent.CLICK, onTouch);
            
            startNextParticleSystem();
        }
        
        private function onRemovedFromStage(event:TurkeyEvent):void
        {
            stage.stage2D.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			stage.removeEventListener(TurkeyMouseEvent.CLICK, onTouch);
        }
        
        private function onKey(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.SPACE)
                startNextParticleSystem();
        }
        
        private function onTouch(event:TurkeyMouseEvent):void
        {
                mParticleSystem.emitterX = event.stageX;
                mParticleSystem.emitterY = event.stageY;
        }
    }
}