import { GoogleAuth } from 'google-auth-library';
import { config } from '../config.js';

const ANDROID_PUBLISHER_SCOPE =
  'https://www.googleapis.com/auth/androidpublisher';

function parseServiceAccount(rawValue) {
  if (!rawValue) return null;

  const trimmed = rawValue.trim();
  if (!trimmed) return null;

  try {
    if (trimmed.startsWith('{')) {
      return JSON.parse(trimmed);
    }

    const decoded = Buffer.from(trimmed, 'base64').toString('utf8');
    return JSON.parse(decoded);
  } catch {
    return null;
  }
}

async function getAccessToken(serviceAccountJson) {
  const auth = new GoogleAuth({
    credentials: serviceAccountJson,
    scopes: [ANDROID_PUBLISHER_SCOPE],
  });

  const client = await auth.getClient();
  const tokenResponse = await client.getAccessToken();
  const token = tokenResponse?.token;

  return token || null;
}

export async function verifyGooglePlayPurchase({
  packageName,
  productId,
  purchaseToken,
}) {
  if (!packageName || !productId || !purchaseToken) {
    return { valid: false, reason: 'missing_fields' };
  }

  if (config.playPackageName && packageName !== config.playPackageName) {
    return {
      valid: false,
      reason: 'package_name_mismatch',
    };
  }

  const serviceAccount = parseServiceAccount(config.playServiceAccountJson);
  if (!serviceAccount) {
    return {
      valid: false,
      reason: 'missing_or_invalid_service_account',
    };
  }

  const token = await getAccessToken(serviceAccount);
  if (!token) {
    return {
      valid: false,
      reason: 'oauth_token_failed',
    };
  }

  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
    `${encodeURIComponent(packageName)}/purchases/products/` +
    `${encodeURIComponent(productId)}/tokens/${encodeURIComponent(purchaseToken)}`;

  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (!response.ok) {
      const errorBody = await response.text();
      return {
        valid: false,
        reason: 'google_api_error',
        status: response.status,
        details: errorBody,
      };
    }

    const data = await response.json();

    const purchaseState = data.purchaseState;
    const acknowledgementState = data.acknowledgementState;
    const consumedState = data.consumptionState;
    const purchaseTimeMillis = data.purchaseTimeMillis;
    const orderId = data.orderId;
    const purchaseType = data.purchaseType;
    const regionCode = data.regionCode;

    if (purchaseState !== 0) {
      return {
        valid: false,
        reason: 'purchase_not_completed',
        purchaseState,
        acknowledgementState,
        consumedState,
      };
    }

    return {
      valid: true,
      reason: 'verified',
      purchaseState,
      acknowledgementState,
      consumedState,
      purchaseTimeMillis,
      orderId,
      purchaseType,
      regionCode,
      productId,
      packageName,
    };
  } catch (error) {
    return {
      valid: false,
      reason: 'network_or_runtime_error',
      details: error instanceof Error ? error.message : String(error),
    };
  }
}
