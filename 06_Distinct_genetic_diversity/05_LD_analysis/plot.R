library(tidyverse)
library(patchwork)

load("SNP_InDel_SV.ld.agrestis.5k.Rdata")
# load("SNP_InDel_SV.ld.melo.5k.Rdata")
dat.ld %>% head() 

dat.ld.new<-dat.ld %>% 
  mutate(group=paste0(str_extract(SNP_A,pattern = "[A-Za-z]+$"),
                      "_",
                      str_extract(SNP_B,pattern = "[A-Za-z]+$")))
  
dat.ld.new %>% 
  mutate(new_group=case_when(
    group == "SNP_SV"|group=="SV_SNP" ~ "SNP_SV",
    group == "InDel_SV"|group=="SV_InDel" ~ "InDel_SV",
  #  group == "InDel_SNP"|group=="SNP_InDel" ~ "SNP_InDel",
    group == "SNP_SNP" ~ "SNP_SNP",
    group == "SV_SV" ~ "SV_SV",
    TRUE ~ "OTHERS"
  )) -> dat.ld.new

# 首先创建分箱函数
categorize_r2 <- function(r2) {
  case_when(
    r2 >= 0 & r2 <= 0.2 ~ "0<=R2<=0.2",
    r2 > 0.2 & r2 <= 0.5 ~ "0.2<R2<=0.5",
    r2 > 0.5 & r2 < 0.7 ~ "0.5<R2<0.7",
    r2 >= 0.7 ~ "R2>=0.7",
    TRUE ~ NA_character_
  )
}

# 对数据进行分类
dat.categorized <- dat.ld.new %>%
  filter(new_group %in% c("SNP_SV", "InDel_SV")) %>%
  mutate(r2_category = categorize_r2(R2))

# 统计每个类别的计数
count_stats <- dat.categorized %>%
  group_by(new_group, r2_category) %>%
  summarise(count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = new_group, values_from = count, values_fill = 0)

# 将统计结果写入文本文件
write.table(count_stats, "R2_category_counts.agrestis.5k.txt", sep = "\t", row.names = FALSE, quote = FALSE)



#p1<-ggplot(data=dat.ld.new %>% filter(new_group=="SNP_SV"),
#       aes(x=R2))+
#  geom_histogram(aes(y=after_stat(count / sum(count))),
#                 bins = 150,
#                 alpha=0.8,
#                 color="grey",
#                 fill="#009f73")+
#  ylim(NA,0.05)+
#  theme_bw(base_size = 15)+
#  theme(panel.grid = element_blank())+
#  labs(title = "SNP_SV")


#p2<-ggplot(data=dat.ld.new %>% filter(new_group=="InDel_SV"),
#       aes(x=R2))+
#  geom_histogram(aes(y=after_stat(count / sum(count))),
#                 bins = 150,
#                 alpha=0.8,
#                 color="grey",
#                 fill="#56b4e8")+
#  ylim(NA,0.05)+
#  theme_bw(base_size = 15)+
#  theme(panel.grid = element_blank())+
#  labs(title = "InDel_SV")
p1_p2 <- ggplot(data = dat.ld.new %>% filter(new_group %in% c("SNP_SV", "InDel_SV")),
       aes(x = R2, fill = new_group, color = new_group)) +
  geom_histogram(aes(y = after_stat((count / sum(count))*100)),
                 bins = 150,
                 alpha = 0.5,  # 调整透明度
                 position = "identity") +  # 使用identity位置使直方图重叠
  scale_fill_manual(values = c("SNP_SV" = "#95a792", "InDel_SV" = "#56b4e8")) +
  scale_color_manual(values = c("SNP_SV" = "#95a792", "InDel_SV" = "#56b4e8")) +
  ylim(NA, 2.5) +
  theme_bw(base_size = 15) +
  theme(panel.grid = element_blank(),
        legend.position = c(0.8, 0.8)) +  # 添加图例
  labs(x = expression(R^2), y = "Frequency (%)") +
  guides(fill = guide_legend(title = "Group"),
         color = guide_legend(title = "Group"))

#p3<-ggplot(data=dat.ld.new %>% filter(new_group=="SV_SV"),
#       aes(x=R2))+
#  geom_histogram(aes(y=after_stat(count / sum(count))),
#                 bins = 150,
#                 alpha=0.8,
#                 color="grey",
#                 fill="#d55e00")+
#  ylim(NA,0.025)+
#  theme_bw(base_size = 15)+
#  theme(panel.grid = element_blank())+
#  labs(title = "SV_SV")

#p4<-ggplot(data=dat.ld.new %>% filter(new_group=="SNP_SNP"),
#       aes(x=R2))+
#  geom_histogram(aes(y=after_stat(count / sum(count))),
#                 bins = 150,
#                 alpha=0.8,
#                 color="grey",
#                 fill="#0072b1")+
#  ylim(NA,0.025)+
#  theme_bw(base_size = 15)+
#  theme(panel.grid = element_blank())+
#  labs(title = "SNP_SNP")
#p5<-ggplot(data=dat.ld.new %>% filter(new_group=="SNP_InDel"),
#       aes(x=R2))+
#  geom_histogram(aes(y=after_stat(count / sum(count))),
#                 bins = 150,
#                 alpha=0.8,
#                 color="grey",
#                 fill="#d55e00")+
#  ylim(NA,0.025)+
#  theme_bw(base_size = 15)+
#  theme(panel.grid = element_blank())+
#  labs(title = "SNP_SNP")
#ggsave("SNP_SV.pdf", plot = p1, device = "pdf", width = 10, height = 8)
#ggsave("InDel_SV.pdf", plot = p2, device = "pdf", width = 10, height = 8)
ggsave("SNP-InDel_SV.agrestis.5k.pdf", plot = p1_p2, device = "pdf", width = 15, height = 8)
# ggsave("SNP-InDel_SV.melo.5k.pdf", plot = p1_p2, device = "pdf", width = 15, height = 8)
#ggsave("SV_SV.pdf", plot = p3, device = "pdf", width = 10, height = 8)
#ggsave("SNP_SNP.pdf", plot = p4, device = "pdf", width = 10, height = 8)
#ggsave("SNP_InDel.pdf", plot = p5, device = "pdf", width = 10, height = 8)
