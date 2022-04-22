using System;

public struct Pet
{
    public string Name;
    public string TypeOfPet;
}

namespace Structure

{
    class Program
    {
        static void Main(string[] args)
        {
            var numberOfPets = 0;
            var pets = new Pet[10];

            while (true)
            {
                Console.Write("\nSelect one of the following options by typing A, D, C or L\nA) Add a pet\nD) Delete a pet\nC) Change a pet\nL) List pets\nE) Exit\n>>");
                var choice = Console.ReadLine().ToLower();

                switch (choice)
                {
                    case "a":
                        {
                            Console.Write("\nName:");
                            var name = Console.ReadLine();

                            Console.Write("Type of pet:");
                            var typeOfPet = Console.ReadLine();

                            // Add the pet to the end of the array
                            pets[numberOfPets].Name = name;
                            pets[numberOfPets].TypeOfPet = typeOfPet;

                            numberOfPets++;
                            break;
                        }

                    case "d":
                        {
                            if (numberOfPets == 0)
                            {
                                Console.WriteLine("\nNo pets");
                                break;
                            }

                            for (var index = 0; index < numberOfPets; index++)
                            {
                                Console.WriteLine("\n{0}. {1,-10} {2}", index + 1, pets[index].Name, pets[index].TypeOfPet);
                            }

                            Console.Write("\nWhich pet to remove (1-{0})", numberOfPets);

                            var indexToDelete = int.Parse(Console.ReadLine());

                            // Squish the array from index to the end
                            for (var index = indexToDelete - 1; index < numberOfPets; index++)
                            {
                                // Copy the pet from the next index into the current index
                                pets[index] = pets[index + 1];
                            }

                            // One less pet
                            numberOfPets--;
                            break;
                        }

                    case "c":
                        if (numberOfPets == 0)
                        {
                            Console.WriteLine("\nNo pets");
                            break;
                        }

                        for (var index = 0; index < numberOfPets; index++)
                        {
                            Console.WriteLine("\n{0}. {1,-10} {2}", index + 1, pets[index].Name, pets[index].TypeOfPet);
                        }

                        Console.Write("\nWhich pet to change (1-{0})", numberOfPets);

                        var indexToChange = int.Parse(Console.ReadLine());

                        Console.Write("\nNew Name:");
                        var changeName = Console.ReadLine();

                        Console.Write("New pet type:");
                        var changeTypeOfPet = Console.ReadLine();

                        pets[indexToChange - 1].Name = changeName;
                        pets[indexToChange - 1].TypeOfPet = changeTypeOfPet;

                        break;

                    case "l":
                        {
                            if (numberOfPets == 0)
                            {
                                Console.WriteLine("\nNo pets");
                            }

                            for (int index = 0; index < numberOfPets; index++)
                            {
                                Console.WriteLine("\n{0}. {1,-10} {2}", index + 1, pets[index].Name, pets[index].TypeOfPet);
                            }

                            break;
                        }

                    case "exit":
                    case "e":
                        {
                            return;
                        }

                    default:
                        {
                            Console.WriteLine("\nInvalid option [{0}]", choice);
                            break;
                        }
                }
            }
        }
    }
}
