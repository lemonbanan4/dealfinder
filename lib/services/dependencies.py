import os

import firebase_admin
from firebase_admin import app_check, credentials
from fastapi import Depends, HTTPException, Request, status

# --- Firebase Admin SDK Initialization ---
# Initialize only once.
try:
    # GOOGLE_APPLICATION_CREDENTIALS will be used if set,
    # otherwise Application Default Credentials (ADC) are used on Cloud Run.
    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if cred_path:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    else:
        # This will work automatically in Cloud Run
        firebase_admin.initialize_app()
except ValueError:
    # App is already initialized, ignore.
    pass

async def verify_app_check(request: Request):
    """A FastAPI dependency that verifies the Firebase App Check token."""
    app_check_token = request.headers.get("X-Firebase-AppCheck")
    if not app_check_token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="App Check token not provided.")
    try:
        await app_check.verify_token(app_check_token)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=f"Invalid App Check token: {e}")