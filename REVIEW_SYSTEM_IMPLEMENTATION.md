# Doctor Review & Rating System - Implementation Guide

## ✅ Files Created

### Domain Layer
1. `lib/domain/entities/review_entity.dart` - Review entity
2. `lib/domain/repos/review_repo.dart` - Repository interface
3. `lib/domain/use_cases/add_review_use_case.dart` - Add review
4. `lib/domain/use_cases/get_doctor_reviews_use_case.dart` - Get reviews
5. `lib/domain/use_cases/delete_review_use_case.dart` - Delete review

### Data Layer
6. `lib/data/models/review_model.dart` - Firestore model
7. `lib/data/repos/review_repo_impl.dart` - Repository implementation

### UI Components
8. `lib/core/widgets/star_rating.dart` - Reusable star rating widget
9. `lib/features/reviews/add_review_dialog.dart` - Review submission dialog
10. `lib/features/reviews/doctor_reviews_screen.dart` - Reviews list screen

---

## 📋 Manual Steps Required

### Step 1: Register in Dependency Injection

The DI system should auto-register with `@injectable` annotations, but run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 2: Firebase Security Rules

Add these rules to Firestore:

```javascript
// Reviews collection
match /reviews/{reviewId} {
  // Anyone can read reviews
  allow read: if true;
  
  // Only authenticated patients can create reviews
  allow create: if request.auth != null 
    && request.resource.data.patientId == request.auth.uid;
  
  // Only admins can delete reviews
  allow delete: if request.auth != null 
    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
  
  // No updates allowed (create new review instead)
  allow update: if false;
}
```

---

## 🔧 Integration Points

### 1. Patient Side - After Completing Appointment

Add a button to show review dialog after appointment is marked as "Completed".

**Location**: When patient views completed appointments

```dart
// Example integration in patient appointment history
if (appointment.status == 'Completed') {
  ElevatedButton(
    onPressed: () async {
      // Check if already reviewed
      final repo = getIt<ReviewRepo>();
      final hasReviewed = await repo.hasReviewedDoctor(
        patientId, 
        appointment.doctorId
      );
      
      if (hasReviewed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You already reviewed this doctor')),
        );
        return;
      }
      
      showDialog(
        context: context,
        builder: (context) => AddReviewDialog(
          doctorId: appointment.doctorId,
          doctorName: appointment.doctorName,
        ),
      );
    },
    child: Text('Leave a Review'),
  );
}
```

### 2. Doctor Profile - Show Reviews & Rating

**Location**: When patient selects a doctor to book appointment

Add this to the doctor selection/booking screen:

```dart
// Display average rating
FutureBuilder<double>(
  future: getIt<ReviewRepo>().getDoctorAverageRating(doctorId),
  builder: (context, snapshot) {
    final avgRating = snapshot.data ?? 0.0;
    return Row(
      children: [
        StarRating(rating: avgRating.round(), size: 20),
        SizedBox(width: 8),
        Text('${avgRating.toStringAsFixed(1)} / 5.0'),
      ],
    );
  },
);

// View all reviews button
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorReviewsScreen(
          doctorId: doctorId,
          doctorName: doctorName,
        ),
      ),
    );
  },
  child: Text('View Reviews'),
);
```

### 3. Admin Panel - Manage Reviews

Add a reviews management section in admin interface:

```dart
ListTile(
  leading: Icon(Icons.rate_review),
  title: Text('Manage Reviews'),
  onTap: () {
    // Show list of all reviews with delete option
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorReviewsScreen(
          doctorId: doctorId,
          doctorName: doctorName,
          isAdmin: true, // Enables delete buttons
        ),
      ),
    );
  },
);
```

---

## 🎨 Features

### Patient Features
- ✅ Can only review after completing at least one appointment
- ✅ Can submit only one review per doctor
- ✅ Must provide 1-5 star rating
- ✅ Must write a comment (max 500 characters)
- ✅ Can see all reviews for a doctor before booking

### Admin Features
- ✅ Can view all reviews
- ✅ Can delete any review (for inappropriate content)
- ✅ Red delete button appears next to each review

### System Features
- ✅ Real-time updates (uses Firestore streams)
- ✅ Automatic average rating calculation
- ✅ Shows total number of reviews
- ✅ Reviews sorted by date (newest first)
- ✅ Beautiful UI with star ratings

---

## 📊 Database Structure

### Firestore Collection: `reviews`

```
reviews/
  ├── {reviewId}/
  │   ├── doctorId: string
  │   ├── patientId: string
  │   ├── patientName: string
  │   ├── patientImage: string? (optional)
  │   ├── rating: number (1-5)
  │   ├── comment: string
  │   └── createdAt: timestamp
```

---

## 🧪 Testing Checklist

- [ ] Patient can submit review after completing appointment
- [ ] Patient cannot review same doctor twice
- [ ] Patient cannot review without completed appointment
- [ ] Reviews display correctly on doctor profile
- [ ] Average rating calculates correctly
- [ ] Admin can delete reviews
- [ ] Non-admin cannot delete reviews
- [ ] Empty state shows when no reviews
- [ ] Real-time updates work (new reviews appear instantly)

---

## 🚀 Next Steps

1. Run `flutter pub run build_runner build`
2. Add Firebase security rules
3. Integrate review button in patient appointment history
4. Add reviews section to doctor booking screen
5. Add reviews management to admin panel
6. Test thoroughly!

---

## 📝 Example Usage Locations

### Where to Show "Leave Review" Button:
- Patient's completed appointments list
- Patient's appointment details after completion
- Notification after appointment is marked complete

### Where to Show Reviews:
- Doctor selection screen (when booking)
- Doctor profile page
- Admin dashboard for moderation

### Where to Show Average Rating:
- Doctor cards in booking interface
- Doctor list/search results
- Doctor profile header
