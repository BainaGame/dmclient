package
{
	/**
	 * 
	 * 屏幕分成很多行，每一行同一时刻只有一行文字，一行结束后才可以显示下一行
	 * 
	 * */
	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.HTMLUncaughtScriptExceptionEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.html.HTMLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	[SWF(width=1024,height=768,frameRate=60,backgroundColor=0x000000)]
	public class danmuas extends Sprite
	{
		private var designHeight:int = 768;
		private var designWidth:int = 1024;
		private var designLineHeight:int = 20;
		
		private var timer:Timer;
		
		private var container:Sprite;
		
		private var dataList:Array;
		
		/**空闲行号列表*/
		private var idleLines:Array;
		
		/** 配置信息，颜色列表，最大字号，最小字号*/
		private var config:Object = {font:[20,50],time:[4,7],color:[0xFAEBD7,0xF0F8FF,0xF5F5DC,0xFFE4C4,0xFFEBCD,0xD2691E]};
		
//		古董白 #FAEBD7
//		爱丽丝蓝 #F0F8FF
//		米　色 #F5F5DC
//		陶坯黄 #FFE4C4
//		杏仁白 #FFEBCD
//		军服蓝 #5F9EA0
//		查特酒绿 #7FFF00
//		巧克力色 #D2691E
//		珊瑚红 #FF7F50
//		绯　红 #DC143C
//		深卡其色 #BDB76B
//		深品红 #8B008B
//		金　色 #FFD700
		
		private var htmlLoader:HTMLLoader;
		
		public function danmuas()
		{
			stage.nativeWindow.alwaysInFront = true;
			stage.nativeWindow.orderToFront();
			stage.displayState = StageDisplayState.FULL_SCREEN;
			
			init();
		}
		
		private function init():void
		{
			timer = new Timer(100);
			container = new Sprite();
			addChild(container);
			
			initHtmlLoader();
			initLines();
		}
		
		private function initHtmlLoader():void
		{
			this.htmlLoader = new HTMLLoader();
			this.htmlLoader.window.myJSCallAS = myJSCallAS;
			this.htmlLoader.load(new URLRequest("http://123.59.82.49:4000/client.html"));
			this.htmlLoader.addEventListener(Event.COMPLETE,completeHandler);
			this.htmlLoader.addEventListener(HTMLUncaughtScriptExceptionEvent.UNCAUGHT_SCRIPT_EXCEPTION,exceptionHandler);
		}
		
		private function initLines():void
		{
			idleLines = [];
			
			var numLines:int = designHeight / designLineHeight;
			for(var i:int=0;i<numLines;i++)
			{
				idleLines.push(i);
			}
		}
		
		private function exceptionHandler(evt:HTMLUncaughtScriptExceptionEvent):void
		{
			showOneMessage("JS出错");
		}
		
		private function myJSCallAS(str:String):void
		{
			showOneMessage(str);
		}
		
		private function completeHandler(evt:Event):void
		{
			showOneMessage("加载完成");
		}
		
		private function showOneMessage(msg:String):void
		{
			if (idleLines.length > 0)
			{
				var index:int = this.getRandomInt(0,idleLines.length);
				showOneMessageByLine(idleLines.splice(index,1),msg);
			}
			else
			{
				trace("没办法显示!")
			}
		}
		
		/**显示一条弹幕*/
		private function showOneMessageByLine(lineNum:int,msg:String):void 
		{
			var text:TextField = new TextField();
			text.autoSize = TextFieldAutoSize.LEFT;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = this.getArrayRandom(config.color);
			textFormat.size = this.getRandomInt(config.font[0],config.font[1]);
			textFormat.font = "微软雅黑";
			textFormat.align = TextFormatAlign.LEFT;
			
			text.setTextFormat(textFormat);
			text.defaultTextFormat = textFormat;
			
			text.text = msg;
			
			this.container.addChild(text);
			
			text.x = Capabilities.screenResolutionX;
			text.y = designHeight - lineNum * designLineHeight - config.font[1];
			
			TweenLite.to(text,
				this.getRandomNumber(config.time[0],config.time[1]),
				{
					x:-text.width,
					onComplete:onLineComplete,
					onCompleteParams:[lineNum, text],
					ease:Sine.easeInOut
				}
			);
		}
		
		private function onLineComplete(lineNum:int,text:DisplayObject):void
		{
			idleLines.push(lineNum);
			
			if (text.parent)
			{
				text.parent.removeChild(text);
			}
		}
		
		/**
		 *显示弹幕 
		 */		
		private function showText():void
		{
			timer.addEventListener(TimerEvent.TIMER,timerHandler);
			timer.start();
		}
		
		private function timerHandler(evt:TimerEvent):void
		{
			
		}
		
		private function getRandomNumber(min:int,max:int):int
		{
			max = Math.max(max,min);
			min = Math.min(max,min);
			
			var sub:int = max - min;
			var random:Number = Math.random();
			
			return min + sub * random;
		}
		
		private function getRandomInt(min:int,max:int):int
		{
			max = Math.max(max,min);
			min = Math.min(max,min);
			
			var sub:int = max - min;
			var random:Number = Math.random();
			
			return min + Math.floor(sub * random);
		}
		
		private function getArrayRandom(arr:Array):Object
		{
			if (arr.length == 0)
			{
				return null;
			}
			
			var random:Number = Math.random();
			var index:int = Math.floor(arr.length * random);
			
			return arr[index];
		}
		
		private function onTweenComplete(time:Number,text:DisplayObject):void
		{
			if (text.parent)
			{
				text.parent.removeChild(text);
			}
		}
		
		private function makeTextFormate(textField:TextField):void
		{
			
		}
		
		private function showSprite():void
		{
			var sprite:Sprite = new Sprite();
			var g:Graphics = sprite.graphics;
			
			sprite.addEventListener(MouseEvent.MOUSE_DOWN,downHandler);
			
			g.lineStyle(10);
			g.drawCircle(100,100,100);
			
			addChild(sprite);
		}
		
		protected function downHandler(event:MouseEvent):void
		{
			stage.nativeWindow.startMove();
		}
		
		private function getDatas():Array
		{
			var result:Array = [];
			
			for(var i:int=0;i<200;i++)
			{
				result.push("测试文字"+i);
			}
			
			return result;
		}
	}
}