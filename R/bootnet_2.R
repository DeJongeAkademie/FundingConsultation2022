library('bootnet')
results <- estimateNetwork(
  df[c(yvars, xvars)],
  default = "EBICglasso",
  corMethod = "cor_auto",
  tuning = 0.5)
