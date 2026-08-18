from fastapi import APIRouter
from app.schemas.security_analysis import URLAnalyzeRequest
import httpx
from urllib.parse import urlparse

# api.py tarafından dahil edilen "router" nesnesi
router = APIRouter()


@router.post("/analyze-url")
async def analyze_url(request: URLAnalyzeRequest):
    """
    Basit URL güvenlik analizi prototipi.
    - Kural tabanlı kontroller (scheme, shortener, suspicious tlds)
    - Hızlı HTTP isteği ile TLS doğrulama kontrolü
    Dönen nesne: threat_level, phishing_score (0-100), is_safe, risk_factors
    """
    url = request.url.strip()
    parsed = urlparse(url)
    domain = parsed.hostname or ''

    score = 100.0
    risk_factors = []

    # 1) Scheme kontrolü
    if parsed.scheme != 'https':
        score -= 40
        risk_factors.append('Non-HTTPS scheme')

    # 2) Suspicious TLDs / patterns
    suspicious_patterns = ['.tk', '.ml', '.ga', '.cf', '.pw', '.xyz']
    for p in suspicious_patterns:
        if domain.endswith(p):
            score -= 25
            risk_factors.append(f'Suspicious TLD: {p}')
            break

    # 3) URL shortener check
    shorteners = ['bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly', 'is.gd']
    for s in shorteners:
        if domain == s or domain.endswith('.' + s):
            score -= 30
            risk_factors.append('URL shortener detected')
            break

    # 4) Quick remote check (HTTP HEAD) to see reachability and TLS
    try:
        async with httpx.AsyncClient(timeout=6.0, verify=True) as client:
            # Try HEAD first
            try:
                resp = await client.head(url, follow_redirects=True)
            except Exception:
                resp = await client.get(url, follow_redirects=True)

            # If response status not OK, penalize a bit
            if resp.status_code >= 400:
                score -= 10
                risk_factors.append(f'HTTP status {resp.status_code}')
    except httpx.SSLError:
        score -= 40
        risk_factors.append('TLS/SSL validation failed')
    except Exception:
        # network issues or blocked — do not fail hard, just note
        risk_factors.append('Remote check failed')

    # Clamp score
    if score < 0:
        score = 0.0
    if score > 100:
        score = 100.0

    # Decide threat_level
    if score >= 80:
        threat = 'SAFE'
        is_safe = True
    elif score >= 40:
        threat = 'SUSPICIOUS'
        is_safe = False
    else:
        threat = 'MALICIOUS'
        is_safe = False

    return {
        'threat_level': threat,
        'phishing_score': round(score, 1),
        'is_safe': is_safe,
        'risk_factors': risk_factors,
    }