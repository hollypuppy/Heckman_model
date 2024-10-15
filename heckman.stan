data {
  int<lower=0> N;
  int<lower=0> N_o; // num of observed observations
  int<lower=0> K; // dimension of X
  matrix[N, K] X;
  vector[N] Y_s;
  vector[N_o] Y_o;
}

parameters {
  vector[K] beta_s;
  vector[K] beta_o;
  real rho;
  real<lower=0> tau;
  vector[N-N_o] Y_no;
  vector<upper=0>[N - N_o] Z_neg;  // negative utilities
  vector<lower=0>[N_o] Z_pos;    // positive utilities

}

transformed parameters {
  matrix[K, 2] beta;
  beta = append_col(beta_s,beta_o);
  matrix[2, 2] Sigma;
  Sigma[1, 1] = 1;
  Sigma[1, 2] = rho * tau;
  Sigma[2, 1] = rho * tau;
  Sigma[2, 2] = tau * tau;
}

model {
  array[N] vector[2] H_array;

  int idx_pos = 1;
  int idx_neg = 1;

  // this step sets all observations with Y_s=0 to have negative utilities,
  // and all observations with Y_s=1 to have positive utilities.
  for (i in 1:N) {
    vector[2] H_row;
    
    if (Y_s[i] == 1) {
      H_row[1] = Z_pos[idx_pos];
      H_row[2] = Y_o[idx_pos];
      idx_pos += 1;
    } else if (Y_s[i] == 0) {
      H_row[1] = Z_neg[idx_neg];
      H_row[2] = Y_no[idx_neg];
      idx_neg += 1;
    }
    
    H_array[i] = H_row;
  }
  
  array[N] vector[2] mu;
  for (n in 1:N){
    mu[n] = to_vector(X[n] * beta);
  }
  
  H_array ~ multi_normal(mu[1:N], Sigma);
}

