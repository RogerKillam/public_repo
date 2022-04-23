// Write a program that calculates factorial of an integer n given by the user.

using System;
namespace Factorial

{
    class Program
    {
        static void Main(string[] args)
        {
            Console.Write("Please enter a small integer between 1 and 10: ");
            int n = int.Parse(Console.ReadLine());
            int fact = n;
            if (n <= 10)
            {
                for (int i = n - 1; i >= 1; i--)
                {
                    fact = fact * i;
                }
                Console.WriteLine("{0}! = {1}", n, fact);
                Console.ReadLine();
            }
        }
    }
}
