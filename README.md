# Receipt Bubble

A Flutter project that scans receipts to extract items and split the cost among users

## Motivation
Whether it be out at a restaurant or at the grocery stores, I often find myself having to split the bill somehow. Sometimes, splitting the bill isn't as easy as just splitting it in half. There may be multiple members of the party, or maybe some people want to opt out of paying for certain items in the cart. 

To solve this issue, I created Receipt Bubble.
## Goal of the project
The goal is to be able to take a picture of a receipt and have the app return you a list of items on that receipt. From there, I wanted users to be able to pick and choose what elements of the receipt that they want to pay for.
## Basic User Flow
User 1:

 1. Takes picture of receipt
 2. Take user to receipt screen with the items, tax, total
 3. User either chooses to continue or retake the photo
 4. If they continue, take the user to the split screen with a group code
 5. User 1 shares the group code with other users

Other users:

 1. Enter a group code to access the receipt splitting screen

Once in the splitting screen:

 - Users can choose what items they want to "claim" and their own total will be displayed at the bottom (including the split tax)

## Current Functionality

 - User authentication by email and password ✅
 - Can scan and parse items from a receipt (including tax and total) ✅
 - Can split by item between users ✅
## Future Plans
 - QR codes for group codes
 - Splitting unequal percentages on items
 - Personal history of receipts
