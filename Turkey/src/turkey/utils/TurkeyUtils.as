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
	}
}