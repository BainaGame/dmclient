package
{
	/**
	 * 
	 * 屏幕分成很多行，每在一行上增加一个弹幕，则这个行号会被移动到列表尾部，增加弹幕时会从列表前面随机找一个行号来显示
	 * 
	 * */
	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.HTMLUncaughtScriptExceptionEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.html.HTMLLoader;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	[SWF(width=1024,height=768,frameRate=60)]
	public class danmuas extends Sprite
	{
		private var designHeight:int = 768;
		private var designWidth:int = 1024;
		private var designLineHeight:int = 20;
		
		private var container:Sprite;
		
		private var msgArr:Array = [];
		
		/**空闲行号列表,每在一行上增加一个弹幕，则这个行号会被移动到列表尾部*/
		private var idleLines:Array;
		
		/** 配置信息，颜色列表，最大字号，最小字号*/
		private var config:Object = {font:[45,80],time:[6,9],color:[0xff3399,0x0066cc,0x6ff66,0xFFff33,0x9900ff,0xcc00ff,009966]};
		
		private var htmlLoader:HTMLLoader;
		
		private var resultText:TextField;
		
		public function danmuas()
		{
			stage.nativeWindow.alwaysInFront = true;
			stage.nativeWindow.orderToFront();
			
			stage.nativeWindow.width = Capabilities.screenResolutionX;
			stage.nativeWindow.height = Capabilities.screenResolutionY;
			
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			init();
			
			showIndicator(10,0);
			
			stage.nativeWindow.addEventListener(Event.ACTIVATE,function (evt:Event):void{
				trace("asdfasdf")
			});
			
			stage.nativeWindow.addEventListener(Event.CLOSING,function(evt:Event):void{
				trace("closing");
			});
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
		
		/**
		 * 初始化结果文本框
		 */
		private function initResultText():void
		{
			resultText = new TextField();
			resultText.width = 800;
			resultText.height = 600;
			resultText.multiline = true;
			resultText.background = true;
			resultText.border = true;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = 30;
			textFormat.align = TextFormatAlign.CENTER;
			
			resultText.defaultTextFormat = textFormat;
			
			resultText.x = (designWidth-resultText.width)/2;
			resultText.y = (designHeight-resultText.height)/2;
			
			resultText.text = "";
			
			addChild(resultText);
			
			hideResult();
		}
		
		private function init():void
		{
			container = new Sprite();
			
			addChild(container);
			
			initHtmlLoader();
			initLines();
			
			initResultText();
			
			KeyState.setStage(stage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
		}
		
		private function keyDownHandler (evt:KeyboardEvent):void
		{
			if (evt.keyCode == Keyboard.M && evt.ctrlKey)
			{
				trace("按了 ctrl m");
				showResult();
			}
			
			if (evt.keyCode == Keyboard.M && evt.ctrlKey && evt.shiftKey )
			{
				trace("按了 ctrl M");
				hideResult();
			}
			
			if (evt.keyCode == Keyboard.S &&  evt.ctrlKey)
			{
				trace("按了 ctrl s");
				alertSave();
			}
		}
		
		private function alertSave():void
		{
			var filecontent:String = msgArr.join("\r\n");
			var fileRef:FileReference = new FileReference();
			fileRef.save(filecontent,"dm.txt");
		}
		
		private function showResult():void
		{
			var result:String = msgArr.join("\n");
			resultText.text = result;
			
			resultText.visible = true;
		}
		
		private function hideResult():void
		{
			resultText.text = "";
			resultText.visible = false;
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
			
			var numLines:int = (designHeight-config.font[1]) / designLineHeight;
			for(var i:int=0;i<numLines;i++)
			{
				idleLines.push(i);
			}
		}
		
		private function exceptionHandler(evt:HTMLUncaughtScriptExceptionEvent):void
		{
			showOneMessageByLine(0,"JS出错",40);
		}
		
		private function myJSCallAS(str:String):void
		{
			msgArr.push(str);
			showOneMessage(str);
		}
		
		private function completeHandler(evt:Event):void
		{
			showOneMessageByLine(0,"加载完成",40);
		}
		
		private function showOneMessage(msg:String):void
		{
			var index:int = this.getRandomInt(0,idleLines.length-10);
			var lineNum:int = idleLines.splice(index,1);
			idleLines.push(lineNum);
			showOneMessageByLine(lineNum,msg);
		}
		
		/**显示一条弹幕*/
		private function showOneMessageByLine(lineNum:int,msg:String,size:int=40):void
		{
			var text:TextField = new TextField();
			text.cacheAsBitmap = true;
			text.autoSize = TextFieldAutoSize.LEFT;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = this.getArrayRandom(config.color);
			textFormat.size = size || this.getRandomInt(config.font[0],config.font[1]);
			textFormat.font = "微软雅黑";
			textFormat.bold = true;
			textFormat.align = TextFormatAlign.LEFT;
			
			text.setTextFormat(textFormat);
			text.defaultTextFormat = textFormat;
			
			text.text = msg;
			
			this.container.addChild(text);
			
			text.x = designWidth;
			text.y = designHeight - lineNum * designLineHeight - text.height;
			
			TweenLite.to(text,
				this.getRandomNumber(config.time[0],config.time[1])*(designWidth+text.width)/designWidth,
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
			if (text.parent)
			{
				text.parent.removeChild(text);
			}
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
			text.cacheAsBitmap = false;
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