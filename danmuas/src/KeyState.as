package
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author ｋａｋａ
	 */
	public class KeyState 
	{
		static private var key:Object = new Object();
		static private var stage:Stage;
		
		static public function setStage(_stage:Stage):void
		{
			stage = _stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, key_down, false, 2);
			stage.addEventListener(KeyboardEvent.KEY_UP, key_up, false, 2);
		}
		
		static public function clear():void
		{
			for(var name:String in key)
			{
				delete key[name];
			}
		}

		static public function keyIsDown(keyCode:int):Boolean
		{
			return key[keyCode];
		}
		
		static private function key_down(evt:KeyboardEvent):void
		{
			key[evt.keyCode] = true; 
		}
		
		static private function key_up(evt:KeyboardEvent):void
		{
			key[evt.keyCode] = false;
		}
	}        
}