package turkey.errors
{
    public class MissingContextError extends Error
    {
        /** Creates a new MissingContextError object. */
        public function MissingContextError(message:*="", id:*=0)
        {
            super(message, id);
        }
    }
}