# CovidLab API Reference Document

## Endpoint List

- /sign-in
- /update-user

### /sign-in

Signing in always happen through Firebase Console. The user signs in to the Firebase first, then we verify using the token provided.

Sign-in process:
1. Verify auth token
2. If verified successfully;
    - Create the user if not exists (check with Firebase UID)
    - Get the user if exists
3. Prepare output format and return

Input Format
```json
{
    "token":"abc123"
}
```

Output Formats
```json
{
    "success": true,
    "details": {
        "user": {
            "first_name": "Oguzhan",
            "last_name": "Akan",
            "birth_date": "8-15-1995",
            ...
        }
    }
}

```json
{
    "success": false,
    "details": {
        "message": "something went wrong."
    }
}
```


### /update-user

Update user happens at user creation but the user can update their information at any time.

Update user process:
1. Get the user using Firebase UID. If there isn't such user, the request is invalid. Return JSONResponse with status code 422 (Unprocessable entity)
2. Update user with provided fields
3. Return a success message.

Input Format
```json
{
    "uid":"12345678",
    "update_fields": {
        "first_name": "Oguz",
        "birth_date": "1-1-2000",
        ...
    }
}
```

Output Formats
```json
{
    "success": true,
    "details": {
        "message": "User information updated successfully."
    }
}
```

```json
{
    "success": false,
    "details": {
        "message": "Something went wrong."
    }
}
```