// SPDX-FileCopyrightText: YEAR The PKG Authors
// SPDX-License-Identifier: BSD-3-Clause

package pragma

// NoCopy is for embedding in a struct that we do not want to copy
// and hack the "go vet" copy lock checker specification and point out.
//
// See:
//  https://github.com/golang/go/issues/8005#issuecomment-190753527
type NoCopy struct{}

// Lock implemensts sync.Locker.
//
// For go vet copy lock checker.
func (*NoCopy) Lock() {}
