import { config } from '../config.js';

const APPLE_VERIFY_PROD = 'https://buy.itunes.apple.com/verifyReceipt';
const APPLE_VERIFY_SANDBOX = 'https://sandbox.itunes.apple.com/verifyReceipt';

async function callVerifyReceipt(endpoint, payload) {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    return {
      ok: false,
      error: 'apple_http_error',
      statusCode: response.status,
      body: await response.text(),
    };
  }

  const data = await response.json();
  return {
    ok: true,
    data,
  };
}

function flattenReceiptItems(data) {
  const latest = Array.isArray(data?.latest_receipt_info)
    ? data.latest_receipt_info
    : [];
  const inApp = Array.isArray(data?.receipt?.in_app) ? data.receipt.in_app : [];

  return [...latest, ...inApp];
}

function isExpired(item) {
  if (!item?.expires_date_ms) return false;

  const expiresAt = Number(item.expires_date_ms);
  if (Number.isNaN(expiresAt)) return false;

  return Date.now() > expiresAt;
}

function findMatchingItem(items, { productId, transactionId }) {
  return items.find((item) => {
    const productMatches = productId ? item.product_id === productId : true;
    const transactionMatches = transactionId
      ? item.transaction_id === transactionId ||
        item.original_transaction_id === transactionId
      : true;

    return productMatches && transactionMatches;
  });
}

export async function verifyAppStoreReceipt({
  receiptData,
  productId,
  transactionId,
}) {
  if (!receiptData || (!productId && !transactionId)) {
    return { valid: false, reason: 'missing_fields' };
  }

  try {
    const payload = {
      'receipt-data': receiptData,
      password: config.appleSharedSecret || undefined,
      'exclude-old-transactions': true,
    };

    let source = 'production';
    let verifyResult = await callVerifyReceipt(APPLE_VERIFY_PROD, payload);

    if (!verifyResult.ok) {
      return {
        valid: false,
        reason: verifyResult.error,
        statusCode: verifyResult.statusCode,
        details: verifyResult.body,
      };
    }

    if (verifyResult.data?.status === 21007) {
      source = 'sandbox';
      verifyResult = await callVerifyReceipt(APPLE_VERIFY_SANDBOX, payload);
      if (!verifyResult.ok) {
        return {
          valid: false,
          reason: verifyResult.error,
          statusCode: verifyResult.statusCode,
          details: verifyResult.body,
        };
      }
    }

    const status = verifyResult.data?.status;
    if (status !== 0) {
      return {
        valid: false,
        reason: 'apple_status_not_ok',
        appleStatus: status,
        environment: source,
      };
    }

    const items = flattenReceiptItems(verifyResult.data);
    if (items.length === 0) {
      return {
        valid: false,
        reason: 'empty_receipt_items',
        environment: source,
      };
    }

    const matched = findMatchingItem(items, { productId, transactionId });
    if (!matched) {
      return {
        valid: false,
        reason: 'product_or_transaction_not_found',
        environment: source,
      };
    }

    if (matched.cancellation_date) {
      return {
        valid: false,
        reason: 'receipt_cancelled',
        cancellationDate: matched.cancellation_date,
        environment: source,
      };
    }

    if (isExpired(matched)) {
      return {
        valid: false,
        reason: 'subscription_expired',
        expiresDateMs: matched.expires_date_ms,
        environment: source,
      };
    }

    return {
      valid: true,
      reason: 'verified',
      environment: source,
      productId: matched.product_id,
      transactionId: matched.transaction_id,
      originalTransactionId: matched.original_transaction_id,
      purchaseDateMs: matched.purchase_date_ms,
      expiresDateMs: matched.expires_date_ms,
    };
  } catch (error) {
    return {
      valid: false,
      reason: 'network_or_runtime_error',
      details: error instanceof Error ? error.message : String(error),
    };
  }
}
