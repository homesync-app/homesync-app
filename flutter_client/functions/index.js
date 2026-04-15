import { initializeApp } from "firebase-admin/app";
import {
  beforeUserCreated,
  beforeUserSignedIn,
} from "firebase-functions/v2/identity";

initializeApp();

export const beforecreated = beforeUserCreated((event) => {
  return {
    customClaims: {
      role: "authenticated",
    },
  };
});

export const beforesignedin = beforeUserSignedIn((event) => {
  return {
    customClaims: {
      role: "authenticated",
    },
  };
});
