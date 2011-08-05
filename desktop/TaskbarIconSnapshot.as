package desktop
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	public final class TaskbarIconSnapshot
	{
		public static function drawIconData(bitmap:BitmapData, textField:TextField, centerOffset:Point = null):BitmapData
		{
			textField.autoSize = TextFieldAutoSize.LEFT;
			centerOffset = centerOffset ||= new Point;
			
			var matrix:Matrix = new Matrix();
			matrix.translate(
				-(textField.width >> 1) + (bitmap.width >> 1),
				-(textField.height >> 1) + (bitmap.height >> 1)
			);
			
			var textFieldBitmap:BitmapData = new BitmapData(bitmap.width - centerOffset.x, bitmap.height - centerOffset.y, true, 0);
			textFieldBitmap.draw(textField, matrix, null, null, null, true);
			
			var result:BitmapData = bitmap.clone();
			result.copyPixels(textFieldBitmap, new Rectangle(0, 0, bitmap.width - centerOffset.x, bitmap.height - centerOffset.y), centerOffset, null, null, true);
			
			textFieldBitmap.dispose();
			
			return result;
		}
	}
}