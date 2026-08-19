// Package transport mounts the Connect handlers and the interceptor chain
// onto the API's HTTP mux (ADR-0002).
//
// Empty until Epic 03 tasks 03.4-03.8. It exists as a package so that
// `make contract` has something to compile; the contract round-trip tests
// land with the handlers.
package transport
