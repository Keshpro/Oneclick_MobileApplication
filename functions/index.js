
/**
 * ONE CLICK MOBILE APPLICATION
 *
 * QUICKFIX AUTOMATIC NOTIFICATION SYSTEM
 *
 * Customer creates booking -> Worker notification
 * Worker updates booking -> Customer notification
 *
 * Only QuickFix bookings are processed.
 */

const {setGlobalOptions} = require("firebase-functions/v2");

const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");

const {initializeApp} = require("firebase-admin/app");

const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");

const logger = require("firebase-functions/logger");

// Firebase Admin initialization
initializeApp();

const db = getFirestore();

// Limit function instances for cost control
setGlobalOptions({maxInstances: 10});

// ===========================================
// FUNCTION 1: NEW QUICKFIX BOOKING
// ===========================================

exports.quickfixNewBooking = onDocumentCreated(
  "work_appointments/{appointmentId}",
  async (event) => {
    try {
      const booking = event.data?.data();

      if (!booking) {
        logger.warn("Booking data not found");
        return;
      }

      // Ignore bookings from other categories
      if (booking.serviceType !== "quickfix") {
        return;
      }

      const workerId = booking.workerId;
      const customerId = booking.customerId;
      const appointmentId = event.params.appointmentId;

      if (!workerId || !customerId) {
        logger.warn("Worker ID or Customer ID missing");
        return;
      }

      // Create notification for worker
      await db
        .collection("quickfix_notifications")
        .doc(`booking_${appointmentId}`)
        .create({
          receiverId: workerId,
          senderId: customerId,
          appointmentId: appointmentId,

          title: "New Job Request",

          message:
            "You have received a new QuickFix booking request.",

          type: "new_booking",
          isRead: false,

          createdAt: FieldValue.serverTimestamp(),
        });

      logger.info(
        "QuickFix worker notification created",
        {appointmentId},
      );
    } catch (error) {
      // A duplicate notification means the event was
      // already processed successfully.
      if (error.code === 6 || error.code === "already-exists") {
        logger.info("Booking notification already exists");
        return;
      }

      logger.error("Error creating worker notification", error);
      throw error;
    }
  },
);

// ===========================================
// FUNCTION 2: QUICKFIX BOOKING STATUS UPDATE
// ===========================================

exports.quickfixBookingStatusChanged = onDocumentUpdated(
  "work_appointments/{appointmentId}",
  async (event) => {
    try {
      const before = event.data?.before.data();
      const after = event.data?.after.data();

      if (!before || !after) {
        return;
      }

      // Ignore other categories
      if (after.serviceType !== "quickfix") {
        return;
      }

      // Ignore updates unrelated to status
      if (before.status === after.status) {
        return;
      }

      const customerId = after.customerId;
      const workerId = after.workerId;
      const appointmentId = event.params.appointmentId;

      if (!customerId || !workerId) {
        logger.warn("Missing customer or worker ID");
        return;
      }

      let title = "";
      let message = "";
      let type = "";

      switch (after.status) {
        case "Accepted":
          title = "Booking Accepted";
          message =
            "Your QuickFix booking has been accepted by the worker.";
          type = "booking_accepted";
          break;

        case "Rejected":
          title = "Booking Rejected";
          message =
            "Your QuickFix booking has been rejected by the worker.";
          type = "booking_rejected";
          break;

        case "Completed":
          title = "Service Completed";
          message =
            "Your QuickFix service has been completed.";
          type = "booking_completed";
          break;

        default:
          return;
      }

      // Create notification for customer
      await db
        .collection("quickfix_notifications")
        .doc(`status_${appointmentId}_${after.status}`)
        .create({
          receiverId: customerId,
          senderId: workerId,
          appointmentId: appointmentId,

          title: title,
          message: message,
          type: type,

          isRead: false,
          createdAt: FieldValue.serverTimestamp(),
        });

      logger.info(
        "QuickFix customer notification created",
        {appointmentId, status: after.status},
      );
    } catch (error) {
      if (error.code === 6 || error.code === "already-exists") {
        logger.info("Status notification already exists");
        return;
      }

      logger.error("Error creating customer notification", error);
      throw error;
    }
  },
);
