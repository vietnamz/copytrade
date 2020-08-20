package prime

import (
	"bytes"
	"context"
	"github.com/vietnamz/prime-generator/api/server/httputils"
	"github.com/vietnamz/prime-generator/api/types"
	"net/http"
	"time"
)

func (s *primeRoute) primeHandler(ctx context.Context, w http.ResponseWriter, r *http.Request, vars map[string]string) error {
	w.Header().Add("Cache-Control", "no-cache, no-store, must-revalidate")
	w.Header().Add("Pragma", "no-cache")

	if r.Method == http.MethodHead {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.Header().Set("Content-Length", "0")
	}
	key, ok := r.URL.Query()["number"]
	if ok == false {
		w.WriteHeader(400)
		_, err := w.Write(bytes.NewBufferString("number is required").Bytes())
		return err
	}
	start := time.Now()
	result, err := s.D.PrimeSrv.TakeLargestPrimesV2(key[0])
	elapse := time.Since(start)
	if err != nil {
		return err
	}
	var rv types.PrimeNumber
	rv.Mtime = elapse.String()
	rv.Number = result
	return httputils.WriteJSON(w, http.StatusOK, rv)
}