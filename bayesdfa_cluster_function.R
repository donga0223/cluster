args <- commandArgs(trailingOnly = TRUE)
t <- args[1]
l <- args[2]
m <- args[3]
d <- args[4]
i <- args[5]

library(reshape2)
library(bayesdfa)

myres <- function(myT, myL, mymu, mydf, i){
  mydata <- read.csv(paste("simulated_data/T_", myT, "_L_", myL, "_mu_", mymu, "_noise_df_", mydf, "_sim_ind_",i,".csv", sep = ""), header = TRUE)
  data1 <- dcast(mydata, location ~ forecast_date, value.var = "score_diff")
  data1 <- data1[,-1]
  
  
  obs_covar <- expand.grid("time" = 1:myT, "timeseries" = 1:myL, "covariate" = 1)
  # obs_covar$value <- rnorm(nrow(obs_covar), 0, 0.1)
  obs_covar$value <- 1.0
  if(myL == 5){
    m <- fit_dfa(y = as.matrix(data1) , iter = 1000, chains = 3, obs_covar = obs_covar
                 , num_trends = 2
                 , estimate_trend_ar = TRUE, scale = "none"
                 , equal_process_sigma = FALSE, est_correlation = FALSE)
  }else{
    m <- fit_dfa(y = as.matrix(data1) , iter = 1000, chains = 3, obs_covar = obs_covar
                 , num_trends = 5
                 , estimate_trend_ar = TRUE, scale = "none"
                 , equal_process_sigma = FALSE, est_correlation = FALSE)
  }
  
  
  b_obs <- rstan::extract(m$model, "b_obs")
  return(b_obs[[1]])
}


res <- myres(t, l, m, d, i)
save(res, file = paste("bayesdfa_res/res_files/T_",t, "_L_", l, "_mu_", m, "_noise_df_", d, "_sim_ind_", i, ".RData", sep = ""))




