package transport

import (
	"context"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
)

// limiter is a token bucket. Refill is computed on read rather than by a
// ticker, so an idle key costs nothing until it is used again.
type limiter struct {
	tokens   float64
	lastSeen time.Time
}

// RateLimiter caps request rate per key, in process.
//
// In process is deliberate (ADR-0004: no gateway, no Kong). One binary, one
// map. If TinBela ever runs more than one instance this becomes per-instance
// and the effective limit multiplies -- worth revisiting then, not now.
type RateLimiter struct {
	mu      sync.Mutex
	buckets map[string]*limiter
	rate    float64       // tokens per second
	burst   float64       // bucket size
	idleFor time.Duration // evict a key untouched this long
}

// NewRateLimiter builds a limiter allowing `burst` requests immediately and
// `rate` per second sustained.
func NewRateLimiter(rate, burst float64) *RateLimiter {
	return &RateLimiter{
		buckets: make(map[string]*limiter),
		rate:    rate,
		burst:   burst,
		idleFor: 10 * time.Minute,
	}
}

// Allow reports whether one request may proceed for this key.
func (r *RateLimiter) Allow(key string) bool {
	now := time.Now()

	r.mu.Lock()
	defer r.mu.Unlock()

	b, ok := r.buckets[key]
	if !ok {
		r.buckets[key] = &limiter{tokens: r.burst - 1, lastSeen: now}
		r.sweep(now)
		return true
	}

	b.tokens += now.Sub(b.lastSeen).Seconds() * r.rate
	if b.tokens > r.burst {
		b.tokens = r.burst
	}
	b.lastSeen = now

	if b.tokens < 1 {
		return false
	}
	b.tokens--
	return true
}

// sweep drops idle keys. Called under the lock, on insert only -- an
// unbounded map keyed by client IP is otherwise a slow memory leak that a
// scanner could accelerate.
func (r *RateLimiter) sweep(now time.Time) {
	if len(r.buckets) < 1024 {
		return
	}
	for k, b := range r.buckets {
		if now.Sub(b.lastSeen) > r.idleFor {
			delete(r.buckets, k)
		}
	}
}

// rateLimitInterceptor throttles per token where there is one, per client IP
// otherwise.
//
// Keying on the token matters: a mess behind one NAT would otherwise share a
// single IP bucket, and one busy manager would throttle the whole building.
func rateLimitInterceptor(rl *RateLimiter) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			key := rateKey(req.Header(), req.Peer().Addr)
			if !rl.Allow(key) {
				return nil, connect.NewError(connect.CodeResourceExhausted,
					errTooManyRequests)
			}
			return next(ctx, req)
		}
	}
}

var errTooManyRequests = &rateErr{}

type rateErr struct{}

func (*rateErr) Error() string { return "too many requests" }

// rateKey prefers the bearer token, falling back to the peer IP.
func rateKey(h http.Header, peer string) string {
	if raw := h.Get(HeaderAuthorization); raw != "" {
		if token, ok := strings.CutPrefix(raw, "Bearer "); ok {
			return "tok:" + strings.TrimSpace(token)
		}
	}
	if host, _, err := net.SplitHostPort(peer); err == nil {
		return "ip:" + host
	}
	return "ip:" + peer
}
