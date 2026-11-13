
const crypto = require("node:crypto");
const querystring = require("node:querystring");

const {
  onCall,
  onRequest,
  HttpsError,
} = require("firebase-functions/v2/https");

const {
  defineSecret,
} = require("firebase-functions/params");

const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");

const logger = require("firebase-functions/logger");

const {
  verifyNotification,
} = require("./payment_utils");

// Firebase Admin must be initialized in functions/index.js.
const db = getFirestore();

const merchantId = defineSecret("PAYHERE_MERCHANT_ID");
const merchantSecret = defineSecret("PAYHERE_MERCHANT_SECRET");

const REGION = "asia-south1";
const CURRENCY = "LKR";
const PROJECT_ID = "oneclick-026";

// Sandbox demonstration price: LKR 2,500.00.
// Replace with trusted doctor-specific pricing before
// supporting variable consultation fees.
const DOCTOR_FEE_MINOR = 250000;

const NOTIFY_URL =
  `https://${REGION}-${PROJECT_ID}` +
  ".cloudfunctions.net/payHereNotify";

const options = {
  region: REGION,
  maxInstances: 10,
  secrets: [merchantId, merchantSecret],
};

function md5Upper(value) {
  return crypto
    .createHash("md5")
    .update(String(value), "utf8")
    .digest("hex")
    .toUpperCase();
}

function generatePaymentHash({
  merchantId: id,
  orderId,
  amount,
  currency,
  secret,
}) {
  return md5Upper(
    String(id) +
    String(orderId) +
    String(amount) +
    String(currency) +
    md5Upper(secret)
  );
}

// PayHere sends form-urlencoded notifications.
function parseNotificationBody(req) {
  const contentType =
    String(req.headers["content-type"] || "")
      .toLowerCase();

  if (
    !contentType.includes(
      "application/x-www-form-urlencoded"
    )
  ) {
    throw new Error("Unsupported content type");
  }

  if (Buffer.isBuffer(req.rawBody)) {
    const parsed = querystring.parse(
      req.rawBody.toString("utf8")
    );
    return parsed;
  }

  if (
    req.body &&
    typeof req.body === "object" &&
    !Buffer.isBuffer(req.body)
  ) {
    return req.body;
  }

  if (typeof req.body === "string") {
    return querystring.parse(req.body);
  }

  throw new Error("Invalid notification body");
}

function stringField(body, field) {
  const value = body[field];

  if (typeof value !== "string") {
    return "";
  }

  return value.trim();
}

// ======================================================
// 1. CREATE PAYHERE WEB PAYMENT
// ======================================================

exports.createPayHerePayment = onCall(
  options,
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Please login before making a payment."
      );
    }

    const data = request.data || {};
    const bookingId = data.bookingId;
    const customer = data.customer;

    if (
      typeof bookingId !== "string" ||
      !bookingId.trim() ||
      bookingId.includes("/") ||
      bookingId.length > 200
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid appointment ID."
      );
    }

    const requiredFields = [
      "firstName",
      "lastName",
      "email",
      "phone",
      "address",
      "city",
    ];

    if (
      !customer ||
      typeof customer !== "object" ||
      requiredFields.some((field) => {
        const value = customer[field];
        return (
          typeof value !== "string" ||
          !value.trim() ||
          value.length > 200
        );
      })
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Complete customer information is required."
      );
    }

    const userId = request.auth.uid;

    const bookingRef = db
      .collection("appointments")
      .doc(bookingId);

    // Deterministic ID prevents creating multiple
    // payment sessions for the same appointment.
    const paymentId = `doctor_${bookingId}`;

    const paymentRef = db
      .collection("payments")
      .doc(paymentId);

    const amountMinor = DOCTOR_FEE_MINOR;
    const amount = (amountMinor / 100).toFixed(2);

    // Transaction prevents concurrent requests from
    // creating conflicting payment records.
    await db.runTransaction(async (tx) => {
      const bookingSnap = await tx.get(bookingRef);
      const paymentSnap = await tx.get(paymentRef);

      if (!bookingSnap.exists) {
        throw new HttpsError(
          "not-found",
          "Appointment not found."
        );
      }

      const booking = bookingSnap.data();

      if (booking.userId !== userId) {
        throw new HttpsError(
          "permission-denied",
          "This appointment does not belong to you."
        );
      }

      if (
        booking.status !== "awaiting_payment" ||
        booking.paymentStatus === "paid" ||
        booking.paymentId
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Appointment is not available for payment."
        );
      }

      // For this Sandbox example, the fee must
      // match the trusted, fixed backend price.
      if (booking.amountMinor !== amountMinor) {
        throw new HttpsError(
          "failed-precondition",
          "Appointment fee does not match the configured price."
        );
      }

      if (paymentSnap.exists) {
        const existing = paymentSnap.data();

        if (
          existing.userId !== userId ||
          existing.bookingId !== bookingId ||
          existing.amountMinor !== amountMinor ||
          existing.orderId !== paymentId ||
          existing.module !== "doctor" ||
          existing.status === "paid"
        ) {
          throw new HttpsError(
            "failed-precondition",
            "This payment cannot be restarted."
          );
        }

        // Reuse the existing order for an unpaid
        // appointment. Do not create another record.
        return;
      }

      tx.create(paymentRef, {
        userId,
        module: "doctor",
        bookingId,
        orderId: paymentId,
        amountMinor,
        amount,
        currency: CURRENCY,
        status: "pending",
        paymentStatus: "unpaid",
        provider: "payhere",
        environment: "sandbox",
        createdAt: FieldValue.serverTimestamp(),
      });
    });

    const id = merchantId.value();
    const secret = merchantSecret.value();

    if (!id || !secret) {
      throw new HttpsError(
        "failed-precondition",
        "PayHere credentials are not configured."
      );
    }

    const hash = generatePaymentHash({
      merchantId: id,
      orderId: paymentId,
      amount,
      currency: CURRENCY,
      secret,
    });

    // Never return the Merchant Secret to Flutter Web.
    return {
      paymentId,
      orderId: paymentId,
      merchantId: id,
      amount,
      currency: CURRENCY,
      hash,
      notifyUrl: NOTIFY_URL,
      sandbox: true,
    };
  }
);

// ======================================================
// 2. PAYHERE SERVER NOTIFICATION
// ======================================================

exports.payHereNotify = onRequest(
  options,
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    let body;

    try {
      body = parseNotificationBody(req);
    } catch (error) {
      logger.warn("Invalid PayHere notification format");
      res.status(400).send("Invalid body");
      return;
    }

    const fields = [
      "merchant_id",
      "order_id",
      "payhere_amount",
      "payhere_currency",
      "status_code",
      "md5sig",
    ];

    if (fields.some((field) => !stringField(body, field))) {
      res.status(400).send("Missing payment fields");
      return;
    }

    const incomingMerchantId =
      stringField(body, "merchant_id");

    const orderId = stringField(body, "order_id");

    const incomingAmount =
      stringField(body, "payhere_amount");

    const incomingCurrency =
      stringField(body, "payhere_currency");

    const statusCode =
      stringField(body, "status_code");

    const gatewayPaymentId =
      stringField(body, "payment_id");

    if (incomingMerchantId !== merchantId.value()) {
      res.status(400).send("Merchant mismatch");
      return;
    }

    // Check PayHere MD5 notification signature.
    const validSignature = verifyNotification(
      body,
      merchantSecret.value()
    );

    if (!validSignature) {
      logger.warn("Invalid PayHere signature");
      res.status(400).send("Invalid signature");
      return;
    }

    if (!orderId || orderId.includes("/")) {
      res.status(400).send("Invalid order");
      return;
    }

    if (statusCode === "2" && !gatewayPaymentId) {
      res.status(400).send("Missing gateway payment ID");
      return;
    }

    const paymentRef = db
      .collection("payments")
      .doc(orderId);

    // Prevent one PayHere transaction ID from being
    // used to confirm multiple OneClick orders.
    const transactionRef = gatewayPaymentId
      ? db.collection("payhere_transactions")
          .doc(gatewayPaymentId)
      : null;

    try {
      await db.runTransaction(async (tx) => {
        const paymentSnap = await tx.get(paymentRef);

        if (!paymentSnap.exists) {
          throw new Error("Payment record not found");
        }

        const payment = paymentSnap.data();

        if (
          payment.orderId !== orderId ||
          payment.provider !== "payhere" ||
          payment.environment !== "sandbox" ||
          payment.module !== "doctor" ||
          payment.amount !== incomingAmount ||
          payment.currency !== incomingCurrency
        ) {
          throw new Error("Payment details mismatch");
        }

        if (
          payment.status === "paid" &&
          payment.providerPaymentId &&
          payment.providerPaymentId !== gatewayPaymentId
        ) {
          throw new Error("Payment already settled by another transaction");
        }

        // A paid record is never downgraded by
        // pending/cancelled/failed callbacks.
        if (payment.status === "paid") {
          return;
        }

        if (statusCode !== "2") {
          tx.update(paymentRef, {
            providerStatusCode: statusCode,
            updatedAt: FieldValue.serverTimestamp(),
          });
          return;
        }

        const bookingRef = db
          .collection("appointments")
          .doc(payment.bookingId);

        const bookingSnap = await tx.get(bookingRef);

        const gatewayTransactionSnap =
          await tx.get(transactionRef);

        if (!bookingSnap.exists) {
          throw new Error("Appointment not found");
        }

        const booking = bookingSnap.data();

        if (
          booking.userId !== payment.userId ||
          booking.amountMinor !== payment.amountMinor ||
          booking.status !== "awaiting_payment" ||
          booking.paymentStatus === "paid" ||
          booking.paymentId
        ) {
          throw new Error("Appointment mismatch");
        }

        if (gatewayTransactionSnap.exists) {
          if (
            gatewayTransactionSnap.data().orderId !== orderId
          ) {
            throw new Error(
              "PayHere transaction already used"
            );
          }
        } else {
          tx.create(transactionRef, {
            orderId,
            paymentId: paymentRef.id,
            bookingId: payment.bookingId,
            createdAt: FieldValue.serverTimestamp(),
          });
        }

        tx.update(paymentRef, {
          status: "paid",
          paymentStatus: "paid",
          providerPaymentId: gatewayPaymentId,
          providerStatusCode: "2",
          paidAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });

        tx.update(bookingRef, {
          status: "confirmed",
          paymentStatus: "paid",
          paymentId: paymentRef.id,
          confirmedAt: FieldValue.serverTimestamp(),
        });
      });

      res.status(200).send("OK");
    } catch (error) {
      logger.error(
        "PayHere notification processing failed",
        error
      );

      res.status(500).send("Processing failed");
    }
  }
);
