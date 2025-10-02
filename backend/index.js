import express from "express";
import dotenv from "dotenv";
import admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import midtransClient from "midtrans-client";
import cors from "cors";
import { refreshToken } from "firebase-admin/app";

dotenv.config();

const privateKey = process.env.FIREBASE_PRIVATE_KEY
    ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n")
    : undefined;

admin.initializeApp({
    credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey,
    }),
});

const db = getFirestore();
const app = express();
app.use(express.json({ limit: '5mb' }));
app.use(cors());

app.get("/", (req, res) => {
    res.send("Backend aktif");
});

app.get("/health", (req, res) => {
    res.status(200).send("ok");
});

app.post("/send-notification", async (req, res) => {
    try {
        const { token, title, body, data } = req.body;
        if (!token || !title || !body) {
            return res.status(400).json({ error: "Missing token, data, title or body" });
        }
        const message = {
            token,
            data: {
                ...data,
                title,
                body,
            },
        };
        await admin.messaging().send(message);
        res.json({ success: true, message: "Notification sent!" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to send notification" });
    }
});

app.post("/send-multi", async (req, res) => {
    try {
        const { tokens, title, body, data } = req.body;
        if (!tokens || !title || !body) {
            return res.status(400).json({ error: "Missing token, data, title or body" });
        }
        const message = {
            tokens,
            data: {
                ...data,
                title,
                body,
            },
        };
        const response = await admin.messaging().sendEachForMulticast(message);
        res.json({
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount,
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to send multicast" });
    }
});

app.post("/send-to-roles", async (req, res) => {
    try {
        const { roles, title, body, data } = req.body;
        if (!roles || !title || !body || !Array.isArray(roles) || roles.length === 0) {
            return res.status(400).json({ error: "Missing roles, title or body" });
        }

        const allTokens = new Set();

        const promises = roles.map(async (role) => {
            const collectionName = role === "admin" ? "Admin" : "Users";
            const snap = await db.collection(collectionName).where("role", "==", role).get();
            snap.forEach((doc) => {
                const data = doc.data();
                if (data.fcmTokens && Array.isArray(data.fcmTokens)) {
                    data.fcmTokens.forEach(token => allTokens.add(token));
                }
            });
        });

        await Promise.all(promises);

        const uniqueTokens = Array.from(allTokens);

        if (uniqueTokens.length === 0) {
            return res.json({ success: false, message: "No tokens found for the given roles" });
        }

        const message = {
            tokens: uniqueTokens,
            data: {
                ...data,
                title,
                body,
            },
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        res.json({
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount,
        });

    } catch (err) {
        console.error("Error in send-to-roles:", err);
        res.status(500).json({ error: "Failed to send role-based notifications" });
    }
});

app.post("/send-all", async (req, res) => {
    try {
        const { title, body, data } = req.body;
        if (!title || !body) {
            return res.status(400).json({ error: "Missing data, title or body" });
        }
        const usersSnap = await db.collection("Users").get();
        const adminsSnap = await db.collection("Admin").get();
        let tokens = [];
        usersSnap.forEach(doc => {
            const data = doc.data();
            if (data.fcmTokens && Array.isArray(data.fcmTokens)) {
                tokens.push(...data.fcmTokens);
            }
        });
        adminsSnap.forEach(doc => {
            const data = doc.data();
            if (data.fcmTokens && Array.isArray(data.fcmTokens)) {
                tokens.push(...data.fcmTokens);
            }
        });
        if (tokens.length === 0) {
            return res.json({ success: false, message: "No tokens found in Users/Admin" });
        }
        const message = {
            tokens,
            data: {
                ...data,
                title,
                body,
            },
        };
        const response = await admin.messaging().sendEachForMulticast(message);
        res.json({
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount,
            totalTokens: tokens.length,
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to send broadcast" });
    }
});

app.post("/run-cleanup-orders", async (req, res) => {
    const secretKey = req.headers["x-cleanup-secret"];
    if (secretKey !== process.env.CLEANUP_SECRET_KEY) {
        console.warn("Upaya pembersihan order tanpa otorisasi.");
        return res.status(401).send("Unauthorized");
    }

    console.log("Memulai proses pembersihan order anomali...");

    try {
        const db = getFirestore();
        const query = db.collection("Orders")
            .where("deletedByCustomer", "==", true)
            .where("deletedBySeller", "==", true);
        const snapshot = await query.get();

        if (snapshot.empty) {
            console.log("Tidak ada order anomali yang perlu dibersihkan.");
            return res.status(200).send("No orphaned orders to clean up.");
        }

        const batch = db.batch();
        snapshot.docs.forEach(doc => {
            console.log(`Menjadwalkan penghapusan untuk order anomali: ${doc.id}`);
            batch.delete(doc.ref);
        });

        await batch.commit();

        const message = `Pembersihan selesai. ${snapshot.size} order anomali telah dihapus.`;
        console.log(message);
        return res.status(200).send(message);

    } catch (error) {
        console.error("Error saat membersihkan order anomali:", error);
        return res.status(500).send("Internal Server Error during cleanup.");
    }
});

app.post("/create-transaction", async (req, res) => {
    try {
        console.log("Incoming body:", req.body);

        const { amount, customer, product, rentDurationInDays, driverCostPerDay, insuranceCost, additionalCost } = req.body;

        if (!amount || !customer || !product) {
            return res.status(400).json({ error: "Missing amount, customer, or product" });
        }

        const snap = new midtransClient.Snap({
            isProduction: false,
            serverKey: process.env.MIDTRANS_SERVER_KEY,
        });

        const safeUid = (customer?.uid || "guest").substring(0, 5);
        const orderId = "ORDER-" + safeUid + "-" + new Date().getTime();

        const itemDetails = [
            {
                id: product?.id || "Mobil1",
                price: product?.price || 10000,
                quantity: rentDurationInDays || 1,
                name: product?.name || "Mobil",
                brand: product?.brand || "Honda",
                category: product?.category || "Mobil",
                merchant_name: "RentCarApp+",
                url: "https://rentcarapp.com/mobil"
            },
            {
                id: "insurance",
                price: insuranceCost || 0,
                quantity: 1,
                name: "Biaya Asuransi"
            },
            {
                id: "additional",
                price: additionalCost || 0,
                quantity: 1,
                name: "Biaya Tambahan"
            }
        ];

        if (driverCostPerDay && driverCostPerDay > 0) {
            itemDetails.push({
                id: "driver",
                price: driverCostPerDay,
                quantity: rentDurationInDays || 1,
                name: "Biaya Driver"
            });
        }

        const parameter = {
            transaction_details: {
                order_id: orderId,
                gross_amount: amount,
            },
            customer_details: {
                first_name: customer?.first_name || "Guest",
                last_name: customer?.last_name || "User",
                email: customer?.email || "guest@gmail.com",
                phone: customer?.phone || "08123456789",
                billing_address: {
                    first_name: customer?.first_name || "Guest",
                    last_name: customer?.last_name || "User",
                    email: customer?.email || "guest@gmail.com",
                    phone: customer?.phone || "08123456789",
                    address: customer?.address || "Jl. Default No.1",
                    postal_code: "12345",
                    country_code: "IDN",
                },
                shipping_address: {
                    first_name: customer?.first_name || "Guest",
                    last_name: customer?.last_name || "User",
                    email: customer?.email || "guest@gmail.com",
                    phone: customer?.phone || "08123456789",
                    address: customer?.address || "Jl. Default No.1",
                    postal_code: "12345",
                    country_code: "IDN",
                },
            },
            item_details: itemDetails.filter(item => item.price > 0),
            expiry: {
                unit: "minute",
                duration: 15
            },
        };

        const transaction = await snap.createTransaction(parameter);
        console.log("Snap response:", transaction);

        res.json({ token: transaction.token, redirect_url: transaction.redirect_url, order_id: orderId });
    } catch (err) {
        console.error(err.ApiResponse || err.message);
        res.status(500).json({ error: "Failed to create transaction", detail: err.message });
    }
});

app.post("/cancel-transaction", async (req, res) => {
    try {
        const { order_id } = req.body;
        if (!order_id) {
            return res.status(400).json({ error: "Missing order_id" });
        }

        const snap = new midtransClient.Snap({
            isProduction: false,
            serverKey: process.env.MIDTRANS_SERVER_KEY,
        });

        const response = await snap.transaction.cancel(order_id);
        console.log(`Transaksi ${order_id} berhasil dibatalkan di Midtrans.`, response);

        res.status(200).json({ status: "ok", message: "Transaction cancelled", detail: response });

    } catch (err) {
        console.error(`Gagal membatalkan transaksi: ${err.ApiResponse?.status_message || err.message}`);
        res.status(500).json({ error: "Failed to cancel transaction", detail: err.message });
    }
});

app.post("/midtrans-notification", async (req, res) => {
    try {
        const snap = new midtransClient.Snap({
            isProduction: false,
            serverKey: process.env.MIDTRANS_SERVER_KEY,
            clientKey: process.env.MIDTRANS_CLIENT_KEY,
        });

        const statusResponse = await snap.transaction.notification(req.body);
        const orderId = statusResponse.order_id;
        const transactionStatus = statusResponse.transaction_status;
        const fraudStatus = statusResponse.fraud_status;
        const paymentType = statusResponse.payment_type;

        console.log(
            `Webhook diterima. Order ID: ${orderId}, Status: ${transactionStatus}, Tipe Pembayaran: ${paymentType}`
        );

        const ordersRef = db.collection("Orders");
        const q = ordersRef.where("resi", "==", orderId).limit(1);
        const snapshot = await q.get();

        if (snapshot.empty) {
            console.log(`Order dengan resi ${orderId} tidak ditemukan.`);
            return res.status(404).json({ message: "Order not found" });
        }

        const orderDoc = snapshot.docs[0];
        let appPaymentStatus;

        if (transactionStatus == "capture" || transactionStatus == "settlement") {
            if (fraudStatus == "accept") {
                appPaymentStatus = "Sudah Dibayar";
            } else {
                appPaymentStatus = "Pembayaran Dicurigai";
            }
        } else if (transactionStatus == "pending") {
            appPaymentStatus = "Menunggu Pembayaran";
        } else if (transactionStatus == 'cancel' ||
            transactionStatus == 'deny' ||
            transactionStatus == 'expire') {
            appPaymentStatus = 'Gagal';
        }

        const formatPaymentType = (type) => {
            if (!type) return 'Lainnya';
            return type.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        };
        const friendlyPaymentMethod = formatPaymentType(paymentType);

        await orderDoc.ref.update({
            paymentMethod: friendlyPaymentMethod,
            paymentStatus: appPaymentStatus,
        });

        console.log(`Order ${orderId} berhasil diupdate. Status: ${appPaymentStatus}, Metode: ${friendlyPaymentMethod}`);

        res.status(200).json({ status: "ok", message: "Notification processed" });
    } catch (error) {
        console.error("Error memproses webhook Midtrans:", error.message);
        res.status(500).json({ message: "Internal Server Error" });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
