
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  createRemoteJWKSet,
  importPKCS8,
  jwtVerify,
  SignJWT,
} from "npm:jose";

const FIREBASE_PROJECT_ID = "oneclick-026";
const BUCKET_NAME = "food-seller-verifications";
const MAX_FILE_SIZE = 10 * 1024 * 1024;
const SIGNED_URL_EXPIRY_SECONDS = 300;

const FIREBASE_TOKEN_URL = "https://oauth2.googleapis.com/token";
const FIRESTORE_SCOPE = "https://www.googleapis.com/auth/datastore";

const firebaseKeys = createRemoteJWKSet(
  new URL(
    "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
  ),
);

const allowedTypes: Record<string, string[]> = {
  nic_front: ["application/pdf", "image/jpeg", "image/png"],
  nic_back: ["application/pdf", "image/jpeg", "image/png"],
  br_certificate: ["application/pdf", "image/jpeg", "image/png"],
  declaration_letter: ["application/pdf", "image/jpeg", "image/png"],
  photo_kitchen: ["image/jpeg", "image/png"],
  photo_storage: ["image/jpeg", "image/png"],
  photo_packaging: ["image/jpeg", "image/png"],
  photo_products: ["image/jpeg", "image/png"],
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function getServiceAccount(): {
  client_email: string;
  private_key: string;
  project_id: string;
} {
  const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");

  if (!raw) {
    throw new Error("Firebase service account secret is missing.");
  }

  let account: Record<string, unknown>;

  try {
    let parsed: unknown = JSON.parse(raw);

    // Supports secrets stored as either a JSON object or a JSON-encoded string.
    if (typeof parsed === "string") {
      parsed = JSON.parse(parsed);
    }

    if (!parsed || typeof parsed !== "object") {
      throw new Error("Invalid service account.");
    }

    account = parsed as Record<string, unknown>;
  } catch {
    throw new Error("Firebase service account secret is invalid.");
  }

  const email = account.client_email;
  const privateKey = account.private_key;
  const projectId = account.project_id;

  if (
    typeof email !== "string" ||
    typeof privateKey !== "string" ||
    typeof projectId !== "string" ||
    projectId !== FIREBASE_PROJECT_ID
  ) {
    throw new Error("Firebase service account configuration is invalid.");
  }

  return {
    client_email: email,
    private_key: privateKey,
    project_id: projectId,
  };
}

async function getFirestoreAccessToken(): Promise<string> {
  const account = getServiceAccount();

  const privateKey = await importPKCS8(account.private_key, "RS256");

  const assertion = await new SignJWT({
    scope: FIRESTORE_SCOPE,
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(account.client_email)
    
    .setAudience(FIREBASE_TOKEN_URL)
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(privateKey);

  const response = await fetch(FIREBASE_TOKEN_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  if (!response.ok) {
    console.error("Google OAuth token request failed:", response.status);
    throw new Error("Unable to authorize Firestore access.");
  }

  const result = await response.json();

  if (typeof result.access_token !== "string") {
    throw new Error("Google OAuth response did not contain an access token.");
  }

  return result.access_token;
}

async function getFirestoreDocument(
  collection: string,
  documentId: string,
  accessToken: string,
): Promise<Record<string, unknown> | null> {
  const url =
    `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}` +
    `/databases/(default)/documents/${collection}/${encodeURIComponent(documentId)}`;

  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    console.error(
      "Firestore document request failed:",
      collection,
      response.status,
    );
    throw new Error("Unable to verify account permissions.");
  }

  return await response.json();
}

function firestoreString(
  document: Record<string, unknown>,
  fieldName: string,
): string | null {
  const fields = document.fields as
    | Record<string, Record<string, unknown>>
    | undefined;

  const value = fields?.[fieldName]?.stringValue;

  return typeof value === "string" ? value : null;
}


function firestoreVerificationPath(
  document: Record<string, unknown>,
  fileType: string,
): string | null {
  const fields = document.fields as
    | Record<string, Record<string, unknown>>
    | undefined;

  const verificationFiles = fields?.verificationFiles?.mapValue as
    | { fields?: Record<string, Record<string, unknown>> }
    | undefined;

  const fileFields = verificationFiles?.fields;
  if (!fileFields) return null;

  const directKeyMap: Record<string, string> = {
    nic_front: "nicFront",
    nic_back: "nicBack",
    br_certificate: "businessRegistration",
    declaration_letter: "declarationLetter",
  };

  if (directKeyMap[fileType]) {
    const value = fileFields[directKeyMap[fileType]]?.stringValue;
    return typeof value === "string" ? value : null;
  }

  const photoKeyMap: Record<string, string> = {
    photo_kitchen: "kitchen",
    photo_storage: "storage",
    photo_packaging: "packaging",
    photo_products: "products",
  };

  const photoKey = photoKeyMap[fileType];
  if (photoKey) {
    const businessPhotos = fileFields.businessPhotos?.mapValue as
      | { fields?: Record<string, Record<string, unknown>> }
      | undefined;

    const value = businessPhotos?.fields?.[photoKey]?.stringValue;
    return typeof value === "string" ? value : null;
  }

  return null;
}



async function createAdminSignedUrl(
  supabase: ReturnType<typeof createClient>,
  uid: string,
  path: string,
  sellerUid: string,
): Promise<Response> {
  if (
    !sellerUid ||
    !path ||
    path.length > 1024 ||
    path.includes("\\") ||
    path.includes("..") ||
    path.startsWith("/") ||
    !path.startsWith(`${sellerUid}/`)
  ) {
    return jsonResponse({ error: "Invalid document request." }, 400);
  }

  const accessToken = await getFirestoreAccessToken();

  // Verify the caller's role from Firestore, not from client-supplied data.
  const adminDocument = await getFirestoreDocument(
    "users",
    uid,
    accessToken,
  );

  if (
    !adminDocument ||
    firestoreString(adminDocument, "role") !== "admin"
  ) {
    return jsonResponse({ error: "Admin access required." }, 403);
  }

  // Confirm that this exact path was submitted by this seller.
  const sellerDocument = await getFirestoreDocument(
    "food_sellers",
    sellerUid,
    accessToken,
  );

  if (
    !sellerDocument ||
    firestoreString(sellerDocument, "uid") !== sellerUid
  ) {
    return jsonResponse({ error: "Seller application not found." }, 404);
  }

  const matchingFileTypes = Object.keys(allowedTypes).filter(
    (type) => firestoreVerificationPath(sellerDocument, type) === path,
  );

  if (matchingFileTypes.length !== 1) {
    return jsonResponse(
      { error: "Document is not part of this seller application." },
      403,
    );
  }

  const { data, error } = await supabase.storage
    .from(BUCKET_NAME)
    .createSignedUrl(path, SIGNED_URL_EXPIRY_SECONDS);

  if (error || !data?.signedUrl) {
    console.error("Signed URL creation failed:", error?.message);
    return jsonResponse(
      { error: "Unable to create document preview." },
      500,
    );
  }

  return jsonResponse({
    signedUrl: data.signedUrl,
    expiresIn: SIGNED_URL_EXPIRY_SECONDS,
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed." }, 405);
  }

  try {
    const authorization = req.headers.get("Authorization");
    const token = authorization?.match(/^Bearer (.+)$/i)?.[1];

    if (!token) {
      return jsonResponse({ error: "Please sign in again." }, 401);
    }

    const { payload } = await jwtVerify(token, firebaseKeys, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
    });

    const uid = payload.sub;

    if (!uid) {
      return jsonResponse({ error: "Invalid user token." }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      console.error("Supabase server configuration is missing.");
      return jsonResponse({ error: "Server configuration error." }, 500);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    const contentType = req.headers.get("content-type") ?? "";

    if (contentType.includes("application/json")) {
      const body = await req.json();

      if (body?.action === "signed-url") {
        if (
          typeof body.path !== "string" ||
          typeof body.sellerUid !== "string"
        ) {
          return jsonResponse(
            { error: "A document path and seller UID are required." },
            400,
          );
        }

        return await createAdminSignedUrl(
          supabase,
          uid,
          body.path,
          body.sellerUid,
        );
      }

      return jsonResponse({ error: "Unsupported action." }, 400);
    }

    // Existing seller upload flow.
    const form = await req.formData();
    const file = form.get("file");
    const fileType = form.get("fileType");

    if (!(file instanceof File) || typeof fileType !== "string") {
      return jsonResponse(
        { error: "A file and fileType are required." },
        400,
      );
    }

    if (!Object.hasOwn(allowedTypes, fileType)) {
      return jsonResponse({ error: "Unsupported file type." }, 400);
    }

    if (file.size === 0 || file.size > MAX_FILE_SIZE) {
      return jsonResponse(
        { error: "File must be between 1 byte and 10 MB." },
        400,
      );
    }

    if (!allowedTypes[fileType].includes(file.type)) {
      return jsonResponse(
        { error: "This file format is not allowed." },
        400,
      );
    }

    const extensionByMime: Record<string, string> = {
      "application/pdf": "pdf",
      "image/jpeg": "jpg",
      "image/png": "png",
    };

    const extension = extensionByMime[file.type];

    const path =
      `${uid}/${fileType}_${crypto.randomUUID()}.${extension}`;

    const { error } = await supabase.storage
      .from(BUCKET_NAME)
      .upload(path, file, {
        contentType: file.type,
        upsert: false,
      });

    if (error) {
      console.error("Storage upload failed:", error.message);
      return jsonResponse({ error: "Unable to upload the file." }, 500);
    }

    return jsonResponse({ path });
  } catch (error) {
    console.error("Verification function failed:", error);
    return jsonResponse(
      { error: "Authentication failed or the request could not be completed." },
      401,
    );
  }
});
