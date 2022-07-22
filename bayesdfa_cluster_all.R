
num_cores <- 18L

myTlist <- c(10, 100, 500)
myLlist <- c(5, 50, 50)
mymulist <- c(0, 1, 10)
mydflist <- c(2,100)



num_cores <- "8"
memory <- "8000"

for(tl in 1:length(myTlist)){
  for(m in mymulist){
    for(d in mydflist){
      for(i in seq_len(1000)){
        filename <- paste("bayesdfa_res/shellfiles/T_", myTlist[tl], "_L_", myLlist[tl], "_mu_", m, "_noise_df_", d, "_sim_ind_",i,".sh", sep = "") ## add T,L i
        
        requestCmds <- "#!/bin/bash\n"
        requestCmds <- paste0(requestCmds, "#BSUB -n ", num_cores, " # how many cores we want for our job\n",
                              "#BSUB -R span[hosts=1] # ask for all the cores on a single machine\n",
                              "#BSUB -R rusage[mem=", memory, "] # ask for memory\n",
                              "#BSUB -o log.out # log LSF output to a file\n",
                              "#BSUB -W 72:00 # run time\n",
                              "#BSUB -q long # which queue we want to run in\n")
        
        cat(requestCmds, file = filename)
        cat("module load gcc/8.1.0\n", file = filename, append = TRUE)  
        cat("module purge\n", file = filename, append = TRUE)
        cat("module load R/3.5.1_gcc8.1.0 gcc/8.1.0 binutils/2.37\n", file = filename, append = TRUE)
        #    cat("module load gcc/8.1.0\n", file = filename, append = TRUE)
        #    cat("module load R/4.0.0_gcc\n", file = filename, append = TRUE)
        #    cat("module load gurobi/900\n", file = filename, append = TRUE)
        #cat("module load singularity/singularity-3.6.2\n", file = filename, append = TRUE)
        cat(paste(
          "R CMD BATCH --vanilla \'--args", myTlist[tl], myLlist[tl], m, d, i ,"\'", ## check \
          "bayesdfa_res/bayesdfa_cluster_function.R",
          "bayesdfa_res/bayesdfa_cluster_function.Rout"),
          file = filename, append = TRUE)
        
        bsubCmd <- paste("bsub < ", filename)
        system(bsubCmd)
      }
    }
  }
}







