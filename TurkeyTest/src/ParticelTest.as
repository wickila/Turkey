package 
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    import turkey.core.Turkey;
    import turkey.events.TurkeyEvent;
    
    [SWF(width="640", height="480", frameRate="60", backgroundColor="#000000")]
    public class ParticelTest extends Sprite
    {
        public function ParticelTest()
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			Turkey.init(stage,stage.stageWidth,stage.stageHeight,stage.color);
			Turkey.stage.addEventListener(TurkeyEvent.COMPLETE,onTurkeyInit);
        }
		
		private function onTurkeyInit(event:TurkeyEvent):void
		{
			Turkey.stage.addChild(new ParticelContainer());
		}
	}
}