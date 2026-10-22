
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createRemoteJWKSet, jwtVerify } from "npm:jose";

const FIREBASE_PROJECT_ID = "oneclick-026";
const BUCKET_NAME = "food-seller-verifications";
const MAX_FILE_SIZE = 10 * 1024 * 1024;

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

    // Verify the Firebase ID token before accepting an upload.
    const { payload } = await jwtVerify(token, firebaseKeys, {
      issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
      audience: FIREBASE_PROJECT_ID,
    });

    const uid = payload.sub;

    if (!uid) {
      return jsonResponse({ error: "Invalid user token." }, 401);
    }

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

    // Return a private storage path, never a public URL.
    return jsonResponse({ path });
  } catch (error) {
    console.error("Verification upload request failed:", error);
    return jsonResponse(
      { error: "Authentication failed or the upload request was invalid." },
      401,
    );
  }
});
