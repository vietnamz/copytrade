package daemon

import (
	"bytes"
	"errors"
	"fmt"
	"github.com/sirupsen/logrus"
	"github.com/vietnamz/prime-generator/daemon/config"
	"math/big"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
)

type PrimeService struct {
	cfg *config.Config
}

// Constructor to initialize an prime generator srv.
func newPrimeService(config *config.Config) *PrimeService{
	return &PrimeService{
		config,
	}
}
// TakeLargestPrimes returns a largest prime number
// with an upper bound input provided.
// Input : upperBound 	: uint64
// Output: result		: uint64
// Limitation:
//				input < 2^64(18446744073709551615)
// Notes: if the result == 0, means we have an error.
func (p *PrimeService) TakeLargestPrimes(upperBound string) string {
	//./primesieve 1 18446744073709551611 -n
	result := strconv.Itoa(0)
	valid, _ := regexp.Match("^[0-9]*$", bytes.NewBufferString(upperBound).Bytes())
	if valid == false {
		logrus.Printf("no valid")
		return result
	}
	cmd := exec.Command("primesieve", "1",  upperBound, "-n")
	var out bytes.Buffer
	cmd.Stdout = &out
	err := cmd.Run()
	if err != nil {
		logrus.Errorf("Encounter an error %s", err)
		return result
	}
	output := out.String()
	if strings.Contains(output, "Nth prime:") == false {
		logrus.Errorf("No prime has been found : %s", output)
		return result
	}
	resultStr := output[strings.LastIndex(output, "Nth prime: ") + len("Nth prime: "):]
	resultStr = strings.TrimSpace(resultStr)
	valid, _ = regexp.Match("^[0-9]*$", bytes.NewBufferString(resultStr).Bytes())
	if valid == false {
		return result
	}
	return resultStr
}

func (p *PrimeService) TakeLargestPrimesV2(upperBound string) (string, error) {
	//./primesieve 1 18446744073709551611 -n
	result := big.NewInt(0)
	valid, _ := regexp.Match("^[0-9]*$", bytes.NewBufferString(upperBound).Bytes())
	if valid == false {
		logrus.Printf("no valid")
		return result.String(), errors.New("numeric value is required")
	}
	result.SetString(upperBound, 10)
	if result.Cmp(big.NewInt(2)) == -1 {
		return result.String(), errors.New("can not be less than 2")
	}
	// if this is an even number minus 1.
	if big.NewInt(0).Mod( result, big.NewInt(2 )).Cmp(big.NewInt(0) ) == 0 {
		result = result.Sub(result, big.NewInt(1))
	} else {
		result = result.Sub(result, big.NewInt(2))
	}
	// if < 2. return 2.
	if result.Cmp(big.NewInt(2)) == -1 {
		return big.NewInt(2).String(), nil
	}
	for {
		rv , err := isPrime( result )
		if err !=nil {
			fmt.Println(err)
			return big.NewInt(0).String(), err
		} else if rv == true {
			return result.String(), nil
		} else {
			result = result.Sub( result, big.NewInt( 2 ) )
		}
	}
	return result.String(), nil
}
func isPrime(prime *big.Int) (bool, error)  {
	//openssl prime 4314134392890548590438093860456904
	cmd := exec.Command("openssl", "prime",  prime.String())
	var out bytes.Buffer
	cmd.Stdout = &out
	err := cmd.Run()
	if err != nil {
		logrus.Errorf("Encounter an error %s", err)
		return false, err
	}
	output := strings.TrimSpace(out.String())
	if strings.Contains(output, "is not prime") == true {
		logrus.Debugf("No prime has been found so far : %s", output)
		return false, nil
	} else {
		return true, nil
	}
	return false, nil
}
