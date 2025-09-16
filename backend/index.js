import express from "express";
import dotenv from "dotenv";
import admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import midtransClient from "midtrans-client";
import cors from "cors";

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
        const { token, title, body } = req.body;
        if (!token || !title || !body) {
            return res.status(400).json({ error: "Missing fields" });
        }
        const message = {
            notification: { title, body },
            token,
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
        const { tokens, title, body } = req.body;
        if (!tokens || tokens.length === 0) {
            return res.status(400).json({ error: "No tokens provided" });
        }
        const message = {
            notification: { title, body },
            tokens,
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

app.post("/send-to-role", async (req, res) => {
    try {
        const { role, title, body } = req.body;
        const collectionName = role === "admin" ? "Admin" : "Users";
        const snap = await db.collection(collectionName).where("role", "==", role).get();
        const tokens = [];
        snap.forEach((doc) => {
            const data = doc.data();
            if (data.fcmTokens && Array.isArray(data.fcmTokens)) {
                tokens.push(...data.fcmTokens);
            }
        });
        if (tokens.length === 0) {
            return res.json({ success: false, message: `No tokens found for role ${role}` });
        }
        const message = {
            notification: { title, body },
            tokens,
        };
        const response = await admin.messaging().sendEachForMulticast(message);
        res.json({
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount,
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to send role-based notif" });
    }
});

app.post("/send-all", async (req, res) => {
    try {
        const { title, body } = req.body;
        if (!title || !body) {
            return res.status(400).json({ error: "Missing title or body" });
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
            notification: { title, body },
            tokens,
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

app.post("/create-transaction", async (req, res) => {
    try {
        console.log("Incoming body:", req.body);

        const { amount, customer, product, rentDurationInDays } = req.body;

        if (!amount || !customer || !product || !rentDurationInDays) {
            return res.status(400).json({ error: "Missing amount, customer, product, or rentDurationInDays" });
        }

        const snap = new midtransClient.Snap({
            isProduction: false,
            serverKey: process.env.MIDTRANS_SERVER_KEY,
        });

        const safeUid = (customer?.uid || "guest").substring(0, 10);

        const parameter = {
            transaction_details: {
                order_id: "ORDER-" + safeUid + "-" + Date.now(),
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
                    city: customer?.city || "Jakarta",
                    postal_code: "12345",
                    country_code: "IDN",
                },
                shipping_address: {
                    first_name: customer?.first_name || "Guest",
                    last_name: customer?.last_name || "User",
                    email: customer?.email || "guest@gmail.com",
                    phone: customer?.phone || "08123456789",
                    address: customer?.address || "Jl. Default No.1",
                    city: customer?.city || "Jakarta",
                    postal_code: "12345",
                    country_code: "IDN",
                },
            },
            item_details: [
                {
                    id: product?.id || "Mobil1",
                    price: product?.price || 10000,
                    quantity: rentDurationInDays || 1,
                    name: product?.name || "Mobil",
                    brand: product?.brand || "Automatic",
                    category: product?.category || "SUV",
                    merchant_name: "RentCarApp+",
                    url: "https://rentcarapp.com/mobil"
                },
                {
                    id: "driver",
                    price: req.body.driverCost || 0,
                    quantity: 1,
                    name: "Biaya Supir"
                },
                {
                    id: "insurance",
                    price: req.body.insuranceCost || 0,
                    quantity: 1,
                    name: "Biaya Asuransi"
                },
                {
                    id: "additional",
                    price: req.body.additionalCost || 0,
                    quantity: 1,
                    name: "Biaya Tambahan"
                }
            ].filter(item => item.price > 0)
        };

        const transaction = await snap.createTransaction(parameter);
        console.log("Snap response:", transaction);

        res.json({ token: transaction.token, redirect_url: transaction.redirect_url });
    } catch (err) {
        console.error(err.ApiResponse || err.message);
        res.status(500).json({ error: "Failed to create transaction", detail: err.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
