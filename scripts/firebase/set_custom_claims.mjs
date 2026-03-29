import { readFile } from 'node:fs/promises';
import process from 'node:process';
import admin from 'firebase-admin';

async function main() {
  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  const claimsFilePath = process.env.FIREBASE_CLAIMS_FILE ?? 'scripts/firebase/custom_claims.users.json';

  if (!serviceAccountPath) {
    throw new Error('Missing FIREBASE_SERVICE_ACCOUNT_JSON env var');
  }

  const serviceAccount = JSON.parse(await readFile(serviceAccountPath, 'utf8'));
  const claimsFile = JSON.parse(await readFile(claimsFilePath, 'utf8'));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  for (const user of claimsFile.users ?? []) {
    if (!user.firebase_uid || !user.claims) {
      throw new Error(`Invalid user entry: ${JSON.stringify(user)}`);
    }

    await admin.auth().setCustomUserClaims(user.firebase_uid, user.claims);
    console.log(`Applied claims to ${user.label ?? user.email ?? user.firebase_uid}`);
  }

  console.log('Done. Users must refresh their Firebase ID token after claims update.');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
