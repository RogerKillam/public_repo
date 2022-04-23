1. Array indices start at one. **[FALSE]**

2. Array.Rank is the total number of elements. **[FALSE]**

3. Array.Length is the number of array dimensions. **[FALSE]**

4. foreach is used to iterate through an array. **[TRUE]**

5. protected class data is used in inheritance. **[TRUE]**

6. Static variables retain their values for the life of the program. **[TRUE]**

7. Constructors are used to initialize class data. **[TRUE]**

8. Accessor functions are used to hide data. **[TRUE]**

9. The elements of an array can be different types. **[TRUE]**

10. The elements of a structure can be different types. **[TRUE]**

11. Which is the correct operator to access a member of a structure?

**A. .**

B. [ ]

C. ( )

D. !

12. Several functions with the same name are called:
A. overall
B. oversize
**C. overloading**
D. overdone

13. If aiArray has 10 elements, which is the last logically valid accessible element:
A. aiArray[8]
**B. aiArray[9]**
C. aiArray[10]
D. aiArray[11]

14. Which is the correct way to declare a two-dimensional array:
A. int[ , ] aiArray;
B. int[ ] aiArray;
**C. int[ ][ ] aiArray;**
D. int[ ].[ ] aiArray;

15. The parameter to a function int AddSum(int iVal) is:
A. passed by ref
**B. passed by value**
C. passed by pointer
D. None of the above

16. A local variable's scope is:
A. within a module
B. within a function
**C. within a statement**
D. None of the above

17. Declare an integer array of size 100:
**A. int[] numbers = new int[100];**
B. int numbers = new[] int[100];
C. int[100] numbers = new int[];
D. int new numbers = int[100];

18. Properties should have the following:
A. let / set
**B. get / set**
C. get only
D. set only

19. Which is the correct way to test two strings for equality?
**A. Str1 == Str2**
B. *Str1 == *Str2
C. &Str1 == &Str2
D. None of the above

20. Which one is a correct way to access a method from class Point:
A. point.MyMethod();
**B. Point.MyMethod();**
C. class point.MyMethod()
D. class MyMethod(); 

21. What happens when you create an object of a class? Briefly describe the steps that happen behind the scene to the class that we instantiate from.
**When a class is created, its constructor is called. Constructors have the same name as the class, and they usually initialize the data members of the new object.**

22. What will the following display?
 
 ```
    using System;
    class Test
    {
        static void Main()
        {
            int[] X = new int[10] { 0, 1, 4, 9, 16, 0, 0, 0, 0, 0 };
            int k;

            for (k = 5; k < 10; ++k)
            {
                X[k] = k * k;
            }

            for (k = 0; k < X.Length; k++)
            {
                Console.Write("{0}  ", X[k]);
            }
        }
    }
```
 
**Display = 0  1  4  9  16  25  36  49  64  81**

23. What will the following do?

```
    using System;
    class Factorial
    {
        public static void Main()
        {
            long nFactorial = 1;
            long nComputeTo = 5;

            long nCurDigit = 1;

            try
            {
                long x = 1 / (1 - nFactorial);

                checked
                {
                    for (; nCurDigit <= nComputeTo; nCurDigit++)
                    {
                        nFactorial *= nCurDigit;
                    }
                }
            }
            catch (OverflowException e)
            {
                Console.WriteLine("Computing {0}! caused an overflow {1}",
                nComputeTo, e.StackTrace);
                return;
            }

            //catch (DivideByZeroException d)
            //{
            //Console.WriteLine("x cannot be zero");
            //return;
            //}

            Console.WriteLine("{0}! is {1}", nComputeTo, nFactorial);
        }
    }
```

**Behavior = This program will not complete. The try statement as written will not catch x’s DivideByZeroException.**

24. What will the following display?
 
 ```
    using System;
    class Shape
    {
    }

    class Test
    {
        static void Main()
        {
            Shape s = new Shape();
            Console.WriteLine(s);
        }
    }
```

**Display = Shape**

25. Define a structure that contains a student name, social security number, number of classes taken, and a letter grade.

```
    struct Student
    {
        public string Name;
        public string Grade; //Assuming char will not address + and – grades
        public int ClassesCount;
        private int SSN;

        public Student(string name, string grade, int count, int ssn)
        {
            Name = name;
            Grade = grade;
            ClassesCount = count;
            SSN = ssn;
        }
    }
```
 
26. Define an enum for the seasons (Summer, Spring, Winter, and Fall).

```
    enum Seasons
    {
        Summer, //The default value of the first enum member is 0 
        Spring,
        Winter,
        Fall
    }
```

27. Given the following program what will be displayed. Is there anything unusual about this program?
 
 ```
    using System;
    class Test
    {
        static void Main()
        {
            int[] xlist = new int[] { 9, 5, 3, -2, 4, 5 };

            for (int x = 0; x < xlist.Length; x++)
            {
                if (xlist[x] == 3)
                {
                    for (int y = x; y < xlist.Length - 1; y++)
                    {
                        xlist[y] = xlist[y + 1];
                    }
                }
            }

            foreach (int v in xlist)
            {
                Console.Write("{0} ", v);
            }
        }
    }
```

**Display = 9 5 -2 4 5 5**
**This program will shift the items up 1 place in the index, leaving index 5 alone, which is why item 5 is printed twice.**
 
28. Given the following program what will be displayed. Is there anything unusual about this program?
 
 ```
    using System;
    class Test
    {
        static void Main()
        {
            int[] xlist = new int[] { 7, -2 };

            for (int x = 0; x < xlist.Length - 1; x++)
            {
                if (xlist[x] > xlist[x + 1])
                {
                    int t = xlist[x];
                    xlist[x] = xlist[x + 1];
                    xlist[x + 1] = t;
                }
            }

            foreach (int v in xlist)
            {
                Console.Write("{0} ", v);
            }
        }
    }
```

**Display = -2 7**
**This program uses three steps to flip array items 7 and -2. Variable t is used as the temporary container for the flip algorithm.**
 