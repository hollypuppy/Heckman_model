library(mvtnorm)
library(cmdstanr)
library(shinystan)

#################################
## Heckman selection model     ##
##-----------------------------##
## Simulation study via Stan   ##
#################################


## initializations
rm(list=ls()) 
options(max.print=9999)

## simulation parameters (primary)
## i.e., what we will attempt to recover

# ensure length of beta_s = beta_o
BETA_S = c(1, 0, -1, -2)
BETA_O = c(-3, 4, -5, 6)
# bigger RHO and TAU, more pronounced the Heckman correction
RHO = -0.6
TAU = 3.5


## simulation parameters (auxiliary)
## i.e., simulation sizes
N = 5000
ITER = 500
K = length(BETA_S)


## simulate RHS of Y = XB + eps
X = matrix( c(rep(1, N), rnorm(N*(K-1))), N, K) # intercept included in X
cov = matrix( c(1, RHO*TAU, RHO*TAU, TAU^2), 2, 2)
eps = rmvnorm(n=N, sigma=cov)

Z = X %*% cbind(BETA_S, BETA_O) + eps


## simulate LHS of Y = XB + eps
## i.e., Y = (binary selection, continous outcome)
Y_s = (Z[,1] >= 0)
Y_o_complete = Z[,2]
Y_o = Y_o_complete[Y_s]


## BEFORE RUNNING STAN, see that
## BETA_O estimates are biased when not accounting for selectivity
ols = lm(Y_o ~ X[Y_s,] - 1)
BETA_O; print(ols)

##########
## STAN ##
##########
ptm = proc.time()
model_stan <- cmdstan_model('heckman.stan')
data_stan = list(N = N, N_o = length(Y_o), K = K, X = X, Y_s = Y_s, Y_o = Y_o)
run_stan = model_stan$sample(data=data_stan, iter_warmup =250, iter_sampling = 250, chains=1, refresh=25)
proc.time() - ptm


## summary
print(run_stan,max_rows=20)
launch_shinystan(run_stan)

## plot
y_o_idx = sapply(1:run_stan@par_dims$Z_o_neg, simplify=T, function(x) paste('Z_o_neg[', x,']', sep=''))
y_o_hat = as.matrix(run_stan, pars = y_o_idx) #
plot(density(apply(y_o_hat, 2, mean)), main='Censored Outcomes (Y_o): Ground Truth vs. Imputed', lwd = 2)
lines(density(Y_o_complete[!Y_s]), col = 'red', lwd = 2)
#legend(-40, 0.04, legend=c("Ground Truth", "Imputed"), col=c("black", "red"), lwd=2)


