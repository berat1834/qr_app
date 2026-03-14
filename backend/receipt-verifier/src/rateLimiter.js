import rateLimit from 'express-rate-limit';

// Verification endpoints için rate limiter
// IP + package_name kombinasyonuna göre limit
export function createVerificationRateLimiter() {
  return rateLimit({
    windowMs: 15 * 60 * 1000, // 15 dakika
    max: 100, // Her IP+package_name kombinasyonu için max 100 request
    message: 'Çok fazla doğrulama isteği. Lütfen 15 dakika sonra tekrar deneyin.',
    standardHeaders: true, // RateLimit-* headers'ı döndür
    legacyHeaders: false, // X-RateLimit-* headers'ı disable et
    
    // Key oluşturma: IP + package_name kombinasyonu
    keyGenerator: (req, res) => {
      const packageName = req.body?.packageName || 
                         req.body?.receiptData?.split('.')[0] || 
                         'unknown';
      const ip = req.ip || req.connection.remoteAddress;
      return `${ip}:${packageName}`;
    },
    
    // Skip health check endpoints
    skip: (req, res) => {
      return req.path === '/health' || req.path === '/ping';
    },
    
    // Rate limit aşıldığında log'u
    onLimitReached: (req, res, options, next) => {
      console.warn(`[RATE LIMIT] ${req.ip} - ${req.path}`);
    },
    
    // Custom handler
    handler: (req, res, options, next) => {
      res.status(options.statusCode).json({
        ok: false,
        error: options.message,
        retryAfter: req.rateLimit.resetTime,
      });
    },
  });
}

// Genel API rate limiter (tüm endpoints)
export function createGlobalRateLimiter() {
  return rateLimit({
    windowMs: 60 * 1000, // 1 dakika
    max: 1000, // Global: saniyede ~16 request
    message: 'Çok fazla istek. Lütfen daha sonra tekrar deneyin.',
    standardHeaders: true,
    legacyHeaders: false,
    
    skip: (req, res) => {
      return req.path === '/health' || req.path === '/ping';
    },
  });
}

// Health check endpoint'i (rate limiting olmadan)
export function healthCheck(req, res) {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
}
