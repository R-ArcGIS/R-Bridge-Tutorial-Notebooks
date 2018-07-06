p = read.table("addRLibraries.txt")
pv = as.vector(p$V1)
install.packages(pv)
