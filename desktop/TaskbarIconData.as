package desktop
{
	import flash.display.BitmapData;
	
	
	public final class TaskbarIconData
	{
		public var data:Vector.<BitmapData>;
		public var frameRate:uint;
		
		
		public function dispose():void
		{
			for each (var bitmapData:BitmapData in data)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
			
			data = null;
			frameRate = 0;
		}
	}
}