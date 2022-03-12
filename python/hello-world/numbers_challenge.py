print("Todays Date?")
date = input()

print("Breakfast calories?")
breakfast = int(input())

print("Lunch calories?")
lunch = int(input())

print("Dinner calories?")
dinner = int(input())

print("Snack calories?")
snack = int(input())

sum = breakfast + lunch + dinner + snack

print("Calorie content for " + date + ": " + str(sum))
