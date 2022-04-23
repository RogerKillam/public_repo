// Modify the Queue class to grow as elements are added.
// Modify Enqueue() to call the GrowQueue function when the count+1 is greater than or equal to the array.

using System;
namespace GrowQueueClass

{
    class Program
    {
        // Test GrowQueue()
        public static void Main()
        {
            int[] a = { 1, 2, 3 };
            a = (int[])GrowQueue(a, 5);
            a[3] = 4;
            a[4] = 5;
            for (int i = 0; i < a.Length; i++)
                Console.WriteLine(a[i]);
        }

        private static Array GrowQueue(Array oldArray, int newSize)
        {
            // Create the bigger new array
            int oldSize = oldArray.Length;
            Type elementType = oldArray.GetType().GetElementType();
            Array newArray = Array.CreateInstance(elementType, newSize);

            // Copy the elements from the old array to the new array
            // Reset the head and tail indexes
            int preserveLength = Math.Min(oldSize, newSize);
            if (preserveLength > 0)
                System.Array.Copy(oldArray, newArray, preserveLength);

            // Point to new queue
            return newArray;
        }
    }
}
