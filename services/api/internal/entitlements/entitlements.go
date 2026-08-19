// Package entitlements gates paid features.
//
// v1.0 ships alwaysAllow: everything is free and NO billing code exists in
// this repository (ADR-0010). The real implementation arrives in P5 as a
// generic Droid Builder module, behind this same interface.
package entitlements

import (
	"context"
	"time"

	"github.com/google/uuid"
)

// Feature keys. Add here, never inline a string at a call site.
const (
	FeatureOffline       = "offline"
	FeatureMultiDevice   = "multi_device"
	FeatureUnlimitedHist = "unlimited_history"
	FeatureExports       = "exports"
	FeatureMultiMess     = "multi_mess"
	FeatureNoAds         = "no_ads"
)

// Entitlements answers whether a tenant may use a feature ON A GIVEN DATE.
//
// The `on` parameter is the important design detail: TinBela sells specific
// months, not a subscription. Messes dissolve at semester breaks and students
// hate auto-renew. So entitlement is a question about a date, not a boolean
// flag on an account. Getting this signature right in v1.0 costs nothing and
// saves rewriting every call site in P5.
type Entitlements interface {
	Has(ctx context.Context, tenantID uuid.UUID, feature string, on time.Time) (bool, error)
}

// alwaysAllow is the v1.0 implementation. Everything is free.
type alwaysAllow struct{}

func NewAlwaysAllow() Entitlements { return alwaysAllow{} }

func (alwaysAllow) Has(context.Context, uuid.UUID, string, time.Time) (bool, error) {
	return true, nil
}
