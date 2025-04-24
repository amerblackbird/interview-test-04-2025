# Tasks

## ❓ Why Backend Update Was Required

To determine whether a user has already submitted a review for a specific movie, we need to identify the user uniquely on the client side. This requires access to the authenticated `userId`.

However, the existing login API did not return the user's ID, which made it impossible to perform the required check on the client without additional backend calls or changes.

To solve this:

- I updated the **login API** to include the `userId` in the response. 
  This allows the mobile app to store the user’s ID after login and use it in API requests for review validation.
- Alternatively, a **dedicated user profile API** could have been introduced to fetch the current user's details (including `userId`), but updating the login response is the simplest and most efficient solution for this use case.

This change ensures:
- The frontend can reliably check if the user has already reviewed a movie.
- There’s no risk of duplicate reviews per user.
- A clean and secure user experience without additional requests on app startup.


### Updates

```php
return response()->json([
    'token' => $user->api_token,
    'id' => $user->id, // Add user Id to check if user reviewed movie before.
]);
```

## 📱 Mobile App Changes

### 📌 Route Update

Added a new route to `getPages` in the app’s `AppPages` configuration:

```dart
GetPage(
  name: Routes.submitReview,
  page: () => SubmitReviewPage(),
)
```

### ✏️ Updated: `movie/show.dart`

Enhanced the **Movie Detail Page** (`movie/show.dart`) to observe reviews and determine if the logged-in user has already reviewed the movie.

**What Was Added:**
- On page load, fetches the list of reviews for the current movie.
- Checks if the current `userId` exists in the review list.
- Conditionally shows/hides the **Submit Review** button based on whether the user has already reviewed the movie.

**Behavior:**
- ✅ If user has not reviewed → Show "Write a Review" button → Navigates to `SubmitReviewPage`.
- 🚫 If user already reviewed → Button is hidden or replaced with a "You already reviewed this movie" message.

**State Management:**
- Used `Obx` or similar observable via `GetX` to track whether the user has already reviewed.
- The check is reactive and updates the UI accordingly.

**Why This Change Matters:**
- Improves user experience by avoiding unnecessary navigation.
- Prevents multiple submissions from the UI level.
- Keeps UI logic close to where it's used, making the code easier to follow.


### 📄 New File: `submit_review.dart`

Added a new file at:

This file contains the implementation for `SubmitReviewPage`, the screen that allows users to submit a single review per movie.

**Key Features:**

- Text field for the **review message**.
- Rating input (e.g., using stars or a dropdown from 1 to 5).
- Submit button with loading indicator.
- Disables form if the user has already submitted a review.
