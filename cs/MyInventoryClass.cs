// Write a program to keep track of some inventory items.

using System;
struct ItemData
{
    public int itemIDNo;
    public string sDescription;
    public double dblPricePerItem;
    public int iQuantityOnHand;
    public double dblOurCostPerItem;
    public double dblValueOfItem;
}

class MyInventory
{
    public static void Main()
    {
        // Use an integer to keep track of the count of items in your inventory					
        int icount = 0;
        int index;

        // Create an array of your ItemData struct
        // Minimum size is 10 items with the ability to grow to a maximum of 100 items
        ItemData[] itemProperty = new ItemData[10];

        // Use a never-ending loop that shows the user what options are available
        while (true)
        {
            Console.WriteLine("\n1) Add an item"); // provide an extra blank line on screen
            Console.WriteLine("2) Change an item"); // by giving its item number not array index
            Console.WriteLine("3) Delete an item"); // by giving its item number not array index
            Console.WriteLine("4) List all items in the database");
            Console.WriteLine("5) Quit");
            Console.Write("\nSelect an option : ");

            // Read user's input
            // Convert the given string to integer to match case types shown below
            int.TryParse(Console.ReadLine(), out int optx); // using TryParse to validate input

            switch (optx)
            {
                case 1: // add an item to the list if this option is selected
                    {
                        Console.Write("\nItem ID Number : ");
                        int.TryParse(Console.ReadLine(), out int id);

                        Console.Write("Description : ");
                        string description = Console.ReadLine();

                        Console.Write("Price Per Item : ");
                        double.TryParse(Console.ReadLine(), out double price);

                        Console.Write("Quantity On Hand : ");
                        int.TryParse(Console.ReadLine(), out int quantity);

                        Console.Write("Cost Per Item : ");
                        double.TryParse(Console.ReadLine(), out double cost);

                        double value = price * quantity; // value of item (price * quantity on hand)

                        itemProperty[icount].itemIDNo = id;
                        itemProperty[icount].sDescription = description;
                        itemProperty[icount].dblPricePerItem = price;
                        itemProperty[icount].iQuantityOnHand = quantity;
                        itemProperty[icount].dblOurCostPerItem = cost;
                        itemProperty[icount].dblValueOfItem = value;

                        // Test array length
                        // The database must be able to hold at least 10 items and at most 100 items
                        if (itemProperty.Length > 100)
                        {
                            Console.WriteLine("\nThe database has reached its maximum capacity of 100 items");
                            Console.WriteLine("Press any key to continue...");
                            Console.ReadLine();

                            break;
                        }
                        else if (itemProperty.Length < (itemProperty.Length + 1))
                        {
                            // Grow array
                            int newSize = (itemProperty.Length + 5);
                            itemProperty = (ItemData[])GrowQueue(itemProperty, newSize); // call GrowQueue method
                            icount++;

                            break;
                        }
                        else
                        {
                            // If the array is not full increase by one item
                            icount++;

                            break;
                        }
                    }

                case 2: // Change items in the list if this option is selected
                    {
                        Console.Write("\nPlease enter an item ID No : ");
                        int.TryParse(Console.ReadLine(), out int chgID);

                        bool fFound = false;

                        for (index = 0; index < icount; index++)
                        {
                            if (itemProperty[index].itemIDNo == chgID)
                            {
                                fFound = true;

                                // Code to show what must happen if the item in the list is found
                                Console.WriteLine("\nItem {0} has been found", chgID);

                                Console.WriteLine("\nItem details...");

                                Console.WriteLine("\nItem#        ItemID        Description                 Price        QOH        Cost        Value");
                                Console.WriteLine("-----------  ------------  --------------------------  -----------  ---------  ----------  -----------");
                                Console.WriteLine("{0,-12} {1,-13} {2,-27} {3,-12:C} {4,-10} {5,-11:C} {6:C}", index, itemProperty[index].itemIDNo, itemProperty[index].sDescription, itemProperty[index].dblPricePerItem, itemProperty[index].iQuantityOnHand, itemProperty[index].dblOurCostPerItem, itemProperty[index].dblValueOfItem);

                                Console.WriteLine("\nChange item properties...");

                                Console.Write("\nNew item ID number : ");
                                int.TryParse(Console.ReadLine(), out int chId);

                                Console.Write("New description : ");
                                string chDescription = Console.ReadLine();

                                Console.Write("New price per item : ");
                                double.TryParse(Console.ReadLine(), out double chPrice);

                                Console.Write("New quantity on hand : ");
                                int.TryParse(Console.ReadLine(), out int chQuantity);

                                Console.Write("New cost per item : ");
                                double.TryParse(Console.ReadLine(), out double chCost);

                                double chValue = chPrice * chQuantity; // value of item (price * quantity on hand)

                                itemProperty[index].itemIDNo = chId;
                                itemProperty[index].sDescription = chDescription;
                                itemProperty[index].dblPricePerItem = chPrice;
                                itemProperty[index].iQuantityOnHand = chQuantity;
                                itemProperty[index].dblOurCostPerItem = chCost;
                                itemProperty[index].dblValueOfItem = chValue;

                                break;

                            }
                        }

                        if (!fFound) // ...and if not found
                        {
                            Console.WriteLine("Item {0} not found", chgID);
                            Console.WriteLine("Press any key to continue...");
                            Console.ReadLine();
                        }

                        break;
                    }

                case 3: // Delete items in the list if this option is selected
                    {
                        Console.Write("\nPlease enter an item ID number : ");
                        int.TryParse(Console.ReadLine(), out int delID);

                        bool fDeleted = false;

                        for (index = 0; index < icount; index++)
                        {
                            if (itemProperty[index].itemIDNo == delID)
                            {
                                fDeleted = true;

                                // Delete the item if you found it
                                // Reset the count to show a new count for your list 
                                itemProperty[index] = itemProperty[index + 1];

                                // Note: your list is now reduced by one item
                                icount--;
                            }
                        }

                        if (fDeleted == true)
                        {
                            Console.WriteLine("\nItem deleted");
                            Console.WriteLine("Press any key to continue...");
                            Console.ReadLine();
                        }
                        else
                        {
                            Console.WriteLine("\nItem {0} not found", delID);
                            Console.WriteLine("Press any key to continue...");
                            Console.ReadLine();
                        }

                        break;
                    }

                case 4:  // lList all items in current database if this option is selected
                    {
                        if (icount == 0)
                        {
                            Console.WriteLine("\nThere are no items");
                            Console.WriteLine("Press any key to continue...");
                            Console.ReadLine();
                            break;
                        }

                        Console.WriteLine("\nItem#        ItemID        Description                 Price        QOH        Cost        Value");
                        Console.WriteLine("-----------  ------------  --------------------------  -----------  ---------  ----------  -----------");
                        for (index = 0; index < icount; index++)
                        {
                            // Use the above line format as a guide for printing or displaying the items in your list right under it
                            Console.WriteLine("{0,-12} {1,-13} {2,-27} {3,-12:C} {4,-10} {5,-11:C} {6:C}", index, itemProperty[index].itemIDNo, itemProperty[index].sDescription, itemProperty[index].dblPricePerItem, itemProperty[index].iQuantityOnHand, itemProperty[index].dblOurCostPerItem, itemProperty[index].dblValueOfItem);
                        }

                        break;
                    }

                case 5: // Quit the program if this option is selected
                    {
                        Console.Write("\nAre you sure that you want to quit(y/n)? ");
                        string strresp = Console.ReadLine().ToLower();
                        if (strresp == "y")
                        {
                            return;
                        }
                        else
                        {
                            break;
                        }
                    }

                default:
                    {
                        Console.Write("\nInvalid input, please select an option by entering 1-5\n");
                        Console.WriteLine("Press any key to continue...");
                        Console.ReadLine();
                        break;
                    }
            }
        }
    }
    private static Array GrowQueue(Array oldArray, int newSize)
    {
        // Create larger new array
        int oldSize = oldArray.Length;
        Type elementType = oldArray.GetType().GetElementType();
        Array newArray = Array.CreateInstance(elementType, newSize);

        // Copy the elements from the old array to the new array
        int preserveLength = Math.Min(oldSize, newSize);
        if (preserveLength > 0)
        {
            Array.Copy(oldArray, newArray, preserveLength);
        }
        // Point to new queue
        return newArray;
    }
}
