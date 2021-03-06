#' Read distribution plot for scRNA-seq analysis
#'
#' Summary plot of total reads, duplicate reads ratio, mappability, exon and intron reads ratio for scRNA-seq analysis.
#'
#' @docType methods
#' @name RNAReadDistrPlot
#' @rdname RNAReadDistrPlot
#'
#' @param bamstat.filepath Path of the scRNA-seq mapping summary file generated by \code{MAESTRO} workflow,
#' such as PREFIX_bam_stat.txt.
#' @param readdistr.filepath Path of the scRNA-seq read distribution file generated by \code{MAESTRO} workflow,
#' such as PREFIX_read_distribution.txt.
#' @param name Name for the output read distribution plot.
#'
#' @author Dongqing Sun, Chenfei Wang
#'
#' @importFrom ggplot2 aes element_blank element_text geom_bar geom_text ggplot margin theme theme_set xlab ylab
#' @export

RNAReadDistrPlot <- function(bamstat.filepath, readdistr.filepath, name){
  theme_set(cowplot::theme_cowplot())
  RCB_blue = "#2166AC"
  RCB_red = "#B2182B"
  
  read_distr = read.table(readdistr.filepath, header = TRUE, skip = 4, nrows = 10)
  total_tags = unlist(strsplit(readLines(readdistr.filepath, n = 3)[2], split = " "))
  total_tags = as.numeric(total_tags[length(total_tags)])
  
  bam_stat_list = readLines(bamstat.filepath)[c(6,14)]
  bam_stat_list = sapply(bam_stat_list, function(x){
    return(sub(":\\s+",":",x))
  })
  names(bam_stat_list) = NULL
  bam_stat_list = as.numeric(unlist(strsplit(bam_stat_list, split = ":"))[seq(2,2*length(bam_stat_list),2)])
  
  exon_tags = sum(read_distr$Tag_count[1:3])
  intron_tags = read_distr$Tag_count[4]
  map_list = c(bam_stat_list, exon_tags, intron_tags)/1000000

    # metrics = read.csv(bamstat.filepath, header = TRUE)
    # total_reads = as.numeric(gsub(pattern = ",", replacement = "", x = metrics[1,4]))
    # unique_reads = as.numeric(gsub(pattern = "%", replacement = "", x = metrics[1,16]))/100*total_reads
    # exon_reads = as.numeric(gsub(pattern = "%", replacement = "", x = metrics[1,15]))/100*total_reads
    # intron_reads = as.numeric(gsub(pattern = "%", replacement = "", x = metrics[1,14]))/100*total_reads
    # map_list = c(total_reads, unique_reads, exon_reads, intron_reads)/1000000

  map_ratio_list = round(map_list*100/map_list[1],2)
  map_ratio_list = paste0(map_ratio_list, "%")
  Group = c("Total reads", "Uniquely mapped reads","Exon reads", "Intron reads")
  map_df = data.frame(ReadCount = map_list, Group, stringsAsFactors = FALSE)
  map_df$Group = factor(map_df$Group, levels = Group)
  
  png(paste0(name ,"_scRNA_read_distr.png"), width=4.5,height=4.8, res = 300, units = "in")
  p = ggplot(map_df, aes(x = Group, y = ReadCount)) + 
    geom_bar(stat="identity", fill = RCB_blue) + 
    xlab(NULL) + ylab("Read counts (M)") + 
    theme(axis.title = element_text(size = 13), axis.text.y = element_text(size = 12, angle = 90, hjust = 0.5), 
          axis.text.x = element_text(angle = 45, size = 12, hjust = 1),axis.ticks.x = element_blank(),
          legend.position="none", axis.title.y = element_text(margin = margin(r = 20, unit = "pt"))) + 
    geom_text(aes(label = map_ratio_list, y = ReadCount + 0.04*map_list[1]), size = 4.8) 
  print(p)
  dev.off()
}