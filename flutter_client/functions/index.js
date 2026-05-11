import { initializeApp } from "firebase-admin/app";
import {
  beforeUserCreated,
  beforeUserSignedIn,
} from "firebase-functions/v2/identity";

initializeApp();

function withAuthenticatedRole(event) {
  return {
    ...(event.data?.customClaims ?? {}),
    role: "authenticated",
  };
}

export const beforecreated = beforeUserCreated((event) => {
  return {
    customClaims: withAuthenticatedRole(event),
  };
});

export const beforesignedin = beforeUserSignedIn((event) => {
  return {
    sessionClaims: {
      role: "authenticated",
    },
  };
});
