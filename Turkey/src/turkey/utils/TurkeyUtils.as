package turkey.utils
{
	public class TurkeyUtils
	{
		public function TurkeyUtils()
		{
		}
		
		public static function getNextPowerOfTwo(number:int):int
		{
			if (number > 0 && (number & (number - 1)) == 0) // see: http://goo.gl/D9kPj
				return number;
			else
			{
				var result:int = 1;
				while (result < number) result <<= 1;
				return result;
			}
		}
		
		public static function combineArray(arr1:Array,arr2:Array):Array
		{
			if(arr1==null&&arr2==null)return null;
			var result:Array = arr1 == null?null:arr1.concat();
			result = arr2 == null?result:(result==null?arr2.concat():arr2.concat(result));
			return result;
		}
	}
}