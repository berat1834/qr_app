import express from 'express';
import { z } from 'zod';
import { config } from './config.js';
import { verifyGooglePlayPurchase } from './providers/googlePlay.js';
import { verifyAppStoreReceipt } from './providers/appStore.js';
import {
  createGlobalRateLimiter,
  createVerificationRateLimiter,
  healthCheck,
} from './rateLimiter.js';

const app = express();
app.use(express.json({ limit: '1mb' }));

// Global rate limiter
app.use(createGlobalRateLimiter());

// Health check endpoint (rate limiting exempt)
app.get('/health', healthCheck);
app.get('/ping', healthCheck);

const googleSchema = z.object({
  packageName: z.string().min(1),
  productId: z.string().min(1),
  purchaseToken: z.string().min(1),
  userId: z.string().optional(),
});

const appleSchema = z.object({
  receiptData: z.string().min(1),
  productId: z.string().optional(),
  transactionId: z.string().optional(),
  userId: z.string().optional(),
}).refine((data) => Boolean(data.productId || data.transactionId), {
  message: 'productId veya transactionId gerekli',
});

// Verification rate limiter (IP + package_name kombinu başına)
const verifyRateLimiter = createVerificationRateLimiter();

app.post('/verify/google-play', verifyRateLimiter, async (req, res) => {
  const parsed = googleSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      ok: false,
      error: 'invalid_payload',
      details: parsed.error.flatten(),
    });
  }

  const result = await verifyGooglePlayPurchase(parsed.data);
  return res.status(result.valid ? 200 : 402).json({
    ok: result.valid,
    provider: 'google_play',
    result,
  });
});

app.post('/verify/app-store', verifyRateLimiter, async (req, res) => {
  const parsed = appleSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      ok: false,
      error: 'invalid_payload',
      details: parsed.error.flatten(),
    });
  }

  const result = await verifyAppStoreReceipt(parsed.data);
  return res.status(result.valid ? 200 : 402).json({
    ok: result.valid,
    provider: 'app_store',
    result,
  });
});

app.listen(config.port, () => {
  console.log(`receipt-verifier listening on :${config.port}`);
});
