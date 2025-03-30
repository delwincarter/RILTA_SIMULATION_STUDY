


# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Library Path
.libPaths("~/R/x86_64-pc-linux-gnu-library/4.1")

# List of required libraries
required_libraries <- c("parallel", "MplusAutomation", "glue", "here", "tidyverse")

# Check if libraries are installed, and if not, install them
for (lib in required_libraries) {
  if (!requireNamespace(lib, quietly = TRUE)) {
    install.packages(lib)
  }
}

# Load required libraries
library(parallel)
library(MplusAutomation)
library(glue)
library(here)
library(tidyverse)


# Step 1: Create the cluster for parallel processing
num_cores <- detectCores() - 1  # Detect the number of available cores (minus 1)
cl <- makeCluster(num_cores, type = "PSOCK")  # Create the PSOCK cluster

# Step 2: Define the function for the simulation

#Run all models
rilta_rilta_func <- function(N, TPs, Lambda) {
  
  RILTA_RILTA <- mplusObject(
    TITLE = glue("Generate RILTA_RILTA_N_{N}_TP_{TPs}_TH_1"),
    
    MONTECARLO =
      glue("NAMES = u11-u15 u21-u25;
      GENERATE = u11-u15 u21-u25(1);
      CATEGORICAL = u11-u15 u21-u25;
      GENCLASSES = c1(2) c2(2);
      CLASSES = c1(2) c2(2);
      NOBSERVATIONS = {N};
      SEED = 07252005;
      NREPS = 500;
      !!SAVE = repM1*.dat;
      RESULTS = RILTA_RILTA_N_{N}_TP_{TPs}_TH_1_lambda_{Lambda}.csv;"),
    
    ANALYSIS =
      "TYPE = MIXTURE;
      algorithm = integration;
      INTEGRATION = STANDARD(20);
      starts= 250 100;
      logcriterion=0.00001;
      mconv=0.00001;",
    
    OUTPUT = "TECH9",
    
    MODELPOPULATION = glue("	
        %OVERALL%

       [c1#1-c2#1*0];
      	c2#1 on c1#1*{TPs};
      	
       f by u11-u15*{Lambda} (p1-p5)
            u21-u25*{Lambda} (p1-p5);
        f@1;
        [f@0];
        
      MODEL POPULATION-c1:
        %c1#1%
     [u11$1*1 u12$1*1 u13$1*1 u14$1*1 u15$1*1] (p111-p115);

        %c1#2%
     [u11$1*-1 u12$1*-1 u13$1*-1 u14$1*-1 u15$1*-1] (p121-p125);

      MODEL POPULATION-c2:  
        %c2#1%
     [u21$1*1 u22$1*1 u23$1*1 u24$1*1 u25$1*1] (p111-p115);

        %c2#2%
     [u21$1*-1 u22$1*-1 u23$1*-1 u24$1*-1 u25$1*-1] (p121-p125);
       "),
    
    MODEL =
      glue("	
        %OVERALL%
          [c1#1-c2#1*0](par1-par2);
        	c2#1 on c1#1*{TPs} (par11);
        	
       f by u11-u15*{Lambda} (p1-p5)
            u21-u25*{Lambda} (p1-p5);
      	f@1;
        [f@0];

     MODEL c1:
        %c1#1%
     [u11$1*1 u12$1*1 u13$1*1 u14$1*1 u15$1*1] (p111-p115);

        %c1#2%
     [u11$1*-1 u12$1*-1 u13$1*-1 u14$1*-1 u15$1*-1] (p121-p125);

    MODEL c2: 	
        %c2#1%
     [u21$1*1 u22$1*1 u23$1*1 u24$1*1 u25$1*1] (p111-p115);

        %c2#2%
     [u21$1*-1 u22$1*-1 u23$1*-1 u24$1*-1 u25$1*-1] (p121-p125);
	      "),
    
    MODELCONSTRAINT =
      if (TPs == 1.385) {
        glue("
        New(
        trans11*.80 trans12*.20 trans21*.5 trans22*.5
        prob11*.5 prob12*.5 prob21*.65 prob22*.35);
        trans11 = 1/(1+exp(-(par2+par11)));
        trans12 = 1-trans11;
        trans21 = 1/(1+exp(-par2));
        trans22 = 1- trans21;
        !marginal probabilities at T1 and T2:
        prob11 = 1/(1+exp(-par1));
        prob12 = 1 - prob11;
        prob21 = prob11*trans11+prob12*trans21;
        prob22 = 1- prob21;
        ")
      } 
    else if (TPs == .85) {
      glue("
        New(
        trans11*.70 trans12*.30 trans21*.5 trans22*.5
        prob11*.5 prob12*.5 prob21*.60 prob22*.4);
        trans11 = 1/(1+exp(-(par2+par11)));
        trans12 = 1-trans11;
        trans21 = 1/(1+exp(-par2));
        trans22 = 1- trans21;
        !marginal probabilities at T1 and T2:
        prob11 = 1/(1+exp(-par1));
        prob12 = 1 - prob11;
        prob21 = prob11*trans11+prob12*trans21;
        prob22 = 1- prob21;
        ")
    } 
    else  if (TPs == .41) {
      glue("
        New(
        trans11*.60 trans12*.40 trans21*.5 trans22*.5
        prob11*.5 prob12*.5 prob21*.55 prob22*.45);
        trans11 = 1/(1+exp(-(par2+par11)));
        trans12 = 1-trans11;
        trans21 = 1/(1+exp(-par2));
        trans22 = 1- trans21;
        !marginal probabilities at T1 and T2:
        prob11 = 1/(1+exp(-par1));
        prob12 = 1 - prob11;
        prob21 = prob11*trans11+prob12*trans21;
        prob22 = 1- prob21;
        ")
    } 
    else if (TPs == -.41) {
      glue("
        New(
        trans11*.40 trans12*.60 trans21*.5 trans22*.5
        prob11*.5 prob12*.5 prob21*.45 prob22*.55);
        trans11 = 1/(1+exp(-(par2+par11)));
        trans12 = 1-trans11;
        trans21 = 1/(1+exp(-par2));
        trans22 = 1- trans21;
        !marginal probabilities at T1 and T2:
        prob11 = 1/(1+exp(-par1));
        prob12 = 1 - prob11;
        prob21 = prob11*trans11+prob12*trans21;
        prob22 = 1- prob21;
        ")
    } 
    else if (TPs == -.85) {
      glue("
        New(
        trans11*.30 trans12*.70 trans21*.5 trans22*.5
        prob11*.5 prob12*.5 prob21*.40 prob22*.60);
        trans11 = 1/(1+exp(-(par2+par11)));
        trans12 = 1-trans11;
        trans21 = 1/(1+exp(-par2));
        trans22 = 1- trans21;
        !marginal probabilities at T1 and T2:
        prob11 = 1/(1+exp(-par1));
        prob12 = 1 - prob11;
        prob21 = prob11*trans11+prob12*trans21;
        prob22 = 1- prob21;
        ")
    } 
    
    else if (TPs == -1.385) {
      glue("
         New(
        trans11*.20 trans12*.80 trans21*.5 trans22*.5
        prob11*.5 prob12*.5 prob21*.35 prob22*.65);

        trans11 = 1/(1+exp(-(par2+par11)));
        trans12 = 1-trans11;
        trans21 = 1/(1+exp(-par2));
        trans22 = 1- trans21;
        !marginal probabilities at T1 and T2:
        prob11 = 1/(1+exp(-par1));
        prob12 = 1 - prob11;
        prob21 = prob11*trans11+prob12*trans21;
        prob22 = 1- prob21;")
    }
  )
  
  # Run Mplus model
  RILTA_RILTA_Model<- mplusModeler(RILTA_RILTA, 
                                   dataout = here("Simulations", "STUDY_1", "2 Time Points", "4_2T_RILTA_GEN_RILTA_ANALYZED", glue("RILTA_RILTA_N_{N}_TP_{TPs}_TH_1_lambda_{Lambda}.dat")),
                                   modelout = glue(here("Simulations", "STUDY_1", "2 Time Points", "4_2T_RILTA_GEN_RILTA_ANALYZED",  "RILTA_RILTA_N_{N}_TP_{TPs}_TH_1_lambda_{Lambda}.inp")),
                                   check = TRUE, run = TRUE, hashfilename = FALSE)
  return(RILTA_RILTA_Model)
}

#Create grid of conditions for iteration
p1 <- expand.grid(N = c(500, 1000, 2000, 4000),
                  TPs = c(1.385, .85, .41, -.41, -.85, -1.385),
                  lambda = c(0, 1, 1.5, 2, 2.5, 3))

# Set up parallel cluster
# Determine the number of conditions (tasks)
num_conditions <- nrow(p1)

# Limit cores to the available resources per node (e.g., 40 cores per node)
cores_per_node <- 40  # Adjust based on your cluster's specs
num_cores <- min(num_conditions, cores_per_node)

# Create the cluster
print(paste("Number of Cores Allocated:", num_cores))
cl <- makeCluster(num_cores)

# Export necessary functions and variables to the cluster
clusterExport(cl, c("rilta_rilta_func", "p1", "here", "glue"))
clusterEvalQ(cl, {
  library(MplusAutomation)
  library(glue)
  library(here)
})


start_time <- Sys.time()  # Start timer

result_list <- parLapply(cl, 1:nrow(p1), function(i) {
  rilta_rilta_func(p1$N[i], p1$TPs[i], p1$Lambda[i])
})


end_time <- Sys.time()

# Calculate elapsed time in seconds
elapsed_time_secs <- as.numeric(difftime(end_time, start_time, units = "secs"))

# Convert to days, hours, minutes, and seconds
days <- floor(elapsed_time_secs / (24 * 3600))
hours <- floor((elapsed_time_secs %% (24 * 3600)) / 3600)
minutes <- floor((elapsed_time_secs %% 3600) / 60)
seconds <- round(elapsed_time_secs %% 60)

# Print the results
print(paste("Start time:", start_time))
print(paste("End time:", end_time))
print(paste("Total time elapsed:", days, "days", hours, "hours", minutes, "minutes", seconds, "seconds"))

# Stop the cluster
stopCluster(cl)
