
const crypto = require("node:crypto");

// Generate uppercase MD5 hash
function md5Upper(value) {
  return crypto
    .createHash("md5")
    .update(String(value), "utf8")
    .digest("hex")
    .toUpperCase();
}

// Generate PayHere checkout hash
function generatePaymentHash({
  merchantId,
  orderId,
  amount,
  currency,
  merchantSecret,
}) {
  const secretHash = md5Upper(merchantSecret);

  return md5Upper(
    merchantId +
    orderId +
    amount +
    currency +
    secretHash
  );
}

// Verify PayHere payment notification signature
function verifyPaymentNotification({
  merchantId,
  orderId,
  amount,
  currency,
  statusCode,
  md5sig,
  merchantSecret,
}) {
  if (!md5sig) return false;

  const secretHash = md5Upper(merchantSecret);

  const expectedSignature = md5Upper(
    merchantId +
    orderId +
    amount +
    currency +
    statusCode +
    secretHash
  );

  const received = Buffer.from(
    String(md5sig).toUpperCase(),
    "utf8"
  );

  const expected = Buffer.from(
    expectedSignature,
    "utf8"
  );

  if (received.length !== expected.length) {
    return false;
  }

  return crypto.timingSafeEqual(received, expected);
}

module.exports = {
  generatePaymentHash,
  verifyPaymentNotification,
};
