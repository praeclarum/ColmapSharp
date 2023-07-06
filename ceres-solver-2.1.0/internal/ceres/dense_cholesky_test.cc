// Ceres Solver - A fast non-linear least squares minimizer
// Copyright 2022 Google Inc. All rights reserved.
// http://ceres-solver.org/
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name of Google Inc. nor the names of its contributors may be
//   used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Author: sameeragarwal@google.com (Sameer Agarwal)

#include "ceres/dense_cholesky.h"

#include <memory>
#include <numeric>
#include <string>
#include <vector>

#include "Eigen/Dense"
#include "ceres/internal/config.h"
#include "ceres/internal/eigen.h"
#include "ceres/linear_solver.h"
#include "glog/logging.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

namespace ceres {
namespace internal {

using Param = DenseLinearAlgebraLibraryType;

namespace {

std::string ParamInfoToString(testing::TestParamInfo<Param> info) {
  return DenseLinearAlgebraLibraryTypeToString(info.param);
}
}  // namespace

class DenseCholeskyTest : public ::testing::TestWithParam<Param> {};

TEST_P(DenseCholeskyTest, FactorAndSolve) {
  // TODO(sameeragarwal): Convert these tests into type parameterized tests so
  // that we can test the single and double precision solvers.

  using Scalar = double;
  using MatrixType = Eigen::Matrix<Scalar, Eigen::Dynamic, Eigen::Dynamic>;
  using VectorType = Eigen::Matrix<Scalar, Eigen::Dynamic, 1>;

  LinearSolver::Options options;
  ContextImpl context;
  options.context = &context;
  options.dense_linear_algebra_library_type = GetParam();
  std::unique_ptr<DenseCholesky> dense_cholesky =
      DenseCholesky::Create(options);

  const int kNumTrials = 10;
  const int kMinNumCols = 1;
  const int kMaxNumCols = 10;

  for (int num_cols = kMinNumCols; num_cols < kMaxNumCols; ++num_cols) {
    for (int trial = 0; trial < kNumTrials; ++trial) {
      const MatrixType a = MatrixType::Random(num_cols, num_cols);
      MatrixType lhs = a.transpose() * a;
      lhs += VectorType::Ones(num_cols).asDiagonal();
      Vector x = VectorType::Random(num_cols);
      Vector rhs = lhs * x;
      Vector actual = Vector::Random(num_cols);

      LinearSolver::Summary summary;
      summary.termination_type = dense_cholesky->FactorAndSolve(
          num_cols, lhs.data(), rhs.data(), actual.data(), &summary.message);
      EXPECT_EQ(summary.termination_type, LINEAR_SOLVER_SUCCESS);
      EXPECT_NEAR((x - actual).norm() / x.norm(),
                  0.0,
                  std::numeric_limits<double>::epsilon() * 10)
          << "\nexpected: " << x.transpose()
          << "\nactual  : " << actual.transpose();
    }
  }
}

namespace {

// NOTE: preprocessor directives in a macro are not standard conforming
decltype(auto) MakeValues() {
  return ::testing::Values(EIGEN
#ifndef CERES_NO_LAPACK
                           ,
                           LAPACK
#endif
#ifndef CERES_NO_CUDA
                           ,
                           CUDA
#endif
  );
}

}  // namespace

INSTANTIATE_TEST_SUITE_P(_, DenseCholeskyTest, MakeValues(), ParamInfoToString);

}  // namespace internal
}  // namespace ceres
