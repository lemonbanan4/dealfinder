from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore, messaging, auth

# Initialize the Firebase Admin SDK
initialize_app()

@https_fn.on_call(region="europe-north1")
def send_price_alert(req: https_fn.CallableRequest) -> any:
    """
    A callable HTTP function that sends a push notification to a specific user.
    Expected payload: {"user_id": "123...", "title": "Price Drop!", "body": "..."}
    """
    data = req.data
    user_id = data.get("user_id")
    title = data.get("title", "Price Drop Alert! 🎉")
    body = data.get("body", "A product you are watching just dropped in price.")
    product_url = data.get("product_url", "alerts_page")

    if not user_id:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="The 'user_id' parameter is required."
        )

    db = firestore.client()
    user_ref = db.collection("users").document(user_id)
    user_doc = user_ref.get()

    if not user_doc.exists:
        return {"success": False, "error": "User not found."}

    user_data = user_doc.to_dict()
    tokens = user_data.get("fcmTokens", [])

    if not tokens:
        return {"success": False, "message": "No FCM tokens found for this user."}

    # Construct the multicast message for all of the user's devices
    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data={"product_url": str(product_url)},
        android=messaging.AndroidConfig(
            notification=messaging.AndroidNotification(
                sound="notification_sound",
                channel_id="dealfinder_price_alerts_v2"
            )
        ),
        apns=messaging.APNSConfig(
            payload=messaging.APNSPayload(
                aps=messaging.Aps(sound="notification_sound.wav")
            )
        ),
        tokens=tokens,
    )

    # Send the message
    response = messaging.send_each_multicast(message)
    
    # Clean up any tokens that failed (e.g., user uninstalled the app)
    if response.failure_count > 0:
        failed_tokens = [tokens[i] for i, resp in enumerate(response.responses) if not resp.success]
        # Remove the invalid tokens from Firestore
        user_ref.update({"fcmTokens": firestore.ArrayRemove(failed_tokens)})

    return {"success": True, "sent_count": response.success_count, "failed_count": response.failure_count}

@https_fn.on_call(region="europe-north1")
def delete_account(req: https_fn.CallableRequest) -> any:
    """
    Deletes the authenticated user's Firestore data and their Firebase Auth account.
    """
    # 1. Ensure the user is actually logged in and making the request
    if req.auth is None or not req.auth.uid:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="User must be authenticated to delete their account."
        )

    uid = req.auth.uid
    db = firestore.client()

    # 2. Delete the user's alert configs (subcollections must be deleted manually)
    configs_ref = db.collection("users").document(uid).collection("alert_configs")
    for doc in configs_ref.stream():
        doc.reference.delete()
        
    # 3. Delete the user's main document
    db.collection("users").document(uid).delete()
    
    # 4. Delete the user from Firebase Auth
    auth.delete_user(uid)

    print(f"Successfully deleted account and data for UID: {uid}")
    return {"success": True}