// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_fun_flat_jax {
  func.func public @main(%arg0: tensor<i64>, %arg1: tensor<?xf32> {mhlo.sharding = ""}) -> tensor<?xf32> {
    %0 = stablehlo.convert %arg0 : (tensor<i64>) -> tensor<i32>
    %1 = stablehlo.reshape %0 : (tensor<i32>) -> tensor<1xi32>
    %2 = stablehlo.dynamic_iota %1, dim = 0 : (tensor<1xi32>) -> tensor<?xi64>
    %3 = stablehlo.constant dense<0> : tensor<i64>
    %4 = stablehlo.broadcast_in_dim %3, dims = [] : (tensor<i64>) -> tensor<1xi64>
    %5 = "stablehlo.gather"(%arg1, %4) {dimension_numbers = #stablehlo.gather<collapsed_slice_dims = [0], start_index_map = [0]>, indices_are_sorted = true, slice_sizes = array<i64: 1>} : (tensor<?xf32>, tensor<1xi64>) -> tensor<f32>
    %6 = stablehlo.convert %2 : (tensor<?xi64>) -> tensor<?xf32>
    %7 = stablehlo.convert %arg0 : (tensor<i64>) -> tensor<i32>
    %8 = stablehlo.reshape %7 : (tensor<i32>) -> tensor<1xi32>
    %9 = stablehlo.dynamic_broadcast_in_dim %5, %8, dims = [] : (tensor<f32>, tensor<1xi32>) -> tensor<?xf32>
    %10 = stablehlo.add %6, %9 : tensor<?xf32>
    return %10 : tensor<?xf32>
  }
}

