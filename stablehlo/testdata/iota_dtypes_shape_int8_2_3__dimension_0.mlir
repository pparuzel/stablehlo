// RUN: diff <(stablehlo-opt %s --stablehlo-legalize-to-vhlo --vhlo-to-version=target=current -emit-bytecode | stablehlo-opt --vhlo-legalize-to-stablehlo) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @expected() : () -> tensor<2x3xi8>
    %1 = stablehlo.iota dim = 0 : tensor<2x3xi8>
    %2 = stablehlo.custom_call @check.eq(%1, %0) : (tensor<2x3xi8>, tensor<2x3xi8>) -> tensor<i1>
    return %2 : tensor<i1>
  }
  func.func private @expected() -> tensor<2x3xi8> {
    %0 = stablehlo.constant dense<[[0, 0, 0], [1, 1, 1]]> : tensor<2x3xi8>
    return %0 : tensor<2x3xi8>
  }
}