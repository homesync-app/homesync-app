"use strict";

const { applicationDefault, initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

initializeApp({
  credential: applicationDefault(),
  projectId: process.env.GCLOUD_PROJECT || "homesync-prod-r7-123",
});

async function setRoleCustomClaim() {
  let nextPageToken;

  do {
    const listUsersResult = await getAuth().listUsers(1000, nextPageToken);
    nextPageToken = listUsersResult.pageToken;

    await Promise.all(
      listUsersResult.users.map(async (userRecord) => {
        try {
          await getAuth().setCustomUserClaims(userRecord.uid, {
            role: "authenticated",
          });
          console.log(`Set role claim for ${userRecord.uid}`);
        } catch (error) {
          console.error(
            `Failed to set custom role for user ${userRecord.uid}:`,
            error
          );
        }
      })
    );
  } while (nextPageToken);
}

setRoleCustomClaim().then(() => {
  console.log("Done setting role claims for all users");
  process.exit(0);
});
