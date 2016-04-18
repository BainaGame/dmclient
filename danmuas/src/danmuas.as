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
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.HTMLUncaughtScriptExceptionEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.html.HTMLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	[SWF(width=1024,height=768,frameRate=60)]
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
		private var config:Object = {font:[40,80],time:[6,9],color:[0xff3399,0x0066cc,0x6ff66,0xFFff33,0x9900ff,0xcc00ff,009966]};
		
		private var htmlLoader:HTMLLoader;
		
		public function danmuas()
		{
			
			stage.nativeWindow.alwaysInFront = true;
			stage.nativeWindow.orderToFront();
			
			stage.nativeWindow.width = Capabilities.screenResolutionX;
			stage.nativeWindow.height = Capabilities.screenResolutionY;
			
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			trace(stage.nativeWindow.bounds);
			
			init();
			
			showIndicator(10,0);
		}
		
		/**
		 * 显示指示器，知道窗口知否置顶了
		 */
		private function showIndicator(offsetX:Number,offsetY:Number):void
		{
			var shape:Shape = new Shape();
			var graphic:Graphics = shape.graphics;
			
			var width:int = 3;
			
			graphic.beginFill(0);
			graphic.drawRect(0,0,width,width);
			graphic.drawRect(width,width,width,width);
			graphic.beginFill(0xffffff);
			graphic.drawRect(0,width,width,width);
			graphic.drawRect(width,0,width,width);
			graphic.endFill();
			
			container.addChild(shape);
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
			this.htmlLoader.load(new URLRequest("http://123.59.82.49/client.html"));
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
			text.filters = [new GlowFilter(0xffffff,1,2,2,255)];
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