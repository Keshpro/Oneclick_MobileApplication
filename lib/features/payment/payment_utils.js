
const crypto = require("node:crypto");

function md5(value) {
  return crypto
    .createHash("md5")
    .update(String(value), "utf8")
    .digest("hex")
    .toUpperCase();
}

function verifyNotification(data, secret) {
  const {
    merchant_id,
    order_id,
    payhere_amount,
    payhere_currency,
    status_code,
    md5sig,
  } = data;

  if (!md5sig) return false;

  const expected = md5(
    String(merchant_id) +
    String(order_id) +
    String(payhere_amount) +
    String(payhere_currency) +
    String(status_code) +
    md5(secret)
  );

  const received = String(md5sig).toUpperCase();

  if (!/^[A-F0-9]{32}$/.test(received)) {
    return false;
  }

  return crypto.timingSafeEqual(
    Buffer.from(expected, "hex"),
    Buffer.from(received, "hex")
  );
}

module.exports = {verifyNotification};
