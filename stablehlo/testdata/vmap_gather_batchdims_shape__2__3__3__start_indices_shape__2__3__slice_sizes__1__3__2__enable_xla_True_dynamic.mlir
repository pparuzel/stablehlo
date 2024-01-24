// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_fun_flat_jax {
  func.func public @main(%arg0: tensor<i64>, %arg1: tensor<?x2x3x3xf32> {mhlo.sharding = ""}, %arg2: tensor<?x2x3xi64> {mhlo.sharding = ""}) -> tensor<?x2x3x2xf32> {
    %0 = stablehlo.convert %arg0 : (tensor<i64>) -> tensor<i32>
    %1 = stablehlo.reshape %0 : (tensor<i32>) -> tensor<1xi32>
    %2 = stablehlo.constant dense<2> : tensor<1xi32>
    %3 = stablehlo.constant dense<1> : tensor<1xi32>
    %4 = stablehlo.concatenate %1, %2, %3, dim = 0 : (tensor<1xi32>, tensor<1xi32>, tensor<1xi32>) -> tensor<3xi32>
    %5 = stablehlo.dynamic_iota %4, dim = 0 : (tensor<3xi32>) -> tensor<?x2x1xi64>
    %6 = stablehlo.concatenate %5, %arg2, dim = 2 : (tensor<?x2x1xi64>, tensor<?x2x3xi64>) -> tensor<?x2x4xi64>
    %7 = "stablehlo.gather"(%arg1, %6) {dimension_numbers = #stablehlo.gather<offset_dims = [2, 3], collapsed_slice_dims = [0, 1], start_index_map = [0, 1, 2, 3], index_vector_dim = 2>, slice_sizes = array<i64: 1, 1, 3, 2>} : (tensor<?x2x3x3xf32>, tensor<?x2x4xi64>) -> tensor<?x2x3x2xf32>
    return %7 : tensor<?x2x3x2xf32>
  }
}

