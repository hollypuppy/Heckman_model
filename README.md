# Bayesian Heckman Selection Model

In many real-world scenarios, data are not simply missing at random; instead, the absence of certain observations can be systematically linked to specific characteristics of the dataset. Take, for example, a situation where a company is collecting customer feedback through a survey. 

- First Stage (Selection Equation):
  <div align="center">
  $Z_i = X_i\beta_s + u_i$

  $D_i = 1$ if $Z_i >0$; $D_i = 0$ if $Z_i <0$
  </div> 
  The selection process, in this case, is the customer’s choice whether to take the survey (yes or no). This stage uses a probit model to predict the likelihood of survey participation. 

- Second Stage (Outcome Equation):
  <div align="center">
   $Y_i = X_{i}\beta_o + \epsilon_i$
  </div> 
  This equation models the rating of the product. In the data, we only observe $Y_i$ if $D_i=1$, otherwise $Y_i$ is missing.

In the model, $(u_i,\epsilon_i)$ has a bivaraite normal distribution:  <img width="229" alt="image" src="https://github.com/user-attachments/assets/e93355a5-a90c-411c-84ad-f2df5d5ae12c">

We can jointly model the two stages:
<img width="279" alt="image" src="https://github.com/user-attachments/assets/1a8d94ed-5725-41a3-a5ee-e483ae6c1330">

The log-likelihood is

<div align="center">
<img width="521" alt="image" src="https://github.com/user-attachments/assets/9af340b7-cfed-461c-a6f0-ebce7baa9d60">
</div> 

where
- $N_1$ is the number of observations we observe 
- $N_0$ is the number of observations we do not observe, and $N_1 + N_0 = N$
- $P(Y_i,Z_i>0 \mid X_i) = P(Y_i)P(Z_i>0\mid Y_i,X_i)$







