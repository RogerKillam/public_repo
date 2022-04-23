// Write a program that takes seconds and converts it into days, hours, minutes, and seconds.
// 129023 seconds should generate: 1 days, 11 hours, 50 minutes, and 23 seconds

using System;
namespace ComplexCalculations
{
    class Program
    {
        static void Main(string[] args)
        {
            // Input
            Console.Write("Enter seconds (129023):");
            int readSeconds = int.Parse(Console.ReadLine());

            // Days
            int days = readSeconds / 86400;
            int rDays = readSeconds % 86400;
            // Hours
            int hours = rDays / 3600;
            int rHours = rDays % 3600;
            // Minutes
            int minutes = rHours / 60;
            int rMinutes = rHours % 60;
            // Seconds
            int seconds = rMinutes / 60;
            int rSeconds = rMinutes % 60;

            // Output
            Console.WriteLine("{0} days, {1} hours, {2} minutes, and {3} seconds", days, hours, minutes, seconds);
            Console.ReadLine();
        }
    }
}
