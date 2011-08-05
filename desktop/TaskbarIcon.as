package desktop
{
	import flash.desktop.NativeApplication;
	import flash.utils.Dictionary;
	
	
	public final class TaskbarIcon
	{
		private static var icons:Dictionary = new Dictionary(false);
		
		private static var _memento:TaskbarIconMemento;
		private static var _timer:TaskbarIconTimer;
		
		
		public static function get icon():String
		{
			return memento.name;
		}
		
		public static function set icon(value:String):void
		{
			if (icons.hasOwnProperty(value))
			{
				if (TaskbarIcon.icon === value)
				{
					return;
				}
				
				memento.setIcon(value, icons[value]);
				
				if (memento.totalFrames > 1 && memento.icon.frameRate > 0)
				{
					timer.frameRate = memento.icon.frameRate;
					timer.start();
				}
				else
				{
					timer.stop();
					
					TaskbarIcon.setIconDataFrame(memento.currentFrame);
				}
			}
			else
			{
				throw new ArgumentError("Parameter icon must be one of the accepted values.");
			}
		}
		
		
		private static function timerCallback():void
		{
			TaskbarIcon.setIconDataFrame(memento.currentFrame);
			memento.nextFrame();
		}
		
		private static function setIconDataFrame(index:uint):void
		{
			NativeApplication.nativeApplication.icon.bitmaps = [memento.icon.data[index]];
		}
		
		
		public static function get supportsIcon():Boolean
		{
			return NativeApplication.supportsDockIcon || NativeApplication.supportsSystemTrayIcon;
		}
		
		
		public static function registerIcon(name:String, icon:TaskbarIconData):TaskbarIconData
		{
			icons[name] = icon;
			return icon;
		}
		
		public static function unregisterIcon(name:String):TaskbarIconData
		{
			var icon:TaskbarIconData;
			
			if (icons.hasOwnProperty(name))
			{
				if (TaskbarIcon.icon === name)
				{
					TaskbarIcon.hide();
					memento.dispose();
				}
				
				icon = icons[name];
				delete icons[name];
			}
			
			return icon;
		}
		
		
		public static function hide():void
		{
			timer.stop();
			
			NativeApplication.nativeApplication.icon.bitmaps = [];
		}
		
		public static function show():void
		{
			if (memento.name)
			{
				TaskbarIcon.icon = memento.name;
			}
		}
		
		
		public static function dispose(disposeIconData:Boolean = false):void
		{
			if (_timer)
			{
				_timer.dispose();
				_timer = null;
			}
			
			if (_memento)
			{
				_memento.dispose();
				_memento = null;
			}
			
			if (disposeIconData)
			{
				for each (var icon:TaskbarIconData in icons)
				{
					icon.dispose();
					icon = null;
				}
			}
			
			icons = new Dictionary(false);
		}
		
		
		private static function get memento():TaskbarIconMemento
		{
			return _memento ||= new TaskbarIconMemento();
		}
		
		private static function get timer():TaskbarIconTimer
		{
			return _timer ||= new TaskbarIconTimer(timerCallback);
		}
	}
}




import desktop.TaskbarIconData;


final class TaskbarIconMemento
{
	private var _icon:TaskbarIconData;
	private var _currentFrame:uint;
	private var _name:String;
	
	
	public function get icon():TaskbarIconData
	{
		return _icon;
	}
	
	
	public function get name():String
	{
		return _name;
	}
	
	
	public function get currentFrame():uint
	{
		return _currentFrame;
	}
	
	public function get totalFrames():uint
	{
		return _icon.data.length;
	}
	
	
	public function nextFrame():void
	{
		if (++_currentFrame > this.totalFrames - 1)
		{
			this.resetCurrentFrame();
		}
	}
	
	
	public function setIcon(name:String, icon:TaskbarIconData):void
	{
		_name = name;
		_icon = icon;
		
		this.resetCurrentFrame();
	}
	
	
	public function dispose():void
	{
		_name = null;
		_icon= null;
		
		this.resetCurrentFrame();
	}
	
	
	private function resetCurrentFrame():void
	{
		_currentFrame = 0;
	}
}




import flash.events.TimerEvent;
import flash.utils.Timer;


final class TaskbarIconTimer
{
	/*
	* Timer frequency is limited to 60 frames per second, meaning
	* a delay lower than 16.6 milliseconds causes runtime problems.
	*/
	private static const MIN_TIMER_DELAY:Number = 16.6;
	
	
	private var timer:Timer;
	private var callback:Function;
	
	private var _frameRate:uint;
	
	
	public function TaskbarIconTimer(callback:Function)
	{
		this.callback = callback;
		this.internalInitialize();
	}
	
	
	public function get frameRate():uint
	{
		return _frameRate;
	}
	
	public function set frameRate(value:uint):void
	{
		_frameRate = value;
		
		this.setTimerDelayByFrameRate();
		
	}
	
	
	public function start():void
	{
		if (timer.running === false && _frameRate > 0)
		{
			timer.start();
		}
	}
	
	public function stop():void
	{
		if (timer.running)
		{
			timer.stop();
		}
	}
	
	
	public function dispose():void
	{
		if (timer)
		{
			timer.removeEventListener(TimerEvent.TIMER, timerHandler, false);
			timer.stop();
			timer = null;
		}
		
		callback = null;
		_frameRate = 0;
	}
	
	
	private function internalInitialize():void
	{
		timer = new Timer(1000, 0);
		timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
	}
	
	
	private function timerHandler(event:TimerEvent):void
	{
		event.stopImmediatePropagation();
		
		timer.stop();
		
		try {
			callback();
		} catch (error:Error) { }
		
		timer.start();
	}
	
	
	private function setTimerDelayByFrameRate():void
	{
		var delay:Number = 1000 / _frameRate;
		if (delay < TaskbarIconTimer.MIN_TIMER_DELAY)
		{
			delay = TaskbarIconTimer.MIN_TIMER_DELAY;
		}
		
		timer.delay = delay;
	}
}