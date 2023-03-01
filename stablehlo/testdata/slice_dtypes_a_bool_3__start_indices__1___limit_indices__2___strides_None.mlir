// RUN: diff <(stablehlo-opt %s --stablehlo-legalize-to-vhlo --vhlo-to-version=target=current -emit-bytecode | stablehlo-opt --vhlo-legalize-to-stablehlo) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = call @inputs() : () -> tensor<3xi1>
    %1 = call @expected() : () -> tensor<1xi1>
    %2 = "stablehlo.slice"(%0) {limit_indices = dense<2> : tensor<1xi64>, start_indices = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>} : (tensor<3xi1>) -> tensor<1xi1>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<1xi1>, tensor<1xi1>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> tensor<3xi1> {
    %0 = stablehlo.constant dense<true> : tensor<3xi1>
    return %0 : tensor<3xi1>
  }
  func.func private @expected() -> tensor<1xi1> {
    %0 = stablehlo.constant dense<true> : tensor<1xi1>
    return %0 : tensor<1xi1>
  }
}