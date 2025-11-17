#!/usr/bin/env python3
import sys
d1={}
d2={}
def main():
    f1 = open(sys.argv[1], 'r')  # SV length
    f2 = open(sys.argv[2], 'r')  # TE length
    f3 = open(sys.argv[3], 'r')  # blast input
    f4 = open(sys.argv[4], 'w')  # output
    
    # 写入表头
    f4.write("Query_id\tqcoverage\tSubject_id\tscoverage\n")
    
    current_query = None
    best_subject = None
    q_min = float('inf')
    q_max = 0
    s_min = float('inf')
    s_max = 0
    for line1 in f1:
        list1=line1.strip().split()
        d1[list1[0]]=list1[1] 
    for line2 in f2:
        list2=line2.strip().split()
        d2[list2[0]]=list2[1]

    for line in f3:
        line = line.strip()
        
        # 跳过空行和注释行
        if not line or line.startswith('#'):
            # 如果是新的查询开始行，处理上一个查询的结果
            if line.startswith('# Query:'):
                if current_query and best_subject:
                    f4.write(f"{current_query}\t{qcoverage}\t{best_subject}\t{scoverage}\n")
                
                # 重置变量为新查询做准备
                parts = line.split()
                current_query = parts[2]
                best_subject = None
                q_min = float('inf')
                q_max = 0
                s_min = float('inf')
                s_max = 0
            continue
        
        # 处理数据行
        fields = line.split()
        query_id = fields[0]
        subject_id = fields[1]
        q_start = int(fields[6])
        q_end = int(fields[7])
        s_start = int(fields[8])
        s_end = int(fields[9])
        
        # 如果是当前查询的第一个比对结果，设置最佳subject
        if best_subject is None:
            best_subject = subject_id
        
        # 只处理最佳subject的比对结果
        if subject_id == best_subject:
            # 更新查询序列的最小和最大位置
            q_min = min(q_min, q_start, q_end)
            q_max = max(q_max, q_start, q_end)
            sv_len=int(q_max-q_min)
            qcoverage=sv_len/int(d1[query_id])
            # 更新subject序列的最小和最大位置
            s_min = min(s_min, s_start, s_end)
            s_max = max(s_max, s_start, s_end)
            te_len=int(s_max-s_min)
            scoverage=te_len/int(d2[best_subject])
    # 处理最后一个查询
    if current_query and best_subject:
        f4.write(f"{current_query}\t{qcoverage}\t{best_subject}\t{scoverage}\n")
    
    f1.close()
    f2.close()
    f3.close()
    f4.close()
if __name__ == '__main__':
    main()
